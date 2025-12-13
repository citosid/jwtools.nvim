-- Test runner for scripture module
-- Run with: lua tests/scripture_test.lua
-- Or in Neovim: :luafile tests/scripture_test.lua

package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

-- Mock vim global for testing outside of Neovim
if not vim then
	_G.vim = {
		notify = function() end,
		log = {
			levels = {
				ERROR = 1,
				WARN = 2,
				INFO = 3,
			},
		},
	}
end

local scripture = require("jwtools.scripture")
local config = require("jwtools.config")

local function assert_equals(actual, expected, message)
	if actual ~= expected then
		error(string.format("FAIL: %s\n  Expected: %s\n  Actual: %s", message, tostring(expected), tostring(actual)))
	else
		print(string.format("PASS: %s", message))
	end
end

-- Non-breaking space
local NBSP = string.char(0xC2, 0xA0)

-- Set language to Spanish for tests
config.set("language", "es")

print("\n=== Testing single verse ===")
local line1 = "Gén. 1:1"
assert_equals(scripture.get_reference_id(line1, 8), "1001001", "Gén. 1:1 cursor on verse")
assert_equals(scripture.get_reference_id(line1, 1), "1001001", "Gén. 1:1 cursor on book (default)")

print("\n=== Testing verse range ===")
local line2 = "Gén. 1:1-3"
assert_equals(scripture.get_reference_id(line2, 8), "1001001-1001003", "Gén. 1:1-3 cursor on range")
assert_equals(scripture.get_reference_id(line2, 1), "1001001-1001003", "Gén. 1:1-3 cursor on book")

print("\n=== Testing consecutive verses (should merge) ===")
local line3 = "Jer. 20:4, 5"
assert_equals(scripture.get_reference_id(line3, 9), "24020004-24020005", "Jer. 20:4, 5 merged")

print("\n=== Testing multiple verse groups with regular space ===")
-- "Jer. 29:4-7, 10" with regular space
--  123456789012345
local line4 = "Jer. 29:4-7, 10"
print("Line (regular space): '" .. line4 .. "' (length: " .. #line4 .. ")")
assert_equals(scripture.get_reference_id(line4, 9), "24029004-24029007", "regular space: cursor on 4 -> 4-7")
assert_equals(scripture.get_reference_id(line4, 14), "24029010", "regular space: cursor on 10 -> 10")

print("\n=== Testing multiple verse groups with non-breaking space ===")
-- "Jer. 29:4-7," + NBSP + "10" 
-- The NBSP takes 2 bytes, so positions shift
local line5 = "Jer. 29:4-7," .. NBSP .. "10"
print("Line (nbsp): length = " .. #line5)
for i = 1, #line5 do
	print(string.format("  pos %2d = byte 0x%02X '%s'", i, line5:byte(i), 
		(line5:byte(i) >= 32 and line5:byte(i) < 127) and line5:sub(i,i) or "?"))
end

-- With NBSP (2 bytes), "10" starts at position 15 (not 14)
-- pos 13 = 0xC2 (first byte of NBSP)
-- pos 14 = 0xA0 (second byte of NBSP)  
-- pos 15 = '1'
-- pos 16 = '0'
assert_equals(scripture.get_reference_id(line5, 9), "24029004-24029007", "nbsp: cursor on 4 -> 4-7")
assert_equals(scripture.get_reference_id(line5, 15), "24029010", "nbsp: cursor on 1 of 10 -> 10")
assert_equals(scripture.get_reference_id(line5, 16), "24029010", "nbsp: cursor on 0 of 10 -> 10")
assert_equals(scripture.get_reference_id(line5, 1), "24029004-24029007", "nbsp: cursor on book -> 4-7 (default)")

print("\n=== Testing three verse groups ===")
local line6 = "Jer. 29:4-7, 10, 16"
assert_equals(scripture.get_reference_id(line6, 9), "24029004-24029007", "3 groups: cursor on 4")
assert_equals(scripture.get_reference_id(line6, 14), "24029010", "3 groups: cursor on 10")
assert_equals(scripture.get_reference_id(line6, 18), "24029016", "3 groups: cursor on 16")

print("\n=== Testing English ===")
config.set("language", "en")
assert_equals(scripture.get_reference_id("Gen. 1:1", 8), "1001001", "Gen. 1:1 (English)")
assert_equals(scripture.get_reference_id("Gen. 1:1-3", 8), "1001001-1001003", "Gen. 1:1-3 (English)")

print("\n=== All tests passed! ===")
