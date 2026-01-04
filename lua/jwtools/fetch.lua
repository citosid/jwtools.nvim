local M = {}

local config = require("jwtools.config")
local language_urls = require("jwtools.language_urls")
local scripture = require("jwtools.scripture")
local tooltip = require("jwtools.tooltip")

local REGISTER = "j"
local COOKIE_FILE = vim.fn.expand("~/.config/jwtools/cookies.txt")

--- Refresh cookies by fetching the homepage
---@param callback function|nil Called after cookies are refreshed
local function refresh_cookies(callback)
	local dir = vim.fn.expand("~/.config/jwtools")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end

	vim.fn.jobstart({
		"curl",
		"-s",
		"--compressed",
		"-c", COOKIE_FILE,
		"-H", "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:146.0) Gecko/20100101 Firefox/146.0",
		"-H", "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
		"-H", "Accept-Language: en-US,en;q=0.5",
		"-H", "DNT: 1",
		"-H", "Sec-GPC: 1",
		"-H", "Connection: keep-alive",
		"-H", "Upgrade-Insecure-Requests: 1",
		"-H", "Sec-Fetch-Dest: document",
		"-H", "Sec-Fetch-Mode: navigate",
		"-H", "Sec-Fetch-Site: none",
		"-H", "Sec-Fetch-User: ?1",
		"--max-time", "10",
		"https://www.jw.org/en",
	}, {
		on_exit = function(_, exit_code)
			vim.schedule(function()
				if exit_code == 0 and callback then
					callback()
				elseif exit_code ~= 0 then
					vim.notify("Failed to refresh cookies", vim.log.levels.ERROR)
				end
			end)
		end,
	})
end

--- Check if cookies exist and are recent (less than 1 hour old)
local function cookies_valid()
	if vim.fn.filereadable(COOKIE_FILE) == 0 then
		return false
	end
	local stat = vim.loop.fs_stat(COOKIE_FILE)
	if not stat then
		return false
	end
	local age = os.time() - stat.mtime.sec
	return age < 3600 -- 1 hour
end

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

--- Format verse content from API response
---@param json table The API response
---@param ref_id string The reference ID
---@return table|nil { citation: string, content: string } or nil if not found
local function format_verse_content(json, ref_id)
	if not json.ranges or not json.ranges[ref_id] then
		return nil
	end

	local range = json.ranges[ref_id]
	local citation = range.citation:gsub("&nbsp;", " ")

	local content = ""
	for _, verse in ipairs(range.verses) do
		content = content
			.. verse.content
				:gsub("<[^>]+>", " ")
				:gsub("&nbsp;", " ")
				:gsub("&amp;", "&")
				:gsub("%s+", " ")
				:gsub("^%s+", "")
				:gsub("%s+$", "")
			.. " "
	end
	content = content:gsub("%s+$", "") -- trim trailing space

	return { citation = citation, content = content }
end

--- Store formatted scripture in register
---@param citation string The scripture citation
---@param content string The verse content
local function store_in_register(citation, content)
	local formatted = string.format("**%s**\n\n%s", citation, content)
	vim.fn.setreg(REGISTER, formatted)
end

--- Internal fetch function with options
---@param opts table|nil { show_tooltip: boolean, show_notification: boolean }
local function fetch_scripture_internal(opts)
	opts = opts or {}
	local show_tooltip = opts.show_tooltip ~= false -- default true
	local show_notification = opts.show_notification or false

	local cursor_pos = vim.api.nvim_win_get_cursor(0)[2] + 1
	local line = vim.api.nvim_get_current_line()

	local ok, ref_id = pcall(scripture.get_reference_id, line, cursor_pos)

	if not ok or not ref_id then
		vim.notify("No valid scripture reference found", vim.log.levels.WARN)
		return
	end

	local language = config.get("language")
	local url = language_urls.get_url(language, ref_id)

	if not url then
		vim.notify("No valid language configured", vim.log.levels.ERROR)
		return
	end

	local function do_fetch()
		local spinner = show_spinner()
		local spinner_hidden = false

		local function safe_hide_spinner()
			if not spinner_hidden then
				hide_spinner(spinner)
				spinner_hidden = true
			end
		end

		local curl_args = {
			"curl",
			"-s",
			"--compressed",
			"--max-time", "15",
			"-b", COOKIE_FILE,
			"-H", "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:146.0) Gecko/20100101 Firefox/146.0",
			"-H", "Accept: application/json, text/javascript, */*; q=0.01",
			"-H", "X-Requested-With: XMLHttpRequest",
			"-H", "Referer: https://www.jw.org/en/library/bible/",
			"-H", "Sec-Fetch-Dest: empty",
			"-H", "Sec-Fetch-Mode: cors",
			"-H", "Sec-Fetch-Site: same-origin",
			url,
		}

		vim.fn.jobstart(curl_args, {
			stdout_buffered = true,
			on_stdout = function(_, data)
				vim.schedule(function()
					safe_hide_spinner()

					if not data or #data == 0 or (data[1] == "" and #data == 1) then
						vim.notify("Failed to fetch scripture: empty response", vim.log.levels.ERROR)
						return
					end

					local decode_ok, json = pcall(vim.fn.json_decode, table.concat(data, "\n"))
					if not decode_ok or not json then
						vim.notify("Failed to parse scripture response", vim.log.levels.ERROR)
						return
					end

					if json.ranges == nil then
						vim.notify("Scripture not found", vim.log.levels.WARN)
						return
					end

					local formatted = format_verse_content(json, ref_id)
					if not formatted then
						vim.notify("Scripture not found", vim.log.levels.WARN)
						return
					end

					store_in_register(formatted.citation, formatted.content)

					if show_tooltip then
						tooltip.show_verse_tooltip(ref_id, json)
					end

					if show_notification then
						vim.notify(formatted.citation .. " yanked")
					end
				end)
			end,
			on_stderr = function(_, data)
				vim.schedule(function()
					safe_hide_spinner()
					if data and data[1] ~= "" then
						vim.notify("Failed to fetch scripture: network error", vim.log.levels.ERROR)
					end
				end)
			end,
			on_exit = function(_, exit_code)
				vim.schedule(function()
					safe_hide_spinner()
					if exit_code ~= 0 then
						vim.notify("Failed to fetch scripture: curl error", vim.log.levels.ERROR)
					end
				end)
			end,
		})
	end

	-- Refresh cookies if needed, then fetch
	if cookies_valid() then
		do_fetch()
	else
		vim.notify("Refreshing cookies...", vim.log.levels.INFO)
		refresh_cookies(do_fetch)
	end
end

--- Fetch scripture: show tooltip AND yank to register
function M.fetch_scripture()
	fetch_scripture_internal({ show_tooltip = true })
end

--- Yank scripture: yank to register only, show notification
function M.yank_scripture()
	fetch_scripture_internal({ show_tooltip = false, show_notification = true })
end

return M
