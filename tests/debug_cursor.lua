-- Debug script to run inside Neovim
-- Open a buffer with "Jer. 29:4-7, 10" and run :luafile tests/debug_cursor.lua

local scripture = require("jwtools.scripture")
local config = require("jwtools.config")

config.set("language", "es")

-- Get current line and cursor position the same way fetch.lua does
local cursor_pos = vim.api.nvim_win_get_cursor(0)[2] + 1
local line = vim.api.nvim_get_current_line()

print("=== Debug Info ===")
print("Line: '" .. line .. "'")
print("Cursor position (1-indexed): " .. cursor_pos)
print("Character at cursor: '" .. line:sub(cursor_pos, cursor_pos) .. "'")

-- Show all character positions
print("\nCharacter positions:")
for i = 1, #line do
    local char = line:sub(i, i)
    local marker = (i == cursor_pos) and " <-- CURSOR" or ""
    print(string.format("  pos %2d = '%s'%s", i, char, marker))
end

-- Try to get reference ID
local ok, result = pcall(scripture.get_reference_id, line, cursor_pos)
if ok then
    print("\nResult: " .. result)
else
    print("\nError: " .. result)
end
