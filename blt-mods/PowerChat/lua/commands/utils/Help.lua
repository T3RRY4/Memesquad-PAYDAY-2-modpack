--[[ Launches Help() function for the given command
	arguments:
		command

	examples:
		help hours
		help hours boc	--show help for multiple commands
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'help'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args)
	table.remove(args, 1)

	for i,s in pairs(args) do
		local slow = s:lower()
		
		if PowerChatCommands[s] 
			and PowerChatCommands[s].Help
		then
			PowerChatCommands[s].Help()
		end
	end
end