--[[ 	Sends given chat message after given function is called
			arguments
				message
				
			options
				-Class:Function		-- function to hook to
			
			examples
					-- Say 'I got ammo' whenever you pick up an ammo box
				hook -AmmoClip:_pickup I got ammo  
				
					-- Run '!count enemies' whenever you kill an enemy
				hook -PlayerManager:on_killshot !count enemies  
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'hook'

local chatName = 'HOOK'

PowerChatCommands[cmdName] = {}

PowerChatCommands[cmdName].hooks = {}

PowerChatCommands[cmdName].Parse = function(args, ops)
	table.remove(args, 1)

	ops = ops or {}
	local hook_func_str = ops[1] and ops[1]:sub(2) or nil
	
	if hook_func_str then
	
		local new_message = ''
		
		for i = 1, #args do
			if args[i] == PowerChat.settings.sym..cmdName then
				PowerChat:OutPut(chatName, 'Do not use \'hook\' with itself!', Color.red)
				return
			end
			new_message = new_message .. args[i] .. (#ops == 0 and '' or ' ')
		end
		
		for i = 2, #ops do
			new_message = new_message .. ops[i] .. (i == #ops and '' or ' ')
		end
		
		local hclass, hfunc = hook_func_str:match('([^:%.]+):([^:%.]+)')
		
		if not new_message:match('^[%s_]*$') then
			if hclass and hfunc and _G[hclass] and _G[hclass][hfunc] then
				local inx = hclass..'____'..hfunc
				PowerChatCommands[cmdName].hooks[inx] = PowerChatCommands[cmdName].hooks[inx] or {}
				if not PowerChatCommands[cmdName].hooks[inx].origfunccode then
					PowerChatCommands[cmdName].hooks[inx] = {
						origfunccode = _G[hclass][hfunc],
						origfunc = hfunc,
						origclass = hclass,
						messages = { new_message }
					}
				else
					table.insert(PowerChatCommands[cmdName].hooks[inx].messages, new_message)
				end
				_G[hclass][hfunc] = function(...)
					PowerChatCommands[cmdName].hooks[inx].origfunccode(...)
					if managers.chat then
						local peer = managers.network and managers.network:session() or nil
						peer = peer and peer:local_peer() or nil
						if peer then
							for k,v in pairs(PowerChatCommands[cmdName].hooks[inx].messages) do
								managers.chat:send_message(1, peer, v)
							end
						end
					end
				end
			else
				PowerChat:OutPut(chatName, 'Class or function not found', Color.red)
			end
		else
			PowerChat:OutPut(chatName, 'You must specify a message', Color.red)
		end
	else
		PowerChat:OutPut(chatName, 'You must specify a function you want to hook to.', Color.red)
		return
	end
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Sends given chat message after given function is called', Color.yellow)
	PowerChat:OutPut(chatName, 'hook -Class:Function [message]', Color.yellow)
	PowerChat:OutPut(chatName, 'Use \'unhook [-all] [message]\' to stop it.', Color.yellow)
end

local cmdName2 = 'unhook'
PowerChatCommands[cmdName2] = {}
PowerChatCommands[cmdName2].Parse = function(args, ops)
	table.remove(args, 1)
		
	ops = ops or {}
	local hook_func_str = ops[1] and ops[1]:sub(2) or ''
	local hclass, hfunc = hook_func_str:match('([^:%.]+):([^:%.]+)')
	
	local search_str = ''
	for i = 1, #args do
			search_str = search_str .. args[i] .. (i == #args and '' or ' ')
	end
	
	if hclass and hfunc then
		local inx = hclass..'____'..hfunc
		if PowerChatCommands[cmdName].hooks[inx] then
			if search_str ~= '' then
				for k,v in pairs(PowerChatCommands[cmdName].hooks[inx].messages) do
					if v:match(search_str) then
						table.remove(PowerChatCommands[cmdName].hooks[inx].messages, k)
					end
				end
			else
				-- Cannot return the original function to its place
				--  because other mods might have overriden it after us
				-- Simply clear the messages list
				PowerChatCommands[cmdName].hooks[inx].messages = {}
			end
		end
	else
		if search_str ~= '' then
			for k,v in pairs(PowerChatCommands[cmdName].hooks) do
				for k2,v2 in pairs(v.messages) do
					if v2:match(search_str) then
						PowerChatCommands[cmdName].hooks[k].messages[k2] = nil
					end
				end
			end
		else
			PowerChat:OutPut(chatName, 'You must specify the message pattern or -Class:Function (or both)', Color.red)
		end
	end
end