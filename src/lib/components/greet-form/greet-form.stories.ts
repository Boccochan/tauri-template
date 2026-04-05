import type { Meta, StoryObj } from "@storybook/sveltekit";

import GreetForm from "./greet-form.svelte";

const meta = {
  title: "Components/GreetForm",
  component: GreetForm,
} satisfies Meta<typeof GreetForm>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {};
