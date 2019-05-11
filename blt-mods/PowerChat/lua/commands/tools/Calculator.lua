--[[ A calculator
	arguments:
		math problem	--* / ^ % + -
						--cannot start with -
	examples:
		calc 4+(9-3*9)/(2^(25%3))
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'calc'

local chatName = 'CALC'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops, need_return)
	table.remove(args, 1)
	
	if #args == 0 then
		PowerChatCommands[cmdName].Help()
	end
	
	local str = ''
	for i,s in pairs(args) do
		if s:match('[%d%./%*%+%-%(%)%%%^]+') then
			str = str..s
		else
			PowerChat:OutPut(chatName, 'Wrong format: '..s, Color.red)
			return
		end
	end
	PowerChatCommands[cmdName].Terminate = nil
	local result = PowerChatCommands[cmdName].Evaluate(str)
	if result ~= '' and not need_return then
		PowerChat:OutPut(chatName, result, Color.green)
	else
		return result
	end
end

PowerChatCommands[cmdName].Evaluate = function(str)

	local  ls = loadstring('return '..str)()
	if ls then
		return tostring(ls)
	end
	
	local newstr = str

	while newstr ~= nil do

		local m = newstr:match('%([^%(]-%)')
		
		if not m then break end
		
		local replace = m:gsub('%%', '%%%%'):gsub('%-','%%%-'):gsub('%(','%%%(')
						:gsub('%+','%%%+'):gsub('%*','%%%*'):gsub('%?','%%%?')
						:gsub('%)','%%%)'):gsub('%^','%%%^')
		
		newstr = newstr:gsub(replace, PowerChatCommands[cmdName].Evaluate(m:sub(2,#m-1)))
		
		if PowerChatCommands[cmdName].Terminate then return '' end
	end
	
	for k,v in pairs(PowerChatCommands[cmdName].operatorsSyms) do
		local br = true
		local pat = '('..(k > 4 and '%-?' or '')..'[%d%.]+)('..(v=='/' and v or '%'..v)..')(%-?[%d%.]+)'
		
		while br do
			br = false
			for arg1,operator,arg2 in newstr:gmatch(pat) do
				
				if not operator then 
					br = false
					break 
				end
				br = true
				
				local repstr = arg1:gsub('%-','%%%-')..(v=='/' and v or '%'..v)..arg2:gsub('%-','%%%-')

				local res = PowerChatCommands[cmdName].operators[k](arg1,arg2)
				
				newstr = newstr:gsub(repstr, res)
				
				if PowerChatCommands[cmdName].Terminate then
					PowerChat:OutPut(chatName, PowerChatCommands[cmdName].Terminate, Color.red)
					return ''
				end
			end
		end
	end
	
	return newstr
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'A calculator', Color.yellow)
	PowerChat:OutPut(chatName, 'calc [problem]', Color.yellow)
end

PowerChatCommands[cmdName].Parse_Return = function(args, ops)
	return PowerChatCommands[cmdName].Parse(args, ops, true)
end

PowerChatCommands[cmdName].operatorsSyms = {}
PowerChatCommands[cmdName].operatorsSyms[1] = '^'
PowerChatCommands[cmdName].operatorsSyms[2] = '*'
PowerChatCommands[cmdName].operatorsSyms[3] = '/'
PowerChatCommands[cmdName].operatorsSyms[4] = '%'
PowerChatCommands[cmdName].operatorsSyms[5] = '-'
PowerChatCommands[cmdName].operatorsSyms[6] = '+'

local index = 0
PowerChatCommands[cmdName].operators = {}
index = index + 1
PowerChatCommands[cmdName].operators[index] = function(arg1,arg2)
	local num1 = tonumber(arg1)
	local num2 = tonumber(arg2)
	local result = ''
	
	if num1 and num2 then
		result = result..math.pow(num1,num2)
	else
		PowerChatCommands[cmdName].Terminate = 'Error powering \''..arg1..'\' and \''..arg2..'\''
	end
	return result
end

index = index + 1
PowerChatCommands[cmdName].operators[index] = function(arg1,arg2)
	local num1 = tonumber(arg1)
	local num2 = tonumber(arg2)
	local result = ''
	
	if num1 and num2 then
		result = result..(num1*num2)
	else
		PowerChatCommands[cmdName].Terminate = 'Error multiplying \''..arg1..'\' and \''..arg2..'\''
	end
	return result
end

index = index + 1
PowerChatCommands[cmdName].operators[index] = function(arg1,arg2)
	local num1 = tonumber(arg1)
	local num2 = tonumber(arg2)
	local result = ''
	
	if num1 and num2 then
		result = result..(num1/num2)
	else
		PowerChatCommands[cmdName].Terminate = 'Error dividing \''..arg1..'\' and \''..arg2..'\''
	end
	return result
end

index = index + 1
PowerChatCommands[cmdName].operators[index] = function(arg1,arg2)
	local num1 = tonumber(arg1)
	local num2 = tonumber(arg2)
	local result = ''
	
	if num1 and num2 then
		result = result..(num1%num2)
	else
		PowerChatCommands[cmdName].Terminate = 'Error getting remainder \''..arg1..'\' and \''..arg2..'\''
	end
	return result
end

index = index + 1
PowerChatCommands[cmdName].operators[index] = function(arg1,arg2)
	local num1 = tonumber(arg1)
	local num2 = tonumber(arg2)
	local result = ''
	
	if num1 and num2 then
		result = result..(num1-num2)
	else
		PowerChatCommands[cmdName].Terminate = 'Error subtracting \''..arg1..'\' and \''..arg2..'\''
	end
	return result
end

index = index + 1
PowerChatCommands[cmdName].operators[index] = function(arg1,arg2)
	local num1 = tonumber(arg1)
	local num2 = tonumber(arg2)
	local result = ''
	
	if num1 and num2 then
		result = result..(num1+num2)
	else
		PowerChatCommands[cmdName].Terminate = 'Error summing \''..arg1..'\' and \''..arg2..'\''
	end
	return result
end