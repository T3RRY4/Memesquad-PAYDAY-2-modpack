--[[ Searches Wikipedia
		arguments:
			something you want to know about

		options:
			-(lang)		--changes language of the wiki
			-(num)		--acesses the necessary page,
							--when a choice is given

		examples:
			wiki -es		--switches to spanish wiki
			wiki flash		--you'll get several options
			wiki -3 flash	--picks option #3 of 'flash' request
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'wiki'

local chatName = 'WIKI'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].lang_sym = '/'
PowerChatCommands[cmdName].Parse = function(args, ops, nohex)
	table.remove(args, 1)
	
	if #args == 0 and #ops == 0 then
		PowerChatCommands[cmdName].Help()
		return
	end

	PowerChatCommands[cmdName].Index = nil
	
	for i,s in pairs(ops) do
		s = s:sub(2)
		if s:lower():match('^%a%a$') then
			PowerChatCommands[cmdName].Lang = s:sub(2)
		elseif s:match('^%d+$') then
			local n = tonumber(s:sub(2))
			PowerChatCommands[cmdName].Index = n > 0 and n or 1
		end
	end

	local shex = ''
	if nohex then
		shex = args[1]
	else
		local slow = ''
		for i,s in pairs(args) do
			slow = slow..s:lower()..(i<#args and ' ' or '')
		end
		for v in string.gmatch(slow, '.') do
			shex = shex..'%'..string.format('%X', string.byte(v))
		end
	end
	
	if shex == '' then return end
	log('https://'..PowerChatCommands[cmdName].Lang..'.wikipedia.org/wiki/'..shex)
	
	Steam:http_request(
		'https://'..PowerChatCommands[cmdName].Lang..'.wikipedia.org/wiki/'..shex,
			function(success, body)
				if success then
					body = body:gsub('<table.-</table>\n<p>', '</table>\n<p>', 5)
				
					local st1 = body:find('</table>\n<p>') or 0
					local st2 = body:find('</div>\n<p>') or 0
					local par = ''
					if st2 < st1 then 
						par = string.match(body, '</div>\n<p>.-</p>')
					elseif st1 < st2 then 
						par = string.match(body, '</table>\n<p>.-</p>')
					end
				
					if not par and body:match('<h1') then
						local st0 = body:find('</h1>')
						if st0 then
							par = body:sub(st0):match('<p>.-</p>')
						end
					end
				
					local st3, en3 = body:find('<li><a href=') 
				
					if st3 and (st2+st1 == 0 or par:match(':</p>$')) then
						local counter = 0
						if PowerChatCommands[cmdName].Index then
							for v in string.gmatch(body, '<li><a href=\"(.-)\".-</a>') do
								counter = counter+1
								if counter == PowerChatCommands[cmdName].Index then
									local newarg = v:gsub('/.*/','')
									PowerChatCommands[cmdName].Parse({cmdName..',recursive',newarg}, {}, true)
									break 
								end
							end
						else
							local result = ''
							for v in string.gmatch(body, '<li><a href.->(.-)</a>') do
								counter = counter+1
								result = result..counter..'. '..v..'; '
								if counter == 5 then break end
							end
							PowerChat:OutPut(chatName, result:gsub('<.->', ''), Color.yellow)
						end
					elseif par then
						par = par:gsub('<.->', '')
								:gsub('%[.-]','')
								:gsub('%(.-%(','('):gsub('%).-%)',')'):gsub('%(.-%)','')
								:gsub('&#%d-;','')
						PowerChat:OutPut(chatName, par, Color.green)
					else
						PowerChat:OutPut(chatName, 'Parsing went wrong', Color.red)
					end
				else
					PowerChat:OutPut(chatName, 'Something went wrong', Color.red)
				end
			end
		)
end

PowerChatCommands[cmdName].Lang = 'en'

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Searches Wikipedia', Color.yellow)
	PowerChat:OutPut(chatName, 'wiki [-(lang)] [-(num)] [query]', Color.yellow)
	PowerChat:OutPut(chatName, '-(lang) = language (like -en); -(num) = number (when choice)', Color.yellow)
end