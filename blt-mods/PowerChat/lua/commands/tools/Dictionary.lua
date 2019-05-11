--[[ Translates words into another language using Multitran.com
		arguments:
			words to translate

		options:
			-(l1)-(l2)	--change languages to l1 and l2
			-set		--(goes after -l1-l2) remembers that language pair,
							--sets it as current pair of languages
			-lang		--prints current language pair
			-(num)		--sets the number of translations to show for each word

		examples:
			dict -ru-en -set 		--sets current language pair to ru-en
			dict -en-ru house		--transtales 'house' into russian, lang pair stays unchanged
			dict -r					--reverses the lang pair and sets it as current
			dict -lang -5	--prints current language pair and sets the number of translations to 5
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'dict'

local chatName = 'DICT'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].lang_sym = '/'
PowerChatCommands[cmdName].Parse = function(args, ops)
	table.remove(args, 1)
	
	if #args == 0 and #ops == 0 then
		PowerChatCommands[cmdName].Help()
	end

	for i,s in pairs(ops) do
		local slow = s:lower():sub(2)
		if slow == 'set' then
			if PowerChatCommands[cmdName].CurLang then
				PowerChatCommands[cmdName].Lang = PowerChatCommands[cmdName].CurLang
			end
		elseif slow == 'lang' then
			PowerChat:OutPut(chatName, 'Current language is '..PowerChatCommands[cmdName].Lang, Color.green)
		elseif slow:match('^%a%a%-%a%a$') then
			local langs = {}
			for i in string.gmatch(s, "%a+") do
				langs[#langs + 1] = i
			end
			
			if #langs > 1 then
				PowerChatCommands[cmdName].CurLang = langs[1]..PowerChatCommands[cmdName].lang_sym..langs[2]
			end
		elseif slow == 'r' then
			local langs = {}
			for i in string.gmatch(PowerChatCommands[cmdName].Lang, "%a+") do
				langs[#langs + 1] = i
			end
			
			if #langs > 1 then
				PowerChatCommands[cmdName].Lang = langs[2]..PowerChatCommands[cmdName].lang_sym..langs[1]
			end
		elseif slow:match('^%d+$') then
			local n = tonumber(s:sub(2))
			PowerChatCommands[cmdName].Amount = n > 0 and n or 1
		end
	end
	
	for i,s in pairs(args) do
		local slow = s:lower()
		local shex = ''
		for v in string.gmatch(slow, '.') do
			shex = shex..'%'..string.format('%X', string.byte(v))
		end
		--log('https://www.multitran.com/'..PowerChatCommands[cmdName].Lang..'/'..shex)
		Steam:http_request(
			'https://www.multitran.com/'..(PowerChatCommands[cmdName].CurLang or PowerChatCommands[cmdName].Lang)..'/'..shex,
				function(success, body)
					if success then
						local s1, e1 = string.find(body, '<td class=\"trans\"')
						if e1 then
							body = body:sub(e1):gsub('<i>.-</i>', '')
							local counter = 0
							local result = ''
							for v in string.gmatch(body, '<a href=\".-\">(.-)</a>') do
								if not v:match('%.$') then
									result = result..v..', '
									counter = counter + 1
									if counter >= PowerChatCommands[cmdName].Amount then
										break
									end
								end
							end

							if result ~= '' then
								PowerChat:OutPut(chatName, s..': '..result, Color.green)
							else
								PowerChat:OutPut(chatName, 'Something went wrong', Color.red)
							end
						end
					else
						PowerChat:OutPut(chatName, 'Something went wrong', Color.red)
					end
					if i == #args then
						PowerChatCommands[cmdName].CurLang = nil
					end
				end
			)
	end
end

PowerChatCommands[cmdName].Lang = 'en/fr'
PowerChatCommands[cmdName].Amount = 3

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Translates words into another language', Color.yellow)
	PowerChat:OutPut(chatName, 'dict [-(l1)-(l2)] [-set] [-r] [-(num)] [-lang] [word1, word2...]', Color.yellow)
	PowerChat:OutPut(chatName, '-l1-l2 = lang1 lang 2; -set = remember languages;', Color.yellow)
	PowerChat:OutPut(chatName, '-r = reverse langs; -num = number of translations; -lang = current langs', Color.yellow)
end