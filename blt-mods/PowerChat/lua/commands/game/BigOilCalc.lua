--[[ Big Oil engine calculator
	arguments:
		number of cables
		gas
		sign

	examples:
		boc he	--sets current gas to Helium
				--it looks for he, de, ni

		boc 3	--sets current cables number to 3 (1, 2, 3)

		boc <	--sets current sign to < (< or >)

		boc he 3 <	--arguments can be used together

	special:
		boc h3l	--short command to get the engine by info
				--gas, cables, pressure
				--l for 'lower' pressure, h for 'higher'
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'boc'

local chatName = 'BOC'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops, need_return)
	table.remove(args, 1)
	
	for i,s in pairs(args) do
		local slow = s:lower()
		
		if PowerChatCommands[cmdName].engines[slow] then
			if need_return then
				return PowerChatCommands[cmdName].engines[slow]
			end
			PowerChat:OutPut(chatName, 'The engine is #'..PowerChatCommands[cmdName].engines[slow])
			return
		end
		
		if slow:match('he') then
			PowerChatCommands[cmdName].cur[1] = 'h'
		elseif slow:match('ni') then
			PowerChatCommands[cmdName].cur[1] = 'n'
		elseif slow:match('de') then
			PowerChatCommands[cmdName].cur[1] = 'd'
		elseif slow:match('>') then
			PowerChatCommands[cmdName].cur[3] = 'h'
		elseif slow:match('<') then
			PowerChatCommands[cmdName].cur[3] = 'l'
		else
			local n = tonumber(s)
			if n then
				PowerChatCommands[cmdName].cur[2] = ''..n
			end
		end
	end

	local id = PowerChatCommands[cmdName].cur[1]..PowerChatCommands[cmdName].cur[2]..PowerChatCommands[cmdName].cur[3]
	if PowerChatCommands[cmdName].engines[id] then
		if need_return then
			return PowerChatCommands[cmdName].engines[id]
		end
		PowerChat:OutPut(chatName, 'The engine is #'..PowerChatCommands[cmdName].engines[id])
	end
	if need_return then
		return '?'
	end
end

PowerChatCommands[cmdName].engines = {
	n1l = 1,
	d1h = 2,
	d2l = 5,
	h2h = 6,
	h3l = 7,
	n3l = 8,
	d3l = 9,
	n3h = 11,
	d3h = 12
}

PowerChatCommands[cmdName].cur = { '0', '0', '0'}  --current

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Shows the Big Oil engine with given parameters', Color.yellow)
	PowerChat:OutPut(chatName, 'boc [gas] [cables] [sign] [gcs]', Color.yellow)
end

PowerChatCommands[cmdName].Parse_Return = function(args, ops)
	return tostring(PowerChatCommands[cmdName].Parse(args, ops, true))
end