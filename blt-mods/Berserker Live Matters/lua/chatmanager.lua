Hooks:PreHook(ChatManager, "receive_message_by_peer", "Berserker_Help_mod_receive_disable", function(self, channel_id, peer, message)
	if channel_id == 4 and peer:is_host() then
		if message == Berserker_Help_mod._disable_msg then
			Berserker_Help_mod._enabled = false
		end
		if message == Berserker_Help_mod._disable_dlg then
			DelayedCalls:Add("Delayed_Berserker_Help_mod_disable_msg", 1, function()
					managers.chat:_receive_message(1, "[" .. managers.localization:text("Berserker_Help_mod_main_menu_title") .. "]", managers.localization:text("Berserker_Help_mod_lobby_disabled") , Color.yellow)
				end)
		end
		if message == Berserker_Help_mod._enable_dlg then
			DelayedCalls:Add("Delayed_Berserker_Help_mod_enable_msg", 1, function()
					managers.chat:_receive_message(1, "[" .. managers.localization:text("Berserker_Help_mod_main_menu_title") .. "]", managers.localization:text("Berserker_Help_mod_lobby_enabled") , Color.yellow)
				end)
			Berserker_Help_mod._enabled = true
		end
		Berserker_Help_mod:AdjustFixed()
	end
end)