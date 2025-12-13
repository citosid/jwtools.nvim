local M = {}

local REGISTER = "j"

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

	local mode = vim.fn.mode()

	if mode == "v" or mode == "V" or mode == "\22" then
		-- Visual mode: delete selection first, then insert
		vim.cmd('normal! "_d')
		vim.api.nvim_put(vim.split(content, "\n"), "c", true, true)
	else
		-- Normal mode: insert at cursor
		vim.api.nvim_put(vim.split(content, "\n"), "c", true, true)
	end
end

return M
