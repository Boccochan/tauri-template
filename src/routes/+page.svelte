<script lang="ts">
  import { _ } from "svelte-i18n";

  import { GreetForm } from "$lib/components/greet-form";
</script>

<main
  class="container mx-auto flex min-h-screen flex-col items-center justify-start bg-zinc-100 px-4 pt-10 text-zinc-900 dark:bg-zinc-800 dark:text-zinc-100"
>
  <h1 class="mb-8 text-3xl font-semibold">{$_("home.welcome")}</h1>

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
