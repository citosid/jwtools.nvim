local M = {}

local function show_verse_tooltip(ref_id, json)
	local content = ""
	local title = json.ranges[ref_id].citation:gsub("&nbsp;", " ")

	for _, verse in ipairs(json.ranges[ref_id].verses) do
		content = content
			.. verse
				.content
				:gsub("<[^>]+>", " ")
				:gsub("&nbsp;", " ")
				:gsub("&amp;", "&")
				-- :gsub("\r", " ")
				:gsub("%s+", " ")
			.. "\n"
	end

	local lines = vim.split(content, "\n")

	-- Compute longest line and constrain floating window width so wrap actually applies
	local longest = 0
	for _, l in ipairs(lines) do
		longest = math.max(longest, #l)
	end
	local max_width = math.min(80, math.floor(vim.o.columns * 0.45))
	local width = math.max(20, math.min(max_width, longest))

	local opts = {
		border = "rounded",
		focusable = true,
		width = width,
		title = title,
	}

	-- open_floating_preview returns (bufnr, winid)
	local bufnr, winid = vim.lsp.util.open_floating_preview(lines, "plaintext", opts)
	if bufnr and winid then
		-- Let the buffer/window handle wrapping instead of manual truncation
		vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
		vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
		vim.api.nvim_win_set_option(winid, "wrap", true)
		vim.api.nvim_win_set_option(winid, "linebreak", true)
		vim.api.nvim_win_set_option(winid, "breakindent", true)
	end
end

M.show_verse_tooltip = show_verse_tooltip

return M
