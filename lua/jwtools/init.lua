local M = {}

setmetatable(M, {
	__index = function(t, k)
		---@diagnostic disable-next-line: no-unknown
		t[k] = require("jwtools." .. k)
		return rawget(t, k)
	end,
})

M.didsetup = false

--- Available languages for selection
local available_languages = { "es", "en" }

--- Register default keymaps
local function register_keymaps()
	vim.keymap.set("n", "<leader>jf", function()
		require("jwtools.fetch").fetch_scripture()
	end, { desc = "JWTools: Fetch scripture (tooltip + yank)" })

	vim.keymap.set("n", "<leader>jy", function()
		require("jwtools.fetch").yank_scripture()
	end, { desc = "JWTools: Yank scripture" })

	vim.keymap.set({ "n", "v" }, "<leader>jp", function()
		require("jwtools.paste").paste_scripture()
	end, { desc = "JWTools: Paste scripture" })

	vim.keymap.set("n", "<leader>jl", function()
		require("jwtools").select_language()
	end, { desc = "JWTools: Select language" })
end

--- Interactive language selection
function M.select_language()
	vim.ui.select(available_languages, {
		prompt = "Select JWTools language:",
	}, function(choice)
		if choice then
			M.config.set("language", choice)
			vim.notify("JWTools language set to: " .. choice)
		end
	end)
end

--- Setup JWTools with optional configuration
---@param opts table|nil Configuration options { keymaps: boolean, language: string }
function M.setup(opts)
	if M.didsetup then
		return vim.notify("JWTools already setup!", vim.log.levels.WARN)
	end

	M.didsetup = true

	-- Apply user configuration
	M.config.setup(opts)

	-- Register keymaps if enabled (default: true)
	if M.config.get("keymaps") then
		register_keymaps()
	end

	-- Keep command for backward compatibility
	vim.api.nvim_create_user_command("JWToolsFetchScripture", M.fetch.fetch_scripture, {})
end

return M
