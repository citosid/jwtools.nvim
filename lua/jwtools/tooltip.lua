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
	local wrapped_lines = {}

	for _, line in ipairs(lines) do
		local words = vim.split(line, " ")
		local current_line = ""

		for _, word in ipairs(words) do
			if #current_line + #word + 1 > 60 then
				table.insert(wrapped_lines, current_line)
				current_line = word
			else
				if current_line ~= "" then
					current_line = current_line .. " " .. word
				else
					current_line = word
				end
			end
		end

		if #current_line > 0 then
			table.insert(wrapped_lines, current_line)
		end
	end

	local height = math.min(#wrapped_lines, 20)
	local width = 0
	for _, line in ipairs(wrapped_lines) do
		width = math.max(width, #line)
	end

	local opts = {
		border = "rounded",
		focusable = true,
		height = height,
		title = title,
	}

	vim.lsp.util.open_floating_preview(wrapped_lines, "plaintext", opts)
end

M.show_verse_tooltip = show_verse_tooltip

return M
