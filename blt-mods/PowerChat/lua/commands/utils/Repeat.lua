--[[ Sends your previous message again
	no arguments
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'rep'
local cmdName2 = 'crep'

local chatName = 'REP'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops, cmd)
	local str
	if cmd then
		str = PowerChatCommands[cmdName].oldcmd
	else
		str = PowerChatCommands[cmdName].oldmsg
	end
	
	if str then
		if managers.chat then
			local peer = managers.network and managers.network:session() or nil
			peer = peer and peer:local_peer() or nil
			if peer then
					managers.chat:send_message(1, peer, str)
			end
		end
		return
	end
	
	PowerChat:OutPut(chatName, 'You have not '..(cmd and 'run any commands' or 'sent any messages')..' yet.', Color.red)
	if (cmd and PowerChatCommands[cmdName].oldmsg)
		or (not cmd and PowerChatCommands[cmdName].oldcmd)
	then
		PowerChat:OutPut(chatName, 'Did you mean \''..(cmd and cmdName or cmdName2)..'\' ?', Color.red)
	end
end

local cmdName2 = 'crep'
PowerChatCommands[cmdName2] = {}
PowerChatCommands[cmdName2].Parse = function()
	PowerChatCommands[cmdName].Parse({},{},true)
end

local CM_send_orig = ChatManager.send_message
function ChatManager:send_message(channel_id, sender, message)
	if message ~= PowerChat.settings.sym..cmdName
		and message ~= PowerChat.settings.sym..cmdName2
	then
		if message:sub(1,1):lower() == PowerChat.settings.sym:lower() then
			PowerChatCommands[cmdName].oldcmd = message
		else
			PowerChatCommands[cmdName].oldmsg = message
		end
	end
	CM_send_orig(self, channel_id, sender, message)
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Sends the previous message again', Color.yellow)
end

PowerChatCommands[cmdName2].Help = function()
	PowerChat:OutPut(chatName, 'Sends the previous command again', Color.yellow)
end