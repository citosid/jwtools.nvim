-- Test runner for paste module
-- Run with: lua tests/paste_test.lua

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
		bo = {
			textwidth = 80,
		},
		split = function(str, sep)
			local result = {}
			for part in str:gmatch("([^" .. sep .. "]+)") do
				table.insert(result, part)
			end
			return result
		end,
	}
end

-- Load the module internals for testing
-- We need to extract the local functions, so we'll recreate them here for testing
local function wrap_text(text, width)
	local lines = {}
	local current_line = ""

	for word in text:gmatch("%S+") do
		if current_line == "" then
			current_line = word
		elseif #current_line + 1 + #word <= width then
			current_line = current_line .. " " .. word
		else
			table.insert(lines, current_line)
			current_line = word
		end
	end

	if current_line ~= "" then
		table.insert(lines, current_line)
	end

	return lines
end

local function format_as_blockquote(content, textwidth)
	textwidth = textwidth or 80
	local citation, verse_content = content:match("^(%*%*[^*]+%*%*)%s*(.+)$")

	if not citation or not verse_content then
		local lines = vim.split(content, "\n")
		for i, line in ipairs(lines) do
			lines[i] = "> " .. line
		end
		return table.concat(lines, "\n")
	end

	local wrap_width = textwidth - 2
	local wrapped_lines = wrap_text(verse_content, wrap_width)

	local result = {}
	table.insert(result, "> " .. citation)
	table.insert(result, ">")
	for _, line in ipairs(wrapped_lines) do
		table.insert(result, "> " .. line)
	end

	return table.concat(result, "\n")
end

local function assert_equals(actual, expected, message)
	if actual ~= expected then
		error(string.format(
			"FAIL: %s\n  Expected:\n%s\n  Actual:\n%s",
			message,
			tostring(expected),
			tostring(actual)
		))
	else
		print(string.format("PASS: %s", message))
	end
end

local function assert_table_equals(actual, expected, message)
	if #actual ~= #expected then
		error(string.format(
			"FAIL: %s\n  Expected %d items, got %d",
			message,
			#expected,
			#actual
		))
	end
	for i, v in ipairs(expected) do
		if actual[i] ~= v then
			error(string.format(
				"FAIL: %s\n  At index %d:\n  Expected: '%s'\n  Actual: '%s'",
				message,
				i,
				tostring(v),
				tostring(actual[i])
			))
		end
	end
	print(string.format("PASS: %s", message))
end

print("\n=== Testing wrap_text ===")

-- Basic wrapping
local wrapped = wrap_text("hello world", 20)
assert_table_equals(wrapped, { "hello world" }, "short text fits in one line")

wrapped = wrap_text("hello world foo bar", 10)
assert_table_equals(wrapped, { "hello", "world foo", "bar" }, "text wraps at word boundaries")

-- Edge case: single long word
wrapped = wrap_text("superlongword", 5)
assert_table_equals(wrapped, { "superlongword" }, "long word not broken mid-word")

-- Empty string
wrapped = wrap_text("", 80)
assert_table_equals(wrapped, {}, "empty string returns empty table")

-- Exact fit
wrapped = wrap_text("12345 67890", 11)
assert_table_equals(wrapped, { "12345 67890" }, "exact fit on one line")

wrapped = wrap_text("12345 67890", 10)
assert_table_equals(wrapped, { "12345", "67890" }, "one char over wraps")

print("\n=== Testing format_as_blockquote ===")

-- Simple case
local content = "**Luke 1:1**\n\nThis is the verse content."
local result = format_as_blockquote(content, 80)
local expected = "> **Luke 1:1**\n>\n> This is the verse content."
assert_equals(result, expected, "simple verse formats correctly")

-- With wrapping
content = "**Luke 23:40-43**\n\n40 In response the other rebuked him, saying: \"Do you not fear God at all, now that you have received the same judgment? 41 And we rightly so, for we are getting back what we deserve for the things we did; but this man did nothing wrong.\" 42 Then he said: \"Jesus, remember me when you get into your Kingdom.\" 43 And he said to him: \"Truly I tell you today, you will be with me in Paradise.\""

result = format_as_blockquote(content, 80)

-- Check structure: starts with citation, has empty blockquote line, then wrapped content
local lines = {}
for line in result:gmatch("[^\n]+") do
	table.insert(lines, line)
end

assert_equals(lines[1], "> **Luke 23:40-43**", "first line is citation")
assert_equals(lines[2], ">", "second line is empty blockquote")
assert_equals(lines[3]:sub(1, 2), "> ", "third line starts with blockquote prefix")

-- Verify no line exceeds 80 chars
local max_len = 0
for _, line in ipairs(lines) do
	if #line > max_len then
		max_len = #line
	end
end
if max_len > 80 then
	error(string.format("FAIL: line exceeds 80 chars (max: %d)", max_len))
else
	print(string.format("PASS: all lines <= 80 chars (max: %d)", max_len))
end

-- Verify wrapping happens before prefix (content flows naturally)
-- Each content line should have "> " prefix
for i = 3, #lines do
	if lines[i]:sub(1, 2) ~= "> " then
		error(string.format("FAIL: line %d missing blockquote prefix", i))
	end
end
print("PASS: all content lines have blockquote prefix")

-- Fallback: content without citation format
content = "Just some plain text\nwith multiple lines"
result = format_as_blockquote(content, 80)
expected = "> Just some plain text\n> with multiple lines"
assert_equals(result, expected, "fallback prefixes each line")

print("\n=== Testing textwidth variations ===")

content = "**Gen 1:1**\n\nIn the beginning God created the heavens and the earth."
result = format_as_blockquote(content, 40)
lines = {}
for line in result:gmatch("[^\n]+") do
	table.insert(lines, line)
end

for _, line in ipairs(lines) do
	if #line > 40 then
		error(string.format("FAIL: line exceeds 40 chars: '%s' (%d)", line, #line))
	end
end
print("PASS: respects textwidth=40")

print("\n=== All tests passed! ===")
