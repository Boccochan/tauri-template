import type { Meta, StoryObj } from "@storybook/sveltekit";

import LanguageSwitcher from "./language-switcher.svelte";

const meta = {
  title: "Components/LanguageSwitcher",
  component: LanguageSwitcher,
} satisfies Meta<typeof LanguageSwitcher>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {};
