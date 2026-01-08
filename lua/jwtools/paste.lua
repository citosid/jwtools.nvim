local M = {}

local REGISTER = "j"

--- Wrap text to specified width, preserving words
---@param text string The text to wrap
---@param width number Maximum line width
---@return string[] Array of wrapped lines
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

--- Format scripture content as markdown blockquote
---@param content string Raw scripture content from register
---@return string Formatted blockquote
local function format_as_blockquote(content)
	-- Parse citation and verse content
	-- Format in register: **Citation**\n\nContent
	local citation, verse_content = content:match("^(%*%*[^*]+%*%*)%s*(.+)$")

	if not citation or not verse_content then
		-- Fallback: just prefix each line with >
		local lines = vim.split(content, "\n")
		for i, line in ipairs(lines) do
			lines[i] = "> " .. line
		end
		return table.concat(lines, "\n")
	end

	-- Get wrap width (textwidth or default 80, minus 2 for "> " prefix)
	local textwidth = vim.bo.textwidth
	if textwidth == 0 then
		textwidth = 80
	end
	local wrap_width = textwidth - 2

	-- Wrap the verse content first, then add blockquote prefix
	local wrapped_lines = wrap_text(verse_content, wrap_width)

	-- Build the blockquote
	local result = {}
	table.insert(result, "> " .. citation)
	table.insert(result, ">")
	for _, line in ipairs(wrapped_lines) do
		table.insert(result, "> " .. line)
	end

	return table.concat(result, "\n")
end

--- Paste scripture from register j at cursor position
--- In visual mode, replaces the selection
function M.paste_scripture()
	local content = vim.fn.getreg(REGISTER)

	if content == "" then
		vim.notify(
			"No scripture in register. Use <leader>jf or <leader>jy first.",
			vim.log.levels.WARN
		)
		return
	end

	local formatted = format_as_blockquote(content)
	local mode = vim.fn.mode()

	if mode == "v" or mode == "V" or mode == "\22" then
		-- Visual mode: delete selection first, then insert
		vim.cmd('normal! "_d')
		vim.api.nvim_put(vim.split(formatted, "\n"), "c", true, true)
	else
		-- Normal mode: insert at cursor
		vim.api.nvim_put(vim.split(formatted, "\n"), "c", true, true)
	end
end

return M
