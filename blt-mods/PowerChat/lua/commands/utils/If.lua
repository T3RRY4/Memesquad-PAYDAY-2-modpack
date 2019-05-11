--[[ 
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'if'

local chatName = 'IF'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse_Return = function(args, ops)
	table.remove(args, 1)
	
	if #args < 1 or #ops < 2 then
		PowerChatCommands[cmdName].Help()
		return '?'
	end
	
	local condition = args[1]
	table.remove(args, 1)
	for k,v in pairs(args) do
		condition = condition..' '..v
	end
	
	local signs = {'==','>=','<=','>','<'}
	local sign = nil
	for k,v in pairs(signs) do
		if condition:match(v) then
			sign = v
			break
		end
	end
	
	if not sign then return '?' end
	
	local arg1, arg2 = condition:match('(.-)'..sign..'(.+)')
	
	local function fix_format(str)
		if str ~= 'true' and str ~= 'false' then
			return '\''..str..'\''
		end
		return str
	end
	
	local  ls = loadstring('return '..fix_format(arg1)..sign..fix_format(arg2))()
	if ls ~= nil then
		return ls and ops[1]:sub(2) or ops[2]:sub(2)
	end
	return '?'
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Checks a condition and gives a specified response', Color.yellow)
	PowerChat:OutPut(chatName, 'if (condition) -(response_true) -(response_false)', Color.yellow)
end

PowerChatCommands[cmdName].Signs = {}
PowerChatCommands[cmdName].Signs['=='] = function(arg1, arg2)

end