local Config = {}

Config.settings = {
	language = "es",
}

function Config.set(key, value)
	if Config.settings[key] ~= nil then
		Config.settings[key] = value
	else
		vim.notify("Invalid configuration key: " .. key, vim.log.levels.ERROR)
	end
end

-- Function to get the current configuration
function Config.get(key)
	return Config.settings[key]
end

return Config
