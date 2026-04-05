---
name: gh-pr
description: >-
  Guides creating GitHub pull requests with the GitHub CLI (gh): summarizing
  changes, a consistent body format, and Before/After UI screenshots embedded
  directly in the PR description on GitHub (Markdown image syntax with HTTPS
  URLs). For Tauri on Windows, capture-tauri-window.ps1 saves the real desktop
  window to PNG; host PNGs off-repo, then pass --body-file whose Screenshots
  section already contains those URLs. Binary media must not be committed.
  Use when opening a PR, creating a PR with gh, or writing a PR description.
---

# GitHub pull requests (`gh`)

## 含める場所は PR 本文（必須）

**スクリーンショットは「ローカルに取っただけ」では完了ではない。** UI 変更があるとき、**GitHub 上のその PR の説明文（description）の中に**、Before / After を **`![Before](https://...)` / `![After](https://...)` 形式で埋め込む**こと。プレースホルダー、空の「Screenshots」、テンポラリパスの説明だけ、は未完了とみなす。

- **完了の定義:** `gh pr create` または `gh pr edit` のあと、ブラウザで PR を開き、説明文内に画像が**その場で表示**される（リンク切れでない）。
- **禁止:** リポジトリへ PNG/動画をコミットすること。
- **許可:** gist の `raw_url`、ドラフト Release の `browser_download_url`、手動で GitHub に貼り付けたアップロード URL など、**HTTPS で画像として取得できる URL** ならよい。

## Prerequisites

- `gh` is installed and `gh auth login` has been completed.
- Create the PR from a branch that exists on the remote (if not pushed yet, run `git push -u origin <branch>` first).
- **Windows desktop capture:** PowerShell 5.1+ and **[`capture-tauri-window.ps1`](capture-tauri-window.ps1)** in this folder. This is **not** Playwright: it finds the Tauri window by title and copies **on-screen pixels** to a PNG. If `package.json` defines `capture:tauri-window`, you may use `pnpm capture:tauri-window -- ...`; otherwise invoke the script with `-File` as shown below.

## Media: PR vs repository

- **Pull request (required when UI changes):** Before / After を **PR 説明文に** 載せる（HTTPS の Markdown 画像）。ここが空やプレースホルダーのまま PR を出さない。
- **Git repository:** キャプチャファイルを **コミットしない**。作業中は `%TEMP%\gh-pr-captures` などリポジトリ外へ。

### Hosted image URLs（自動化）

優先順位:

1. **`gh gist create`**（動く環境ではこれが簡潔）→ `gh api gists/<id>` で `files["gh-pr-before.png"].raw_url` 等を取得し、本文に埋め込む。
2. **Windows で `gh gist create` が PNG を拒否する場合**（例: `binary file not supported`）→ 下記 **「Windows: gist が使えないとき」** のドラフト Release 手順で HTTPS URL を取得し、**同じく PR 本文に `![]()` で埋め込む**。
3. **手動:** GitHub の PR 編集画面に画像をドラッグ＆ドロップし、生成された URL を本文に残す（最終的に PR 本文に画像が含まれていればよい）。

固定ファイル名 `gh-pr-before.png` / `gh-pr-after.png` を使うと、`gh api` の `--jq` で取りやすい。

## Workflow

### 1. Understand the changes

- `git diff main...HEAD` or `git diff <base>...HEAD` (use the repo’s default base if it is not `main`).
- `git log <base>..HEAD --oneline`
- Reflect findings in the PR “Summary” and “What changed” sections.

### 2. Decide whether the UI changed

- Treat it as a UI change if Svelte/CSS under `src/`, window-related code, or `src-tauri/` affects appearance or screen structure.

### 3. If the UI changed — screenshots (Before / After)

#### 3a. Tauri **desktop window** + **PR 本文へ画像 URL を入れてから** `gh pr create`

Playwright の `localhost` は Tauri ウィンドウではない。**[`capture-tauri-window.ps1`](capture-tauri-window.ps1)** を使う。

**Windows procedure**

1. **出力先（リポジトリ外）:** 例 `%TEMP%\gh-pr-captures`。作成してよい。PNG は **`git add` しない**。

2. **Before（ベースブランチ）:** `<base>`（例 `main`）をチェックアウトできるワークツリーで `pnpm tauri dev` を起動し、ウィンドウが出るまで待つ。

3. **キャプチャ**（`app.windows[].title` に合わせて `-WindowTitleContains` を調整）:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File ./.cursor/skills/gh-pr/capture-tauri-window.ps1 `
     -OutputPath "$env:TEMP\gh-pr-captures\gh-pr-before.png" `
     -WindowTitleContains "tauri-template"
   ```

4. **`pnpm tauri dev` を止め**、ポートを空ける。

5. **After（PR ブランチ）:** ブランチを切り替え、再度 `pnpm tauri dev` → 同様に `gh-pr-after.png` を保存。

6. **HTTPS URL を取得**（gist または下記フォールバック）。**まだ PR を作らない。**

7. **[pr-body-template.md](pr-body-template.md) をコピーし、`### Before` / `### After` に実 URL を書いた Markdown 画像行を入れる**（プレースホルダー禁止）。

8. **`gh pr create ... --body-file`** または既存 PR なら **`gh pr edit <number> --body-file`**。

**Requirements / caveats**

- ウィンドウは**最前面・最小化されていない**こと。スクリプトは `SetForegroundWindow` を呼ぶ。
- **マルチモニタ / DPI:** ずれる場合は OS の表示スケールを確認。
- **macOS / Linux:** このスクリプトは Windows 専用。同等のスクショをリポジトリ外に保存し、**PR 本文への HTTPS 埋め込み**まで行う。

#### Windows: `gh gist create` がバイナリを拒否するとき

`gh gist create` が使えない場合でも、**PR 本文に画像を載せる義務は変わらない。** 次の方法で **公開 HTTPS のダウンロード URL** を得て、`![]()` に使う（リポジトリにバイナリはコミットしない）。

**ドラフト Release に PNG を添付する例**（タグは一意にする）:

```powershell
$tag = "pr-ui-assets-" + (Get-Date -Format "yyyyMMddHHmmss")
gh release create $tag --draft --latest=false `
  --notes "Temporary screenshots for PR description only. Delete after merge." `
  "$env:TEMP\gh-pr-captures\gh-pr-before.png" `
  "$env:TEMP\gh-pr-captures\gh-pr-after.png"
```

アセット URL の取得例:

```bash
gh api repos/:owner/:repo/releases --jq '.[0].assets[] | "\(.name) \(.browser_download_url)"'
```

（`:owner/:repo` は対象リポジトリに合わせる。または `gh repo view --json nameWithOwner -q .nameWithOwner` で確認。）

得られた `browser_download_url` を **`![Before](...)` / `![After](...)` として PR 本文に書く。** マージ後にドラフト Release を削除してよい。

#### 3b. Manual path

GitHub の PR 画面に画像を貼り付けて URL を確定させてもよい。最終的に **PR 説明文に画像が含まれる** こと。`file://` は使わない。

#### 3c. Rules that still apply

- **Never** `git add` screenshot files.
- Before / After が並んで比較できること。

### 4. Fixes that change behavior — video

PR 説明文に埋め込みまたはリンク。動画ファイルをリポジトリにコミットしない。

### 5. Consistent body format

- [pr-body-template.md](pr-body-template.md) をベースに、**Screenshots セクションに実 URL 入りの `![]()` を書いてから** 提出する。

### 6. Create the PR with `gh`

```bash
gh pr create --base main --title "Your title here" --body-file path/to/body.md
```

空の Screenshots で作ってしまった場合は **`gh pr edit <number> --body-file`** で必ず直す。

## Checklist (for agents)

- [ ] Diff とコミット履歴を確認し、Summary がブランチ内容と一致している。
- [ ] UI 変更: **実機 Tauri ウィンドウ**をキャプチャした（Windows は **[`capture-tauri-window.ps1`](capture-tauri-window.ps1)** 等）。
- [ ] **PR の GitHub ページ上**で Before / After 画像が表示される（本文に `![]()` が入っている）。プレースホルダー・未埋めではない。
- [ ] 画像・動画を **git にコミットしていない**。
- [ ] `gh pr create` / `gh pr edit` 済み。

## Running this app (Tauri)

```bash
pnpm tauri dev
```

キャプチャは **`pnpm tauri dev` 実行中**、ウィンドウタイトルが **`src-tauri/tauri.conf.json` の `app.windows[0].title`** と一致するときに行う。
