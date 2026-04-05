import * as tauri from "@tauri-apps/api/core";
import { render, screen } from "@testing-library/svelte";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";

import GreetForm from "./greet-form.svelte";

vi.mock("@tauri-apps/api/core", () => ({
  invoke: vi.fn(),
}));

describe("greet-form", () => {
  beforeEach(() => {
    vi.mocked(tauri.invoke).mockResolvedValue("Hello, Test!");
  });

  it("submits name and shows greeting", async () => {
    const user = userEvent.setup();
    render(GreetForm);
    await user.type(screen.getByPlaceholderText("Enter a name..."), "Test");
    await user.click(screen.getByRole("button", { name: "Greet" }));
    expect(await screen.findByText("Hello, Test!")).toBeInTheDocument();
  });
});
