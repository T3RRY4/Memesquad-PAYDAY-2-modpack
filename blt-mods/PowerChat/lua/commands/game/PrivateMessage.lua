--[[ Sends private message to given player(s)
	arguments:
		message
	options:
		-(player)	--add player to the list of recipients
	examples:
		pm -andole	--add players with 'andole' in the name
						to the recipients list
		pm -abc hello	--add players with 'abc' in the name
							and send 'hello' to all added players
		pm hello	--send 'hello' to the players in the list
		pm-clear	--clear the list of recipients
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'pm'

local chatName = 'PM'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].peers = {}
PowerChatCommands[cmdName].Parse = function(args, ops)
	table.remove(args, 1)
	
	if #args == 0 and #ops == 0 then
		PowerChatCommands[cmdName].Help()
		return
	end
	
	if #(PowerChatCommands[cmdName].peers) == 0
		and #ops == 0
	then
		PowerChatCommands[cmdName].Help()
		return
	end
	
	for k,v in pairs(ops) do
		local vlow = v:sub(2):lower():gsub('%%', '%%%%'):gsub('%-','%%%-'):gsub('%(','%%%(')
						:gsub('%+','%%%+'):gsub('%*','%%%*'):gsub('%?','%%%?')
						:gsub('%)','%%%)'):gsub('%^','%%%^')
		
		for i,p in pairs(managers.network:session():peers()) do
			if p:name():lower():match(vlow) then
				PowerChatCommands[cmdName].peers[#(PowerChatCommands[cmdName].peers) + 1] = p
			end
		end
	end
	
	if #(PowerChatCommands[cmdName].peers) == 0 then
		PowerChat:OutPut(chatName, 'Could not find players', Color.red)
		return
	end
	
	if #args > 0 then
		local msg = ''
		for k,v in pairs(args) do
			msg = msg..v..' '
		end

		PowerChatCommands[cmdName].Send_private_message(1, nil, PowerChatCommands[cmdName].peers, msg)
	end
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Sends private message to given player(s)', Color.yellow)
	PowerChat:OutPut(chatName, 'pm -(player) message', Color.yellow)
	PowerChat:OutPut(chatName, 'pm-clear', Color.yellow)
end

PowerChatCommands[cmdName].Send_private_message = function(channel_id, sender, peers, message)
	if managers.network:session() and managers.chat then
		sender = managers.network:session():local_peer()

		local peersStr = ''
		for peer_id, peer in pairs(peers) do
			if peer and peer:ip_verified() then
				peer:send("send_chat_message", channel_id, message)
				local pname = peer:name()
				peersStr = peersStr..' '..(pname:len() > 5 and pname:sub(1,5) or pname)
			end
		end
		
		peersStr = peersStr:sub(2)
		
		managers.chat:receive_message_by_peer(channel_id, sender, '(to '..peersStr..') '..message)
	else
		PowerChat:OutPut(chatName, 'There is no session or chat', Color.red)
	end
end

local cmdName2 = 'pm-clear'
PowerChatCommands[cmdName2] = {}
PowerChatCommands[cmdName2].Parse = function()
	PowerChatCommands[cmdName].peers = {}
	PowerChat:OutPut(chatName, 'List of recipients cleared', Color.green)
end