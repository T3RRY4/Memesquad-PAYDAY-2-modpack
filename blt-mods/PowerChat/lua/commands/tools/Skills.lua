--[[ Shows skills of given player(s)
	arguments:
		player name
	options:
		-all	--shows playtime for all of the players
	examples:
		skills -all
		skills andole
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'skills'

local chatName = 'SKILLS'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops)
	table.remove(args, 1)
	
	if #args == 0 and #ops == 0 then
		PowerChatCommands[cmdName].Help()
	end

	if #ops > 0 and ops[1]:lower():sub(2) == 'all' then
		for i,p in pairs(managers.network:session():peers()) do
			PowerChatCommands[cmdName].GetSkills(p)
		end
		return
	end
	
	if #ops > 0 then
		ops[1] = ops[1]:lower():sub(2)
		if ops[1]:match('%d') then
			local peers = managers.network:session():peers() or {}
			local id = tonumber(ops[1])
			if peers[id] then
				PowerChatCommands[cmdName].GetSkills(peers[id])
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
				PowerChatCommands[cmdName].GetSkills(p)
			end
		end
	end
end

PowerChatCommands[cmdName].GetSkills = function(peer)
	local outfit_string = peer:profile("outfit_string")
	
	local skills, perkdeck = outfit_string:match('([%d_]+)%-(%d%d?_%d)')
	
	local newskills = peer:name()..': '
	
	for x,y,z in skills:gmatch('(%d%d?)_(%d%d?)_(%d%d?)') do
		newskills = newskills..x..'-'..y..'-'..z..' | '
	end
	
	local perktext = managers.localization:text('menu_st_spec_'..perkdeck:match('%d%d?')) or ''
	perktext = perktext..' '..perkdeck:match('_(%d)')..'/9'
	newskills = newskills..perktext
	
	PowerChat:OutPut(chatName, newskills, Color.green)
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Shows skills of given player(s)', Color.yellow)
	PowerChat:OutPut(chatName, 'skills [-all] [-player_id(1-4)] [player1_name, player2_name...]', Color.yellow)
end