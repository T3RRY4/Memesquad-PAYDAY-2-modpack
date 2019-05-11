Hooks:PreHook(IngameWaitingForPlayersState, "at_enter", "MenuBgsAtEnter", function(self)
	if not MenuBackgrounds.Options.blackscreen then
		return
	end
	if not managers.hud:exists(self.LEVEL_INTRO_GUI) then
		managers.hud:load_hud(self.LEVEL_INTRO_GUI, false, false, false, {})
	end
end)