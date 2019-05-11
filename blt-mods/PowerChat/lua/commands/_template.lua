--[[ Short description of what the command does
	arguments:
		list all of the arguments

	options:
		list all of the options (arguments that start with PowerChat.opt_sym)

	examples:
		write some examples that show how to use the command
--]]

_G.PowerChat = _G.PowerChat or {}  -- it might not be there yet
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'hours'  -- the command to be called, lower case letters only
local chatName = cmdName:upper()

--do not overwrite the whole table if it exists. that can cause crashes if there are hooks.
PowerChatCommands[cmdName] = PowerChatCommands[cmdName] or {}

PowerChatCommands[cmdName].Parse = function(args, ops)
	table.remove(args, 1) -- first arg is cmdName
	
	-- if the usage is wrong then show help
	if #args == 0 and #ops == 0 then
		PowerChatCommands[cmdName].Help()
	end

	-- only one possible option here, use for-in-pairs() otherwise
	-- cut out the option symbol (first character)
	if #ops > 0 and ops[1]:lower():sub(2) == 'all' then
		for i,p in pairs(managers.network:session():peers()) do
			PowerChatCommands[cmdName].GetHours(p:user_id(), p:name())
		end
		return
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

-- give a brief description and usage structure
PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Shows playtime for given player(s)', Color.yellow)
	PowerChat:OutPut(chatName, 'hours [-all] [player1_name, player2_name...]', Color.yellow)
end

-- execute any pending commands
-- this makes auto-exec work for custom commands
if PowerChatCommands[cmdName].Pending then
	for k,v in pairs(PowerChatCommands[cmdName].Pending) do
		PowerChatCommands[cmdName].Parse(v.args or {}, v.ops or {})
	end
end