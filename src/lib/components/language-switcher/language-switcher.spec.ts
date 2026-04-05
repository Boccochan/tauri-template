import { render, screen } from "@testing-library/svelte";
import { describe, expect, it } from "vitest";

import LanguageSwitcher from "./language-switcher.svelte";

describe("language-switcher", () => {
  it("renders locale select trigger", () => {
    render(LanguageSwitcher);
    expect(
      screen.getByRole("button", { name: "Language" }),
    ).toBeInTheDocument();
  });
});
