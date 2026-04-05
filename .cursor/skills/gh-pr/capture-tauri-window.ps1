#Requires -Version 5.1
<#
.SYNOPSIS
  Saves a PNG of the first top-level window whose title contains -WindowTitleContains.
  Intended for Tauri dev: run "pnpm tauri dev", then this script while the window is visible.

  Does not commit files; write -OutputPath outside the repo (e.g. $env:TEMP\gh-pr-captures).

.PARAMETER WindowTitleContains
  Substring to match against the window title (see app.windows[].title in src-tauri/tauri.conf.json).
#>
param(
  [Parameter(Mandatory = $true)]
  [string] $OutputPath,

  [string] $WindowTitleContains = "tauri-template",

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

  public static IntPtr FindWindowByTitleContains(string substr) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((hWnd, lParam) => {
      if (!IsWindowVisible(hWnd)) return true;
      int len = GetWindowTextLength(hWnd);
      if (len == 0) return true;
      var sb = new StringBuilder(len + 1);
      GetWindowText(hWnd, sb, sb.Capacity);
      string title = sb.ToString();
      if (title.IndexOf(substr, StringComparison.OrdinalIgnoreCase) >= 0) {
        found = hWnd;
        return false;
      }
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
  $hwnd = [NativeCapture]::FindWindowByTitleContains($WindowTitleContains)
  if ($hwnd -ne [IntPtr]::Zero) { break }
  Start-Sleep -Milliseconds $PollIntervalMs
}

if ($hwnd -eq [IntPtr]::Zero) {
  Write-Error "No visible window with title containing '$WindowTitleContains' within ${TimeoutSeconds}s. Is 'pnpm tauri dev' running?"
}

[NativeCapture]::SaveWindowPng($hwnd, $OutputPath)
Write-Host "Wrote $OutputPath"
