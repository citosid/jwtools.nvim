local M = {}
local scripture = require("jwtools.scripture")
local tooltip = require("jwtools.tooltip")

local function fetch_scripture()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)[2] + 1
	local line = vim.api.nvim_get_current_line()

	local ref_id = scripture.get_reference_id(line, cursor_pos)

	if not ref_id then
		print("No valid scripture reference found")
		return
	end

	local url = string.format("https://www.jw.org/es/biblioteca/biblia/biblia-estudio/libros/json/data/%s", ref_id)

	vim.fn.jobstart({ "curl", "-s", url }, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			local json = vim.fn.json_decode(table.concat(data, "\n"))
			if json.ranges == nil then
				print("Scripture not found")
				return
			end

			tooltip.show_verse_tooltip(ref_id, json)
		end,
	})
end

M.fetch_scripture = fetch_scripture

return M
