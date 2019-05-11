--[[ Lists the available commands
	arguments:
		pattern		--can include * which matches any text

	examples:
		list	--lists all of the commands
		list h*	--lists the commands that start with 'h'
		list *o*	--lists the commands that contain 'o'
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'list'

local chatName = 'LIST'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops)
	table.remove(args, 1)
	
	local searchTable = PowerChatCommands
	if #ops > 0 then
		if ops[1]:match('^%-aliase?s?$') then
			searchTable = PowerChat.aliases or {}
		end
	end
	
	local result = ''

	if #args > 0 then
		local slow = ('^'..args[1]:lower()..'$'):gsub('%*', '.*')
		
		for k,v in pairs(searchTable) do
			if k:match(slow) then
				result = result..k..' '
			end
		end
	else
		for k,v in pairs(searchTable) do
				result = result..k..' '
		end
	end
	
	PowerChat:OutPut(chatName, result, Color.green)
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Lists the available commands', Color.yellow)
	PowerChat:OutPut(chatName, 'list [-aliases] [(pattern)]', Color.yellow)
end