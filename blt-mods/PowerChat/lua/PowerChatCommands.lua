if not PowerChat or not PowerChat.status then return end
PowerChat.status = false

_G.PowerChatCommands = _G.PowerChatCommands or {}
local cmdName = 'get'
PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops)
	table.remove(args, 1)
	
	if #args < 1 then return end
	
	for k,v in pairs(args) do
		if PowerChat.settings[v] then
			PowerChat:OutPut(nil, v..' = '..PowerChat.settings[v], Color.green)
		end
	end
end

cmdName = 'set'
PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops)
	table.remove(args, 1)
	
	for i, opt in pairs(ops) do
		opt = opt:lower():sub(2)
		
		if opt:match('list') then
			local res = ''
			for k,v in pairs(PowerChat.settings) do
				res = res..k..' '
			end
			PowerChat:OutPut(nil, res, Color.green)
			return
		end
		
		if opt:match('reset') then
			PowerChat.settings = {
				sym = '!',
				opt_sym = '-',
				repl_sym = '$',
				and_sym = '&',
				print_cmd = 'false',
				hijack_chat = 'true'
			}
			PowerChat:OutPut(nil, 'Settings have been reset.', Color.green)
			return
		end
	end
		
	if #ops > 0 and #args == #ops then
		for i=1,#ops do
			local opt = ops[i]:sub(2)
			if PowerChat.settings[opt] then
				PowerChat.settings[opt] = args[i]
				PowerChat:OutPut(nil, '\'PowerChat.'..opt..'\' is now \''..args[i]..'\'', Color.green)
			else
				PowerChat:OutPut(nil, 'Unknown setting: '..opt, Color.red)
			end
		end
		return
	end
	
	if #args < 2 then return end
	if args[1]:sub(1,1) == PowerChat.settings.sym then
		PowerChat:OutPut(nil, 'Replacements cannot start with the command symbol', Color.red)
		return
	end
	
	local k = args[1]
	local v = ''
	
	table.remove(args, 1)
	
	for i,s in pairs(args) do
		v = v..s..' '
	end
	
	v = v:sub(1, string.len(v) - 1)
	
	PowerChat.Replacements = PowerChat.Replacements or {}
	PowerChat.Replacements[k] = v
end

cmdName = 'set-alias'
PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops)
	table.remove(args, 1)

	if #ops > 0 and #args > 0 then
		if #args == #ops then
			for i=1,#ops do
				local opt = ops[i]:sub(2)
				PowerChat.aliases = PowerChat.aliases or {}
				PowerChat.aliases[args[i]] = opt
				PowerChat:OutPut(nil, 'Added alias for \''..opt..'\': \''..args[i]..'\'', Color.green)
			end
			return
		else
			PowerChat:OutPut(nil, 'Nothing was done.', Color.red)
			PowerChat:OutPut(nil, 'Use \'-opt arg\' pairs to set aliases.', Color.red)
			return
		end
	end
end

cmdName = 'unset'
PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args)
	table.remove(args, 1)

	PowerChat.Replacements = PowerChat.Replacements or {}
	
	for i,s in pairs(args) do
		PowerChat.Replacements[s] = nil
	end
end

cmdName = 'onlaunch'
PowerChatCommands[cmdName] = {}

local cmdName2 = 'onlaunch-remove'
PowerChatCommands[cmdName2] = {}
PowerChatCommands[cmdName2].Parse = function(args, ops)
	PowerChatCommands[cmdName].Parse(args, ops, true)
end

PowerChatCommands[cmdName].Parse = function(args, ops, del)
	table.remove(args, 1)
	
	if #args == 0 then
		PowerChatCommands[cmdName].Help()
		return
	end
	
	local str = args[1]
	table.remove(args, 1)
	for i,s in pairs(ops) do
		str = str..' '..s
	end
	for i,s in pairs(args) do
		str = str..' '..s
	end
	
	if str == '' then
		PowerChatCommands[cmdName].Help()
		return
	end
	
	local filename = PowerChat.auto_exec
	local f,err = io.open(filename, 'r')
	local text

	if f then
		text = f:read('*all'):gsub('\n%s*\n', '\n')
		f:close()
	end
	
	if not text then
		text = ''
	end
	
	if del then
		if text ~= '' then
			str = str:gsub('%%', '%%%%'):gsub('%-','%%%-'):gsub('%(','%%%(')
						:gsub('%+','%%%+'):gsub('%*','%%%*'):gsub('%?','%%%?')
						:gsub('%)','%%%)'):gsub('%^','%%%^')
			
			text = text:gsub('[^\n]*'..str..'[^\n]*', '')
		end
	else
		text = text..'\n'..str
	end
	
	if text ~= '' then
		local f2,err2 = io.open(filename, 'w')

		if f2 then
			f2:write(text)
			f2:close()
		end
	end
end

PowerChatCommands[cmdName].Help = function()
	local chatName = cmdName:lower()
	PowerChat:OutPut(chatName, 'Add or remove auto-exec commands', Color.yellow)
	PowerChat:OutPut(chatName, 'onlaunch [command opts args]', Color.yellow)
	PowerChat:OutPut(chatName, 'onlaunch-remove [command opts args]', Color.yellow)
end

cmdName = 'exec'
PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops)
	table.remove(args, 1)
	
	if not args[1] then return end
	
	local filename = args[1]
	table.remove(args, 1)
	for k,v in pairs(args) do
		filename = filename..' '..v
	end
	PowerChat:ExecFile((SavePath or 'mods/saves/')..filename)
end

cmdName = 'clear'
PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops)
	if managers.menu_component._game_chat_gui then
		local l = managers.menu_component._game_chat_gui._lines or {}
		local pnl = managers.menu_component._game_chat_gui._panel
		pnl = pnl and pnl:child("output_panel") or nil
		pnl = pnl and pnl:child("scroll_panel") or nil
		if pnl then
			for k,v in pairs(l) do
				for k2,v2 in pairs(v) do
					pnl:remove(v2)
				end
			end
			managers.menu_component._game_chat_gui._lines = {}
		end
	end
end

PowerChat.status = true