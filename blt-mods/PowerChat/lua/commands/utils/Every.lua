--[[ Keeps sending given chat message every X seconds
		arguments
			message
			
		options
			-(numOfSecs)  -- interval of sending in seconds
			
		examples
			every -5 hello		-- say 'hello' every 5 seconds
			every -15 !count meds  -- run 'count meds' every 15 secs
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'every'

local chatName = 'EVERY'

PowerChatCommands[cmdName] = {}

PowerChatCommands[cmdName].ticks = {}

PowerChatCommands[cmdName].Parse = function(args, ops, delayed)
	table.remove(args, 1)

	ops = ops or {}
	local new_interval = ops[1] and tonumber(ops[1]:sub(2)) or nil
	
	if new_interval then
	
		local new_message = ''
		
		if args[1] and args[1] == PowerChat.settings.sym..cmdName then
			PowerChat:OutPut(chatName, 'Do not use \'every\' with itself!', Color.red)
			return
		end
		
		for i = 1, #args do
			new_message = new_message .. args[i] .. (#ops == 0 and '' or ' ')
		end
		
		for i = 2, #ops do
			new_message = new_message .. ops[i] .. (i == #ops and '' or ' ')
		end
		
		if not new_message:match('^[%s_]*$') then
			table.insert(PowerChatCommands[cmdName].ticks,	{
										interval = new_interval,
										message = new_message,
										old_time = Application:time(),
										delayed = delayed
									})
		else
			PowerChat:OutPut(chatName, 'You must specify a message', Color.red)
		end
	else
		PowerChat:OutPut(chatName, 'You must specify an interval in seconds', Color.red)
		return
	end
end

PowerChatCommands[cmdName].Update = function()
	local apptime = Application:time()
		
	for k,v in pairs(PowerChatCommands[cmdName].ticks) do
		if apptime - v.old_time > v.interval then
			PowerChatCommands[cmdName].ticks[k].old_time = apptime
			if managers.chat then
				local peer = managers.network and managers.network:session() or nil
				peer = peer and peer:local_peer() or nil
				if peer then
					managers.chat:send_message(1, peer, v.message)
				end
			end
			if PowerChatCommands[cmdName].ticks[k].delayed then
				table.remove(PowerChatCommands[cmdName].ticks, k)
			end
		end
	end
end
		
if not CopDamage then
	local CBG_upd = ContractBoxGui.update
	function ContractBoxGui:update(t, dt)
		CBG_upd(self, t, dt)
		if #PowerChatCommands[cmdName].ticks > 0 then
			PowerChatCommands[cmdName].Update()
		end
	end
else
	local PM_upd = PlayerManager.update
	function PlayerManager:update(t, dt)
		PM_upd(self, t, dt)
		if #PowerChatCommands[cmdName].ticks > 0 then
			PowerChatCommands[cmdName].Update()
		end
	end
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Keeps sending given chat message every X seconds', Color.yellow)
	PowerChat:OutPut(chatName, 'every -(numOfSecs) [message]', Color.yellow)
	PowerChat:OutPut(chatName, 'Use \'every-stop [-(numOfSecs)] [-all] [message]\' to stop it.', Color.yellow)
end

local cmdName2 = 'every-stop'
PowerChatCommands[cmdName2] = {}
PowerChatCommands[cmdName2].Parse = function(args, ops)
	table.remove(args, 1)
	
	if #PowerChatCommands[cmdName].ticks == 0 then
		PowerChat:OutPut(chatName, 'There is no cycling messages', Color.yellow)
		return
	end
	
	local search_str = ''
	for i = 1, #args do
			search_str = search_str .. args[i] .. (i == #args and '' or ' ')
	end
	
	for k,v in pairs(PowerChatCommands[cmdName].ticks) do
		if ops and #ops > 0 then
			for k2,v2 in pairs(ops) do
				if v.interval == tonumber(v2:sub(2)) or v2 == '-all' then
					if search_str ~= '' then
						if v.message:match(search_str) then
							table.remove(PowerChatCommands[cmdName].ticks, k)
						end
					else
						table.remove(PowerChatCommands[cmdName].ticks, k)
					end
				end
			end
		else
			if search_str ~= '' then
				if v.message:match(search_str) then
					table.remove(PowerChatCommands[cmdName].ticks, k)
				end
			else
				PowerChat:OutPut(chatName, 'You must specify an interval or a search text (or both)', Color.red)
				return
			end
		end
	end
end

local cmdName3 = 'every-delay'

local chatName3 = 'EVERY'

PowerChatCommands[cmdName3] = {}
PowerChatCommands[cmdName3].Parse = function(args, ops)
	PowerChatCommands[cmdName].Parse(args, ops, true)
end