_G.PowerChat = _G.PowerChat or {}
PowerChat.status = false

PowerChat.settings = {
	sym = '!',
	opt_sym = '-',
	repl_sym = '$',
	and_sym = '&',
	print_cmd = 'false',
	hijack_chat = 'true'
}


PowerChat.auto_exec = (SavePath or 'mods/saves/')..'PowerChat_onlaunch.txt'
PowerChat.out_type = 'log' -- or 'me' or 'all'

function PowerChat:Init()
	local thisPath = debug.getinfo(2, "S").source:sub(2)
	local thisDir = string.match(thisPath, '.*/')
	
	-- you can load your script by hooking it through 'mod.txt'
	--	or through dofile()
	-- you can use PowerChat:LoadScript, but make sure it exists
	PowerChat:LoadScript(thisDir..'commands/game/BigOilCalc.lua')
	PowerChat:LoadScript(thisDir..'commands/tools/Hours.lua')
	PowerChat:LoadScript(thisDir..'commands/utils/Help.lua')
	PowerChat:LoadScript(thisDir..'commands/utils/List.lua')
	PowerChat:LoadScript(thisDir..'commands/utils/Repeat.lua')
	PowerChat:LoadScript(thisDir..'commands/utils/ToPeers.lua')
	PowerChat:LoadScript(thisDir..'commands/utils/Every.lua')
	PowerChat:LoadScript(thisDir..'commands/utils/Hook.lua')
	PowerChat:LoadScript(thisDir..'commands/utils/Event.lua')
	PowerChat:LoadScript(thisDir..'commands/utils/Updates.lua')
	PowerChat:LoadScript(thisDir..'commands/utils/If.lua')
	PowerChat:LoadScript(thisDir..'commands/game/Count.lua')
	PowerChat:LoadScript(thisDir..'commands/game/Fps.lua')
	PowerChat:LoadScript(thisDir..'commands/other/One-Liners.lua')
	PowerChat:LoadScript(thisDir..'commands/tools/Dictionary.lua')
	PowerChat:LoadScript(thisDir..'commands/tools/Wikipedia.lua')
	PowerChat:LoadScript(thisDir..'commands/tools/Calculator.lua')
	PowerChat:LoadScript(thisDir..'commands/tools/Skills.lua')
	PowerChat:LoadScript(thisDir..'commands/other/Bash.lua')
	PowerChat:LoadScript(thisDir..'commands/game/PrivateMessage.lua')
	
	PowerChat:ExecFile(PowerChat.auto_exec, true)
	PowerChat.out_type = 'me'
end

function PowerChat:Parse(command, save, need_return)
	if command:sub(1,1) == PowerChat.settings.sym then
		PowerChat.out_type = 'all'
		
		if PowerChat.settings.hijack_chat == 'true' then
			command = (PowerChat.settings.sym == ' ' and '_' or ' ')..command
			if managers.chat then
				local peer = managers.network and managers.network:session() or nil
				peer = peer and peer:local_peer() or nil
				if peer then
					managers.chat:send_message(1, peer, command, true)
				end
			end
		end
		
		command = command:sub(3)
	elseif not need_return then
		PowerChat.out_type = 'me'
		log("[PowerChat] "..command)
		if PowerChat.settings.print_cmd:match('true') then
			PowerChat:OutPut(nil, PowerChat.settings.sym..command, Color.green)
		end
	else
		PowerChat.out_type = 'log'
	end
	
	if command:sub(1,1) == PowerChat.settings.opt_sym then
		PowerChat:OutPut(nil, 'Error in '..command, Color.red)
		PowerChat:OutPut(nil, 'Commands cannot start with '..PowerChat.settings.opt_sym, Color.red)
		return
	end
	
	local cmdName = command:match('%S+')
	if PowerChat.aliases
		and PowerChat.aliases[cmdName]
	then
		command = command:gsub(cmdName, PowerChat.aliases[cmdName], 1)
	end
	
	if need_return then
		return PowerChat:Execute(command, save, true) or 'nil_PC:Parse'
	end
	
	if command:match(PowerChat.settings.and_sym) then
		
		local andsym = PowerChat:Unmagic(PowerChat.settings.and_sym)
		
		for i in command:match('%S+'):gmatch('[^%s'..andsym..']+') do
			PowerChat:Execute(command:gsub('%S+', i, 1), save)
		end
	else
		PowerChat:Execute(command, save)
	end
end

function PowerChat:Execute(command, save, need_return)
	local args = {}
	local ops = {}
	
	for i in string.gmatch(command, '%S+') do
		if i:sub(1,1) == PowerChat.settings.opt_sym then
			ops[#ops + 1] = i
		else
   			args[#args + 1] = i
		end
	end
	
	if #args < 1 then return end
	
	local cmdName = args[1]:lower()
	
	cmdName = (PowerChat.aliases and PowerChat.aliases[cmdName]) and PowerChat.aliases[cmdName] or cmdName
	
	local func = need_return and 'Parse_Return' or 'Parse'
	
	if PowerChatCommands
		and PowerChatCommands[cmdName]
		and PowerChatCommands[cmdName][func]
		and type(PowerChatCommands[cmdName][func]) == 'function'
	then
		local ok,er = pcall(PowerChatCommands[cmdName][func], args, ops)
		if not ok then
			PowerChat:OutPut(nil, 'An error occured while running: '..cmdName, Color.red)
			if type(er) == 'string' then
				PowerChat:OutPut(nil, er, Color.red)
			end
		elseif need_return then
			return er or 'nil_PC:Execute'
		end
	else
		if save then
			PowerChatCommands[cmdName] = PowerChatCommands[cmdName] or {}
			PowerChatCommands[cmdName].Pending = PowerChatCommands[cmdName].Pending or {}
			PowerChatCommands[cmdName].Pending[#(PowerChatCommands[cmdName].Pending) + 1] = { args=args, ops=ops}
		else
			-- if you get this, make sure that your script is loaded
			if need_return then
				PowerChat:OutPut(nil, 'Command not found or cannot be used this way: '..cmdName, Color.yellow, 'me')
				return 'nil'
			else
				PowerChat:OutPut(nil, 'Command not found: '..cmdName, Color.yellow)
				
				local l = cmdName:len()
				local query1 = '^'..PowerChat:Unmagic(cmdName:sub(1, l - 1))..'.?.?$'
				local query2 = '^.?.?'..PowerChat:Unmagic(cmdName:sub(2))..'$'
				local result = ''
				for k,v in pairs(PowerChatCommands) do
					if k:match(query1) then
						result = result..k..' '
					elseif k:match(query2) then
						result = result..k..' '
					end
				end
				if result ~= '' then
					PowerChat:OutPut(nil, 'Similar commands: '..result, Color.yellow)
				end
			end
		end
	end
end

-- this is to be used for printing in the chat
-- green color = success, red = failure/error, yellow = warning/important info
function PowerChat:OutPut(name, message, color, type_override)
	if not name then
		name = 'PowerChat'
	end
	
	name = '['..name..']'
	message = message or ''
	
	if message:len() > 325 then
		message = message:sub(1,325)..'...'
	end
	
	if type_override then
		PowerChat.out_type = type_override
	end
	
	if not managers.chat then
		PowerChat.out_type = 'log'
	end
	
	local peer = managers.network and managers.network:session() or nil
	peer = peer and peer:local_peer() or nil
		
	if PowerChat.out_type == 'me' then
		managers.chat:_receive_message(1, name, message, color or Color.green)
	elseif PowerChat.out_type == 'all' and peer then
		managers.chat:send_message(1, peer, message)
	elseif PowerChat.out_type == 'log' then
		log('[PowerChat] ['..name..'] '..message)
	end
	
	return message
end

function PowerChat:LoadScript(path)
	local f = io.open(path)
	if f then
		f.close()
		dofile(path)
	else
		log("[PowerChat] File does not exist: "..path)
	end
end

function PowerChat:ExecFile(path, save)
	local f,err = io.open(path, 'r')
	local text

	if f then
		text = f:read('*all')
		f:close()
	end
	
	if text then
		for i in string.gmatch(text, "[^\n]+") do
			PowerChat:Parse(i, save)
		end
	end
end

function PowerChat:Unmagic(str)
	 return str:gsub('%%', '%%%%'):gsub('%-','%%%-'):gsub('%(','%%%(')
						:gsub('%+','%%%+'):gsub('%*','%%%*'):gsub('%?','%%%?')
						:gsub('%)','%%%)'):gsub('%^','%%%^')
end

PowerChat.status = true