#Requires -Version 5.1
<#
.SYNOPSIS
  Saves a PNG of the first top-level window whose title contains -WindowTitleContains.
  Intended for Tauri dev: run "pnpm tauri dev", then this script while the window is visible.

  Does not commit files; write -OutputPath outside the repo (e.g. $env:TEMP\gh-pr-captures).

.PARAMETER WindowTitleContains
  Substring to match against the window title (see app.windows[].title in src-tauri/tauri.conf.json).

.PARAMETER ExcludeTitleContains
  Skip windows whose title contains any of these strings (case-insensitive). Default excludes common IDEs
  so a project folder name in the title (e.g. "... tauri-template - Cursor") does not steal the capture.
#>
param(
  [Parameter(Mandatory = $true)]
  [string] $OutputPath,

  [string] $WindowTitleContains = "tauri-template",

  [string[]] $ExcludeTitleContains = @("Cursor", "Visual Studio Code", "Visual Studio", "VSCodium", "WebStorm", "idea64"),

  [int] $TimeoutSeconds = 120,

  [int] $PollIntervalMs = 400
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing
$DrawingDll = ([System.Drawing.Bitmap].Assembly.Location)
Add-Type -ReferencedAssemblies $DrawingDll @"
using System;
using System.Text;
using System.Runtime.InteropServices;
using System.Drawing;
using System.Drawing.Imaging;

public static class NativeCapture {
  [DllImport("user32.dll")]
  public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

  [DllImport("user32.dll", CharSet = CharSet.Unicode)]
  public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

  [DllImport("user32.dll")]
  public static extern int GetWindowTextLength(IntPtr hWnd);

  [DllImport("user32.dll")]
  public static extern bool IsWindowVisible(IntPtr hWnd);

  [DllImport("user32.dll")]
  public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

  [DllImport("user32.dll")]
  public static extern bool SetForegroundWindow(IntPtr hWnd);

  [DllImport("user32.dll")]
  public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

  public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

  [StructLayout(LayoutKind.Sequential)]
  public struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
  }

  public const int SW_RESTORE = 9;

  public static IntPtr FindWindowExactTitle(string exact) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((hWnd, lParam) => {
      if (!IsWindowVisible(hWnd)) return true;
      int len = GetWindowTextLength(hWnd);
      if (len == 0) return true;
      var sb = new StringBuilder(len + 1);
      GetWindowText(hWnd, sb, sb.Capacity);
      string title = sb.ToString();
      if (string.Equals(title.Trim(), exact, StringComparison.OrdinalIgnoreCase)) {
        found = hWnd;
        return false;
      }
      return true;
    }, IntPtr.Zero);
    return found;
  }

  static bool TitleHasExcludedFragment(string title, string[] excludes) {
    if (excludes == null) return false;
    foreach (var ex in excludes) {
      if (string.IsNullOrEmpty(ex)) continue;
      if (title.IndexOf(ex, StringComparison.OrdinalIgnoreCase) >= 0) return true;
    }
    return false;
  }

  /// <summary>First try exact title (Tauri window is usually exactly app.windows[].title). Else first visible window whose title contains substr but not IDE markers.</summary>
  public static IntPtr FindWindowPreferExact(string substr, string[] excludeContains) {
    IntPtr exact = FindWindowExactTitle(substr);
    if (exact != IntPtr.Zero) return exact;
    IntPtr found = IntPtr.Zero;
    EnumWindows((hWnd, lParam) => {
      if (!IsWindowVisible(hWnd)) return true;
      int len = GetWindowTextLength(hWnd);
      if (len == 0) return true;
      var sb = new StringBuilder(len + 1);
      GetWindowText(hWnd, sb, sb.Capacity);
      string title = sb.ToString();
      if (title.IndexOf(substr, StringComparison.OrdinalIgnoreCase) < 0) return true;
      if (TitleHasExcludedFragment(title, excludeContains)) return true;
      if (found == IntPtr.Zero) found = hWnd;
      return true;
    }, IntPtr.Zero);
    return found;
  }

  public static void SaveWindowPng(IntPtr hWnd, string path) {
    ShowWindow(hWnd, SW_RESTORE);
    SetForegroundWindow(hWnd);
    System.Threading.Thread.Sleep(200);

    RECT rc;
    if (!GetWindowRect(hWnd, out rc)) {
      throw new InvalidOperationException("GetWindowRect failed.");
    }
    int w = rc.Right - rc.Left;
    int h = rc.Bottom - rc.Top;
    if (w <= 0 || h <= 0) {
      throw new InvalidOperationException("Invalid window size: " + w + "x" + h);
    }

    using (var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb)) {
      using (var g = Graphics.FromImage(bmp)) {
        g.CopyFromScreen(rc.Left, rc.Top, 0, 0, new Size(w, h), CopyPixelOperation.SourceCopy);
      }
      bmp.Save(path, ImageFormat.Png);
    }
  }
}
"@

$dir = Split-Path -Parent -Path $OutputPath
if ($dir -and -not (Test-Path -LiteralPath $dir)) {
  New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$hwnd = [IntPtr]::Zero

while ((Get-Date) -lt $deadline) {
  $hwnd = [NativeCapture]::FindWindowPreferExact($WindowTitleContains, $ExcludeTitleContains)
  if ($hwnd -ne [IntPtr]::Zero) { break }
  Start-Sleep -Milliseconds $PollIntervalMs
}

if ($hwnd -eq [IntPtr]::Zero) {
  Write-Error "No visible window matching '$WindowTitleContains' (excluding: $($ExcludeTitleContains -join ', ')) within ${TimeoutSeconds}s. Bring the Tauri window to the foreground — not Cursor/VS Code."
}

[NativeCapture]::SaveWindowPng($hwnd, $OutputPath)
Write-Host "Wrote $OutputPath"
