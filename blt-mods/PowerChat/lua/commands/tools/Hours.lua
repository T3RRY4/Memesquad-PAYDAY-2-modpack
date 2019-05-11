--[[ Prints playtime of selected players
	arguments:
		player name
	options:
		-all	--shows playtime for all of the players
	examples:
		hours -all
		hours andole
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'hours'

local chatName = 'HOURS'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops)
	table.remove(args, 1)
	
	if #args == 0 and #ops == 0 then
		PowerChatCommands[cmdName].Help()
	end

	if #ops > 0 and ops[1]:lower():sub(2) == 'all' then
		for i,p in pairs(managers.network:session():peers()) do
			PowerChatCommands[cmdName].GetHours(p:user_id(), p:name())
		end
		return
	end
	
	if #ops > 0 then
		ops[1] = ops[1]:lower():sub(2)
		if ops[1]:match('%d') then
			local peers = managers.network:session():peers() or {}
			local id = tonumber(ops[1])
			if peers[id] then
				PowerChatCommands[cmdName].GetHours(peers[id]:user_id(), peers[id]:name())
			end
			return
		end
	end
	
	for i,s in pairs(args) do
		local slow = s:lower():gsub('%%', '%%%%'):gsub('%-','%%%-'):gsub('%(','%%%(')
						:gsub('%+','%%%+'):gsub('%*','%%%*'):gsub('%?','%%%?')
						:gsub('%)','%%%)'):gsub('%^','%%%^')
		
		for i,p in pairs(managers.network:session():peers()) do
			if p:name():lower():match(slow) then
				PowerChatCommands[cmdName].GetHours(p:user_id(), p:name())
			end
		end
	end
end

PowerChatCommands[cmdName].GetHours = function(id, name)
	Steam:http_request(
		'http://steamcommunity.com/profiles/'..id..'/games/?tab=recent',
						function(success, body)
							if success then
								local s1, e1 = string.find(body, 'PAYDAY 2')
								if e1 then
									local s2, e2 = string.find(body, 'hours_forever', e1)
									if e2 then
										local hours = ''
										local i = e2+4
										while true do
											local ch = string.sub(body, i, i)
											if tonumber(ch) then
												hours = hours..ch
												i = i + 1
											elseif ch == ',' then
												i = i + 1
											else
												break
											end
										end
										local hrs = tonumber(hours)
										if hrs and hrs > 0 then
											PowerChat:OutPut(chatName, name..' has played '..hrs..' hours', Color.green)
										else
											PowerChat:OutPut(chatName, 'Could not get hours for '..name..'.', Color.red)
										end
									end
								end
							end
						end
					)
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Shows playtime of given player(s)', Color.yellow)
	PowerChat:OutPut(chatName, 'hours [-all] [-player_id(1-4)] [player1_name, player2_name...]', Color.yellow)
end