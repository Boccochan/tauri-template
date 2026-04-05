<script lang="ts">
  import "../app.css";

  import { _, locale } from "svelte-i18n";

  import { browser } from "$app/environment";
  import { LanguageSwitcher } from "$lib/components/language-switcher";
  import { applyLocaleSideEffects, setupI18n } from "$lib/i18n";

  setupI18n();

  let { children } = $props();

  $effect(() => {
    if (!browser) return;
    applyLocaleSideEffects($locale);
  });
</script>

<svelte:head>
  <title>{$_("meta.title")}</title>
</svelte:head>

<div class="relative min-h-screen">
  <div class="pointer-events-none absolute right-4 top-4 z-10 flex justify-end">
    <div class="pointer-events-auto">
      <LanguageSwitcher />
    </div>
  </div>
  {@render children()}
</div>
