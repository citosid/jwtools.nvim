local Config = {}

Config.settings = {
	language = "es",
	keymaps = true,
}

--- Merge user options into settings
---@param opts table|nil User configuration options
function Config.setup(opts)
	opts = opts or {}
	for key, value in pairs(opts) do
		if Config.settings[key] ~= nil then
			Config.settings[key] = value
		else
			vim.notify("JWTools: Invalid configuration key: " .. key, vim.log.levels.WARN)
		end
	end
end

function Config.set(key, value)
	if Config.settings[key] ~= nil then
		Config.settings[key] = value
	else
		vim.notify("JWTools: Invalid configuration key: " .. key, vim.log.levels.ERROR)
	end
end

--- Get a configuration value
---@param key string The configuration key
---@return any The configuration value
function Config.get(key)
	return Config.settings[key]
end

return Config
