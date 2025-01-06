local M = {}

local config = require("jwtools.config")
local language_urls = require("jwtools.language_urls")
local scripture = require("jwtools.scripture")
local tooltip = require("jwtools.tooltip")

local function show_spinner()
	local spinner_chars = { "⠋", "⠙", "⠹", "⠼", "⠽", "⠷" }
	local spinner_idx = 1
	local timer = vim.loop.new_timer()
	local bufnr = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_win_get_cursor(0)[1] - 1
	local col = vim.api.nvim_win_get_cursor(0)[2]

	local ns_id = vim.api.nvim_create_namespace("jwtools_spinner")
	local extmark = vim.api.nvim_buf_set_extmark(bufnr, ns_id, line, col, {
		virt_text = { { spinner_chars[spinner_idx], "Comment" } },
		virt_text_pos = "overlay",
	})

	-- Rotate the spinner
	timer:start(
		0,
		100,
		vim.schedule_wrap(function()
			-- Update the same extmark with a new spinner character
			vim.api.nvim_buf_set_extmark(bufnr, ns_id, line, col, {
				id = extmark,
				virt_text = { { spinner_chars[spinner_idx], "Comment" } },
				virt_text_pos = "overlay",
			})
			spinner_idx = (spinner_idx % #spinner_chars) + 1
		end)
	)

	return { timer = timer, extmark = extmark, ns_id = ns_id }
end

local function hide_spinner(spinner)
	spinner.timer:stop()
	spinner.timer:close()
	vim.api.nvim_buf_del_extmark(vim.api.nvim_get_current_buf(), spinner.ns_id, spinner.extmark)
end

local function fetch_scripture()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)[2] + 1
	local line = vim.api.nvim_get_current_line()

	local ref_id = scripture.get_reference_id(line, cursor_pos)

	if not ref_id then
		print("No valid scripture reference found")
		return
	end

	local language = config.get("language")
	local url = language_urls.get_url(language, ref_id)

	if not url then
		print("No valid language")
		return
	end

	local spinner = show_spinner()

	vim.fn.jobstart({
		"curl",
		"--user-agent",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
		"-s",
		url,
	}, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			local json = vim.fn.json_decode(table.concat(data, "\n"))
			hide_spinner(spinner)
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
