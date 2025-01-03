local M = {}

setmetatable(M, {
	__index = function(t, k)
		---@diagnostic disable-next-line: no-unknown
		t[k] = require("jwtools." .. k)
		return rawget(t, k)
	end,
})

M.didsetup = false

function M.setup()
	if M.didsetup then
		return vim.notify("JWTools already setup!")
	end

	M.didsetup = true

	vim.api.nvim_create_user_command("JWToolsFetchScripture", M.fetch.fetch_scripture, {})
	vim.api.nvim_create_user_command("JWToolsSetJWLanguage", function(opts)
		M.config.set("language", opts.args)
		vim.notify("JWTools language set to: " .. opts.args)
	end, {
		nargs = 1,
		complete = function()
			return { "es", "en" }
		end,
	})
end

return M
