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
end

return M
