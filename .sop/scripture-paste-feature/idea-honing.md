# Requirements Clarification

This document captures the Q&A process to refine the scripture paste feature requirements.

---

## Q1: Should the scripture text include the citation/title?

Currently, when scripture is fetched, it includes both:
- A **citation/title** (e.g., "Genesis 1:1" or "Juan 3:16")
- The **verse content** itself

When copying to the register for pasting, should the pasted text include:
- A) Just the verse content
- B) The citation/title followed by the verse content
- C) Configurable (user can choose)

**Answer:** The pasted text should include both, in the format:
```
**citation**

verse content
```

For example:
```
**Genesis 1:1**

In the beginning, God created heaven and earth.
```

---

## Q2: Which Vim register should the scripture be stored in?

Options:
- A) The unnamed register (`"`) - overwrites normal yank/delete content
- B) A named register (e.g., `"j` for jwtools) - preserves normal clipboard
- C) The system clipboard (`+` or `*`)
- D) A plugin-internal variable (not a Vim register at all)

**Answer:** B - A named register (e.g., `"j` for jwtools) to preserve normal clipboard functionality.

---

## Q3: Should the `<leader>jp` keybinding be set up by the plugin automatically, or should users configure it themselves?

Options:
- A) Plugin sets it up automatically during `setup()`
- B) Plugin provides a function, user maps it themselves
- C) Plugin sets a default but allows override via config

**Answer:** C - Plugin sets opinionated defaults but allows override via config.

Default keymaps:
- `<leader>jf` - Fetch scripture (`JWToolsFetchScripture`)
- `<leader>jp` - Paste scripture from register

Users can override these via config if desired.

---

## Q4: How should users disable or override the default keymaps?

Options:
- A) Pass `keymaps = false` to disable all, or `keymaps = { fetch = "<leader>sf", paste = "<leader>sp" }` to customize
- B) Pass individual options like `fetch_keymap = false` or `paste_keymap = "<leader>sp"`
- C) Other approach?

**Answer:** Simple boolean: `keymaps = false` disables all default keymaps. Users then configure their own mappings manually if needed.

---

## Q5: Should the tooltip still be shown when fetching scripture, or should it be replaced by a different feedback mechanism?

Currently, fetching scripture shows a floating tooltip with the verse content. With the new paste feature:
- A) Keep the tooltip as-is (tooltip shown + text copied to register)
- B) Replace tooltip with a brief notification (e.g., "Scripture copied to register j")
- C) Make it configurable (show tooltip or just notify)

**Answer:** A - Keep the tooltip as-is. Both the tooltip is shown AND the text is copied to the register.

**Additional requirement:** Add a separate command/keymap for yank-only:
- `<leader>jf` - Fetch scripture: shows tooltip AND yanks to register
- `<leader>jy` - Yank scripture: yanks to register only (no tooltip)

---

## Q6: How should the paste command behave - insert at cursor, or replace current line, or something else?

Options:
- A) Insert text at cursor position (like `p` in normal mode)
- B) Insert text below current line (like `o` then paste)
- C) Replace visual selection if in visual mode, otherwise insert at cursor

**Answer:** C - Replace visual selection if in visual mode, otherwise insert at cursor position (A implied).

---

## Q7: For `<leader>jy` (yank-only), should there be any feedback to confirm the yank succeeded?

Options:
- A) No feedback (silent)
- B) Brief notification message (e.g., "Genesis 1:1 yanked")
- C) Echo the citation in the command line

**Answer:** B - Brief notification message (e.g., "Genesis 1:1 yanked")

---

## Q8: What should happen if the user tries to paste (`<leader>jp`) but no scripture has been fetched yet (register is empty)?

Options:
- A) Do nothing (silent)
- B) Show an error/warning message (e.g., "No scripture in register. Use <leader>jf or <leader>jy first")
- C) Attempt to fetch scripture from reference under cursor and then paste

**Answer:** B - Show an error/warning message (e.g., "No scripture in register. Use <leader>jf or <leader>jy first")

---

## Q9: Should the `setup()` function accept configuration options, or is `keymaps = false` the only option needed for now?

Current `setup()` takes no arguments. Should we expand it to accept a config table?

Example:
```lua
require("jwtools").setup({
  keymaps = true,  -- default, or false to disable
  language = "en", -- could also move language config here
})
```

Options:
- A) Only add `keymaps` option for now
- B) Add both `keymaps` and `language` options
- C) Full config table with more options (specify which)

**Answer:** B - Add both `keymaps` and `language` options to the setup config table.

---

## Q10: What should the default language be if not specified in setup?

Currently language is set via `JWToolsSetJWLanguage` command. With the new config:
- A) Default to "en" (English)
- B) Default to "es" (Spanish)
- C) No default - require user to specify
- D) Other (specify)

**Answer:** B - Default to "es" (Spanish)

---

## Q11: Should the `JWToolsSetJWLanguage` command still be available for runtime language changes, or should language only be set via setup?

Options:
- A) Keep the command for runtime changes
- B) Remove the command, language only set via setup
- C) Keep command but also add a Lua API function (e.g., `require("jwtools").set_language("en")`)

**Answer:** B - Remove the command, but add a keymap `<leader>jl` that prompts the user to select from available languages via `vim.ui.select` or similar.

Updated default keymaps:
- `<leader>jf` - Fetch scripture (show tooltip + yank)
- `<leader>jy` - Yank scripture (yank only, no tooltip)
- `<leader>jp` - Paste scripture from register
- `<leader>jl` - Select language (interactive prompt)

---

## Q12: Are there any edge cases or error scenarios we should handle?

For example:
- Network failure during fetch
- Invalid scripture reference
- Multiple verses (range like "Genesis 1:1-3")

Are these already handled, or should we address any specific cases?

**Answer:** 
- Network failure: Handle with appropriate error message
- Invalid/not found scripture reference: Handle with appropriate error message
- Multiple verses range (e.g., "Genesis 1:1-3"): Known regression from previous refactor. Fix this after the main feature is complete and working.

---

## Q13: Do you feel the requirements clarification is complete, or are there other aspects you'd like to discuss before moving forward?

Current summary of the feature:
1. **Config options**: `setup({ keymaps = true, language = "es" })`
2. **Default keymaps** (can be disabled with `keymaps = false`):
   - `<leader>jf` - Fetch: show tooltip + yank to register `j`
   - `<leader>jy` - Yank only: yank to register `j`, show notification
   - `<leader>jp` - Paste: insert from register `j` (replace selection in visual mode)
   - `<leader>jl` - Language select: interactive prompt
3. **Paste format**: `**Citation**\n\nverse content`
4. **Error handling**: Network failures, invalid references, empty register on paste
5. **Future fix**: Multiple verse ranges (regression)

**Answer:** Requirements clarification complete. Ready to proceed.

