--[[ Shows quotes from bash.org
		arguments:
			number of the quote
		examples:
			bash	--show random quote
			bash 32	--show quote #32
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'bash'

local chatName = 'BASH'

local counter = math.random(10000)
PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops, norep)
	table.remove(args, 1)
	
	--if #args == 0 then
	--	PowerChatCommands[cmdName].Help()
	--end
	
	local link = 'http://www.qdb.us/random'..counter
	counter = counter > 10000 and 1 or counter + 1
	
	local bynum = nil
	
	if #args > 0 and args[1]:match('%d+') then
		link = 'http://www.qdb.us/'..args[1]
		bynum = true
	end
	
	Steam:http_request(
			link,
			function(success, body)
				if success then
					for num,qt in body:gmatch('<a class="ql" href=\"/(%d+)\".-class=\"?qt\"?.->(.-)</span>', 5) do
						if qt then
							local _, count = qt:gsub('<br', '')
						
							if count and (bynum or count < 4) then
								qt = qt:gsub('<br />.-\n','\n'):gsub('&gt;','>')
										:gsub('&lt;','<'):gsub('&.-;', '')
							
								PowerChat:OutPut(chatName, '#'..num, Color.green)
								for line in qt:gmatch('[^\n]+') do
									PowerChat:OutPut(chatName, line, Color.green)
								end
								return
							end
						end
					end
					if norep then
						PowerChat:OutPut(chatName, 'Something went wrong', Color.red)
						return
					end
					PowerChatCommands[cmdName].Parse(args, ops, true)
				else
					PowerChat:OutPut(chatName, 'Something went wrong', Color.red)
				end
			end
		)
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Shows quotes from bash.org', Color.yellow)
	PowerChat:OutPut(chatName, 'bash [quote_number1, quote_number2]', Color.yellow)
end