# AGENTS.md — Guide for AI agents

This repository is a **Tauri 2 + SvelteKit + TypeScript + Tailwind CSS v4 + Storybook + Vitest** desktop app template. Read this file and `.cursor/rules/` before making changes.

## Working principles

- Change **only what the task asks for**. Avoid unrelated refactors, bulk deletions, or unsolicited documentation.
- Match existing **naming, imports, and layout**. When unsure, copy a nearby file and adapt it.
- Use **LF line endings** (see `.editorconfig`). Verify line endings in the editor before committing.
- Frontend details live in **`.cursor/rules/frontend.mdc`** (Svelte/TS/CSS under `src`). Storybook config: **`.cursor/rules/storybook.mdc`**.

## Repository layout

| Area | Path | Notes |
|------|------|--------|
| UI & routes | `src/routes/` | SvelteKit. `+layout.ts` sets `ssr = false` (SPA). |
| Shared UI | `src/lib/components/<kebab-name>/` | See “Component set” below. |
| Global CSS | `src/app.css` | `@import "tailwindcss"`. |
| Test setup | `src/test/setup.ts` | Vitest + jest-dom. |
| Build | `vite.config.ts` | Tauri dev port 1420; do not break Vitest `resolve.conditions`. |
| Rust / Tauri | `src-tauri/` | Commands, capabilities, windows. Not ESLint-scoped. |
| Storybook | `.storybook/` | `main.ts` / `preview.ts`. |

## Frontend conventions (summary)

- **Svelte 5**: Runes (`$state`, `$props`, etc.). Do not introduce legacy Svelte 4 patterns in new code.
- **Naming**: **kebab-case** for directories and files (no PascalCase filenames).
- **Imports**: `eslint-plugin-simple-import-sort`. Write imports so **`pnpm lint:fix`** can reorder them cleanly.
- **Function length**: **≤ 100 lines** (`max-lines-per-function` in `eslint.config.js`). Split when it grows beyond that.
- **Styling**: Prefer Tailwind. Avoid huge `<style>` blocks inside components.

### Standard files per component

Under `src/lib/components/<name>/`, keep these together (prefer this shape for new UI):

1. `index.ts` — public API (`export { default as … } from "./….svelte"`).
2. `<name>.svelte` — implementation.
3. `<name>.stories.ts` — Storybook (`Meta` / `StoryObj`).
4. `<name>.spec.ts` — Vitest + `@testing-library/svelte`.

Consumers import from **`$lib/components/<dir>`**.

### Tauri integration

- Call Rust via `@tauri-apps/api` (e.g. `invoke`). In tests, make **`vi.mock`** practical for swapping implementations.
- Storybook or browser-only runs may lack Tauri. Follow existing **DEV fallbacks** or mocking patterns in components.

## Rust (`src-tauri`)

- Keep package name and app identifier aligned with `Cargo.toml` and `tauri.conf.json`.
- Match frontend `invoke` names to Rust command names.
- After changes, verify with **`cargo build`** or **`pnpm tauri build`** (watch Rust toolchain version requirements).

## Commands to run (as appropriate)

| Command | Purpose |
|---------|---------|
| `pnpm check` | Svelte / TypeScript typecheck |
| `pnpm lint` | ESLint |
| `pnpm test` | Unit tests (Vitest `unit` project) |
| `pnpm build` | Frontend production build |
| `pnpm tauri dev` | Desktop smoke test (when needed) |

After frontend edits, aim to pass **`pnpm check`** and **`pnpm lint`**. If you add or change tests, run **`pnpm test`** too.

## Template-specific notes

- When testing Svelte with **Vitest**, removing or weakening **`resolve.conditions` (`browser` when `VITEST`)** in `vite.config.ts` can break `mount`. If you change it, read up on [Vitest](https://vitest.dev/) and Svelte resolution.
- Storybook’s Vitest integration (`storybook` project) depends on Playwright. For CI, **`pnpm test`** (unit only) is often enough.
