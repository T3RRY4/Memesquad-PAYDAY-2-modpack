--[[ Caps frames per second rate at a given value
	arguments:
		value	--new fps rate

	examples:
		fps 60
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'fps'

local chatName = 'FPS'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args)
	table.remove(args, 1)
	
	if #args < 1 then
		PowerChatCommands[cmdName].Help()
		return
	end
	
	local value = tonumber(args[1])
	
	if value then
		Application:cap_framerate(value)
	end
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Caps frames per second rate at a given value', Color.yellow)
	PowerChat:OutPut(chatName, 'fps [value]', Color.yellow)
end