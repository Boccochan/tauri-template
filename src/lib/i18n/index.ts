import { addMessages, init } from "svelte-i18n";

import { browser } from "$app/environment";

import en from "./locales/en.json";
import ja from "./locales/ja.json";

const STORAGE_KEY = "locale";

const SUPPORTED = ["en", "ja"] as const;
export type AppLocale = (typeof SUPPORTED)[number];

function isAppLocale(value: string | null | undefined): value is AppLocale {
  return value !== null && value !== undefined && (SUPPORTED as readonly string[]).includes(value);
}

function getInitialLocale(): AppLocale {
  if (browser) {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (isAppLocale(stored)) return stored;
    const lang = navigator.language.split("-")[0];
    if (lang === "ja") return "ja";
  }
  return "en";
}

let initialized = false;

export function setupI18n(): void {
  if (initialized) return;
  initialized = true;

  // Use addMessages (sync) instead of register(async loaders) so the active
  // locale is set in the same tick as init(). Otherwise $_() throws until the
  // async flush completes, which breaks the first render (blank Tauri window).
  addMessages("en", en);
  addMessages("ja", ja);

  init({
    fallbackLocale: "en",
    initialLocale: getInitialLocale(),
  });
}

/** Syncs `<html lang>` and persisted locale when the active locale changes. */
export function applyLocaleSideEffects(code: string | null | undefined): void {
  if (!browser || !code || !isAppLocale(code)) return;
  document.documentElement.lang = code;
  localStorage.setItem(STORAGE_KEY, code);
}
