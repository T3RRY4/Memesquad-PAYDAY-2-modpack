--[[ Sends the last PowerChat response to all players in the lobby
	no arguments
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'toall'

local chatName = 'TOALL'

PowerChatCommands[cmdName] = {}

PowerChatCommands[cmdName].oldOut = {}

PowerChatCommands[cmdName].Parse = function()

	if #(PowerChatCommands[cmdName].oldOut) > 0 then
		for i, ms in pairs(PowerChatCommands[cmdName].oldOut) do
			if ms then
				if managers.chat then
					local peer = managers.network and managers.network:session() or nil
					peer = peer and peer:local_peer() or nil
					if peer then
						managers.chat:send_message(1, peer, ms or '')
					end
				end
			end
		end
	else
		PowerChat:OutPut(chatName, 'There is nothing to send.', Color.red)
	end
end

local PC_exec_orig = PowerChat.Execute
function PowerChat:Execute(command, ...)
	if not command:lower():match('^'..cmdName) then
		PowerChatCommands[cmdName].oldOut = {}
	end
	return PC_exec_orig(self, command, ...)
end

local PC_output_orig = PowerChat.OutPut
function PowerChat:OutPut(name, message, color, ...)
	if name ~= chatName then
		local inx = #(PowerChatCommands[cmdName].oldOut) + 1
		PowerChatCommands[cmdName].oldOut[inx] = PC_output_orig(self, name, message, color, ...)
		return PowerChatCommands[cmdName].oldOut[inx]
	end
	
	return PC_output_orig(self, name, message, color)
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Sends the previous message to everyone in the lobby', Color.yellow)
end