local M = {}

M.didsetup = false

function M.setup()
	if M.didsetup then
		return vim.notify("JWTools already setup!")
	end

	M.didsetup = true

	vim.api.nvim_create_user_command("JWToolsFetchScripture", require("jwtools.fetch").fetch_scripture, {})
end

return M
