# Tauri + SvelteKit + TypeScript

A template for building desktop apps with Tauri, SvelteKit, and TypeScript (Vite). Includes Tailwind CSS, Storybook, Vitest, and ESLint.

## Prerequisites

- [Node.js](https://nodejs.org/) (LTS recommended)
- [pnpm](https://pnpm.io/installation)
- [Rust](https://www.rust-lang.org/tools/install) via [rustup](https://rustup.rs/) — **1.88.0 or newer** for this template’s dependency tree (see `rust-toolchain.toml` at the repo root). If `rustc --version` is older, run `rustup update` or `rustup toolchain install 1.88.0`.

## Setup

Install dependencies from the repository root:

```bash
pnpm install
```

## Running locally

### Desktop app (Tauri)

Starts the frontend (Vite) and Rust backend together. Opens a development window.

```bash
pnpm tauri dev
```

### Frontend only (browser)

To preview the UI in the browser only (at `http://localhost:1420`):

```bash
pnpm dev
```

### Storybook (optional)

Runs the component catalog at `http://localhost:6006`.

```bash
pnpm storybook
```

## Build

### Frontend (static assets)

Outputs the production frontend to `build/`. Also used by Tauri’s `beforeBuildCommand`.

```bash
pnpm build
```

Preview the build locally:

```bash
pnpm preview
```

### Desktop app (installer / binary)

Builds the **native desktop app** for the OS you run the command on (Windows: `.exe` / installer; macOS: `.app` / `.dmg`; Linux: `.deb` / `.AppImage`, depending on [Tauri bundle targets](https://v2.tauri.app/reference/config/#bundle)).

1. Ensure [Rust ≥ 1.88.0](https://www.rust-lang.org/tools/install) (`rust-toolchain.toml`) and run from the repo root:

```bash
pnpm tauri build
```

2. `beforeBuildCommand` runs `pnpm build` first (frontend → `build/`), then Cargo **release** compiles `src-tauri/`.

3. Artifacts appear under **`src-tauri/target/release/`** (the app binary) and typically **`src-tauri/target/release/bundle/`** (installers). On Windows, look for NSIS/MSI or the portable exe depending on your [bundle targets](https://v2.tauri.app/distribute/).

To build only the frontend without packaging the shell, use `pnpm build` (see above).

### Storybook (static site) (optional)

```bash
pnpm build-storybook
```

## Other commands

| Command      | Description                                      |
| ------------ | ------------------------------------------------ |
| `pnpm check` | Svelte / TypeScript type check (`svelte-check`) |
| `pnpm lint`  | ESLint                                           |
| `pnpm test`  | Unit tests (Vitest)                              |

## Troubleshooting

### WSL2: `libEGL` / `/dev/dri/renderD128: Permission denied`

The WebView/GPU stack may warn or fail when it cannot access the DRI render node. This is common under **WSL2** when your user is not in the right groups or GPU passthrough is limited.

Try one of the following:

1. **Add your user to the `render` and `video` groups** (then sign out of WSL / open a new session):

   ```bash
   sudo usermod -aG render,video "$USER"
   ```

   If `render` does not exist on your distro, only `video` may be present.

2. **Force software rendering** (slower, but often avoids EGL/DRI issues):

   ```bash
   export LIBGL_ALWAYS_SOFTWARE=1
   pnpm tauri dev
   ```

3. **Run the app from native Windows** (PowerShell or CMD under `C:\Users\...\tauri-template`) instead of the Linux path under `/mnt/c/...` in WSL. GUI tooling often behaves more reliably with the Windows GPU and WebView2 stack.

The `ELIFECYCLE` message from pnpm means **the script exited with a non-zero status** (often the same run as the EGL/WebView failure). Scroll above the `ELIFECYCLE` line for the real Rust or process error. If the window still opens, the warnings may be harmless.

## Recommended IDE setup

[VS Code](https://code.visualstudio.com/) + [Svelte](https://marketplace.visualstudio.com/items?itemName=svelte.svelte-vscode) + [Tauri](https://marketplace.visualstudio.com/items?itemName=tauri-apps.tauri-vscode) + [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer) + [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint).
