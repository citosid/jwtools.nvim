# Implementation Plan: Scripture Paste Feature

## Checklist

- [x] Step 1: Update config.lua with setup function
- [x] Step 2: Create paste.lua module
- [x] Step 3: Refactor fetch.lua with register storage
- [x] Step 4: Update init.lua with setup options and keymaps
- [x] Step 5: Manual testing and verification
- [x] Step 6: Clean up and remove deprecated code

---

## Step 1: Update config.lua with setup function

**Objective**: Add a `setup()` function to merge user-provided options with defaults.

**Implementation guidance**:
- Add `keymaps = true` to default settings
- Create `Config.setup(opts)` function that merges opts into settings
- Validate that only known keys are accepted

**Test requirements**:
- Calling `setup({})` preserves defaults
- Calling `setup({ language = "en" })` updates language
- Calling `setup({ keymaps = false })` disables keymaps

**Integration**: Standalone change, no dependencies on other steps.

**Demo**: Load plugin, call `require("jwtools.config").setup({ language = "en" })`, verify `get("language")` returns `"en"`.

---

## Step 2: Create paste.lua module

**Objective**: Create new module to handle pasting scripture from register `j`.

**Implementation guidance**:
- Create `lua/jwtools/paste.lua`
- Implement `paste_scripture()` function
- Check if register is empty, show warning if so
- Handle normal mode: insert at cursor with `vim.api.nvim_put`
- Handle visual mode: delete selection first, then insert

**Test requirements**:
- Empty register shows warning message
- Normal mode inserts text at cursor position
- Visual mode replaces selection

**Integration**: Standalone module, will be wired in Step 4.

**Demo**: Manually set register `j` with test content (`vim.fn.setreg("j", "test")`), call `require("jwtools.paste").paste_scripture()`, verify text inserted.

---

## Step 3: Refactor fetch.lua with register storage

**Objective**: Modify fetch to store formatted scripture in register and support yank-only mode.

**Implementation guidance**:
- Add `format_verse_content(json, ref_id)` helper that returns `{ citation, content }`
- Add `store_in_register(citation, content)` helper using `vim.fn.setreg("j", ...)`
- Refactor `fetch_scripture` to use internal `fetch_scripture_internal(opts)` 
- Add `yank_scripture()` function that calls internal with `show_tooltip = false, show_notification = true`
- Improve error handling for network failures in `on_stderr`

**Test requirements**:
- After `fetch_scripture()`, register `j` contains formatted text
- After `yank_scripture()`, register `j` contains formatted text and notification shown
- Format is `**Citation**\n\n{content}`

**Integration**: Depends on existing tooltip.lua. Will be wired to keymaps in Step 4.

**Demo**: Place cursor on scripture reference, call `require("jwtools.fetch").yank_scripture()`, verify notification appears and `vim.fn.getreg("j")` contains formatted scripture.

---

## Step 4: Update init.lua with setup options and keymaps

**Objective**: Wire everything together - setup accepts options, registers keymaps, adds language selector.

**Implementation guidance**:
- Modify `setup(opts)` to accept options table and call `config.setup(opts)`
- Add `register_keymaps()` function with all four keymaps
- Conditionally call `register_keymaps()` based on `config.get("keymaps")`
- Add `select_language()` function using `vim.ui.select`
- Remove `JWToolsSetJWLanguage` command
- Keep `JWToolsFetchScripture` command for backward compatibility (optional)

**Test requirements**:
- `setup()` with no args uses defaults and registers keymaps
- `setup({ keymaps = false })` does not register keymaps
- `setup({ language = "en" })` sets language to English
- `<leader>jl` shows language picker

**Integration**: Depends on Steps 1-3 being complete.

**Demo**: 
1. Call `require("jwtools").setup()` 
2. Press `<leader>jf` on scripture reference - tooltip + register populated
3. Press `<leader>jp` - scripture pasted
4. Press `<leader>jl` - language picker shown

---

## Step 5: Manual testing and verification

**Objective**: Verify all functionality works end-to-end.

**Test scenarios**:
1. `<leader>jf` on "Juan 3:16" → tooltip shown, register populated with `**Juan 3:16**\n\n{verse}`
2. `<leader>jy` on "Genesis 1:1" (with `language = "en"`) → notification "Genesis 1:1 yanked", register populated
3. `<leader>jp` in normal mode → text inserted at cursor
4. `<leader>jp` in visual mode → selection replaced with scripture
5. `<leader>jp` with empty register → warning shown
6. `<leader>jl` → picker shows "es", "en", selection updates config
7. `setup({ keymaps = false })` → no keymaps registered
8. Network error (disconnect wifi) → error notification shown
9. Invalid reference → "No valid scripture reference found"

**Integration**: Full integration test of all steps.

**Demo**: Complete walkthrough of typical user workflow.

---

## Step 6: Clean up and remove deprecated code

**Objective**: Remove deprecated `JWToolsSetJWLanguage` command and any dead code.

**Implementation guidance**:
- Remove `JWToolsSetJWLanguage` command from init.lua
- Review for any unused code paths
- Ensure error messages are consistent

**Test requirements**:
- Plugin loads without errors
- All keymaps work as expected

**Integration**: Final cleanup after all features verified.

**Demo**: Fresh Neovim session, load plugin, verify no errors and all features work.
