<script lang="ts">
  import { invoke } from "@tauri-apps/api/core";
  import { Button } from "bits-ui";
  import { get } from "svelte/store";
  import { _ } from "svelte-i18n";

  let name = $state("");
  let greetMsg = $state("");

  async function greet(event: Event) {
    event.preventDefault();
    try {
      greetMsg = await invoke<string>("greet", { name });
    } catch {
      if (import.meta.env.DEV) {
        greetMsg = get(_)("greet.fallback", { values: { name } });
      }
    }
  }
</script>

<div class="flex flex-col items-center gap-4">
  <form class="flex flex-row flex-wrap items-center justify-center gap-2" onsubmit={greet}>
    <input
      id="greet-input"
      class="rounded-lg border border-zinc-300 bg-white px-3 py-2 text-zinc-900 shadow-sm outline-none transition focus:border-blue-500 dark:border-zinc-600 dark:bg-zinc-900/60 dark:text-zinc-100"
      placeholder={$_("greet.placeholder")}
      bind:value={name}
    />
    <Button.Root
      type="submit"
      class="cursor-pointer rounded-lg border border-transparent bg-white px-4 py-2 font-medium text-zinc-900 shadow-sm outline-none transition hover:border-blue-600 active:bg-zinc-200 dark:bg-zinc-900/60 dark:text-zinc-100 dark:active:bg-zinc-800"
    >
      {$_("greet.button")}
    </Button.Root>
  </form>
  {#if greetMsg}
    <p class="min-h-6 text-zinc-800 dark:text-zinc-200">{greetMsg}</p>
  {/if}
</div>
