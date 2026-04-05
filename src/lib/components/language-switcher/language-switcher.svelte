<script lang="ts">
  import { Select } from "bits-ui";
  import { _, locale } from "svelte-i18n";

  const options = [
    { code: "en", label: "English" },
    { code: "ja", label: "日本語" },
  ] as const;

  const items = options.map((o) => ({ value: o.code, label: o.label }));

  const selectedLabel = $derived(
    options.find((o) => o.code === $locale)?.label ?? options[0].label,
  );
</script>

<div
  class="inline-flex rounded-lg border border-zinc-300 bg-white px-2 py-1 text-sm text-zinc-900 shadow-sm dark:border-zinc-600 dark:bg-zinc-900/60 dark:text-zinc-100"
>
  <Select.Root
    type="single"
    value={$locale ?? undefined}
    {items}
    onValueChange={(v) => {
      if (v !== undefined) locale.set(v);
    }}
  >
    <Select.Trigger
      class="inline-flex cursor-pointer items-center gap-1 bg-transparent outline-none select-none"
      aria-label={$_("language.label")}
    >
      <span>{selectedLabel}</span>
      <svg
        class="size-4 shrink-0 opacity-70"
        aria-hidden="true"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M19 9l-7 7-7-7"
        />
      </svg>
    </Select.Trigger>
    <Select.Portal>
      <Select.Content
        class="data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 outline-hidden z-50 max-h-[min(24rem,var(--bits-select-content-available-height))] min-w-[var(--bits-select-anchor-width)] select-none rounded-lg border border-zinc-200 bg-white py-1 text-zinc-900 shadow-lg data-[side=bottom]:slide-in-from-top-2 data-[side=top]:slide-in-from-bottom-2 dark:border-zinc-600 dark:bg-zinc-900 dark:text-zinc-100"
        sideOffset={4}
      >
        <Select.Viewport class="p-1">
          {#each options as opt (opt.code)}
            <Select.Item
              class="data-highlighted:bg-zinc-100 dark:data-highlighted:bg-zinc-800 outline-hidden flex cursor-pointer items-center rounded px-2 py-1.5 text-sm data-disabled:opacity-50"
              value={opt.code}
              label={opt.label}
            >
              {#snippet children({ selected })}
                <span class="flex-1">{opt.label}</span>
                {#if selected}
                  <span class="text-xs text-blue-600 dark:text-blue-400" aria-hidden="true">✓</span>
                {/if}
              {/snippet}
            </Select.Item>
          {/each}
        </Select.Viewport>
      </Select.Content>
    </Select.Portal>
  </Select.Root>
</div>
