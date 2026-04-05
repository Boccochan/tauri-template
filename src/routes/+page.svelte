<script lang="ts">
  import { openUrl } from "@tauri-apps/plugin-opener";
  import { Button } from "bits-ui";
  import { _ } from "svelte-i18n";

  import { GreetForm } from "$lib/components/greet-form";

  const DOCS_URL = "https://tauri.app/start/";

  async function openDocs() {
    try {
      await openUrl(DOCS_URL);
    } catch {
      window.open(DOCS_URL, "_blank", "noopener,noreferrer");
    }
  }
</script>

<main
  class="container mx-auto flex min-h-screen flex-col items-center justify-start bg-zinc-100 px-4 pt-10 text-zinc-900 dark:bg-zinc-800 dark:text-zinc-100"
>
  <h1 class="mb-8 text-3xl font-semibold">{$_("home.welcome")}</h1>

  <div class="mb-8">
    <Button.Root
      type="button"
      class="cursor-pointer rounded-lg border border-zinc-300 bg-white px-4 py-2 text-sm font-medium text-zinc-900 shadow-sm outline-none transition hover:border-blue-600 hover:bg-zinc-50 active:bg-zinc-200 dark:border-zinc-600 dark:bg-zinc-900/60 dark:text-zinc-100 dark:hover:bg-zinc-800 dark:active:bg-zinc-700"
      onclick={openDocs}
    >
      {$_("home.openDocs")}
    </Button.Root>
  </div>

  <div class="mb-8 flex flex-row flex-wrap items-center justify-center gap-4">
    <a href="https://vite.dev" target="_blank" rel="noreferrer">
      <img
        src="/vite.svg"
        class="h-24 p-6 transition hover:drop-shadow-[0_0_2em_#747bff]"
        alt={$_("home.altVite")}
      />
    </a>
    <a href="https://tauri.app" target="_blank" rel="noreferrer">
      <img
        src="/tauri.svg"
        class="h-24 p-6 transition hover:drop-shadow-[0_0_2em_#24c8db]"
        alt={$_("home.altTauri")}
      />
    </a>
    <a href="https://svelte.dev" target="_blank" rel="noreferrer">
      <img
        src="/svelte.svg"
        class="h-24 p-6 transition hover:drop-shadow-[0_0_2em_#ff3e00]"
        alt={$_("home.altSvelteKit")}
      />
    </a>
  </div>
  <p class="mb-8 text-center text-sm text-zinc-600 dark:text-zinc-400">
    {$_("home.logosHint")}
  </p>

  <GreetForm />
</main>
