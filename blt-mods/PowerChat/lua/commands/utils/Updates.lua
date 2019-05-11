--[[ Checks updates for PowerChat
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'updates'
local chatName = 'UPDATES'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function()
	Steam:http_request(
		'https://modworkshop.net/mydownloads.php?action=view_down&did=21411',
				function(success, body)
					if success then
						local ver = body:match('<strong>Version ([%d%.]+)</strong>')

						if ver and BLT and BLT.Mods and BLT.Mods.GetMod then
							
							local pc = BLT.Mods:GetMod(debug.getinfo(1, "S").source:sub(2):match('mods/(.-)/'))
							local curver = pc and pc:GetVersion() or ''
							
							if ver ~= curver then
								PowerChat:OutPut(chatName, 'A newer version of PowerChat is available at modworkshop.net', Color.purple)
							else
								PowerChat:OutPut(chatName, 'You are using the latest version of PowerChat', Color.green)
							end
						end
					end
				end
			)
end

--local s = PowerChat.settings.sym
--local o = PowerChat.settings.opt_sym
--local a = PowerChat.settings.and_sym
-- !every -30 !updates&every-stop !updates
--PowerChat:Parse(s..'every '..o..'30 '..s..'updates'..a..'every-stop '..s..'updates')