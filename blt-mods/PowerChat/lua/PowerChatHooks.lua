local thisPath
local function GetPath()
	thisPath = debug.getinfo(2, "S").source:sub(2)
end
GetPath()
GetPath = nil

local CM_init_orig = ChatManager.init
function ChatManager:init()
	CM_init_orig(self)
	
	local thisDir = string.match(thisPath, '.*/')

	dofile(thisDir..'PowerChat.lua')
	dofile(thisDir..'PowerChatCommands.lua')
	
	if not PowerChat or not PowerChat.status then
		log("[PowerChat] PowerChat failed to load.")
		PowerChat = nil
		return
	end
	PowerChat:Init()
end

local CM_send_orig = ChatManager.send_message
function ChatManager:send_message(channel_id, sender, message)
	if not PowerChat then
		CM_send_orig(self, channel_id, sender, message)
		return
	end
	
	if PowerChat.Replacements then
		for k,v in pairs(PowerChat.Replacements) do
			message = message:gsub(PowerChat.settings.repl_sym..k,v)
		end
	end
	
	local cmd_repl = PowerChat:Unmagic(PowerChat.settings.repl_sym..PowerChat.settings.sym)..'[^'..PowerChat:Unmagic(PowerChat.settings.sym)..']-[^'..PowerChat:Unmagic(PowerChat.settings.repl_sym)..']'..PowerChat:Unmagic(PowerChat.settings.sym)
	local m = message:match(cmd_repl)
	while m do
		message = message:gsub(PowerChat:Unmagic(m), PowerChat:Parse(m:sub(3,#m-1), false, true) or 'nil_CM:send')
		m = message:match(cmd_repl)
	end
	
	if message:sub(1,1) == PowerChat.settings.sym then
		local hj = PowerChat.settings.hijack_chat == 'true'
		
		PowerChat:Parse(message:sub(2))
		
		if managers.menu_component._game_chat_gui then
			managers.menu_component._game_chat_gui._enter_loose_focus_delay = true
			managers.menu_component._game_chat_gui:_loose_focus()
		end
		
		if hj then
			return
		end
	end
	
	CM_send_orig(self, channel_id, sender, message)
end