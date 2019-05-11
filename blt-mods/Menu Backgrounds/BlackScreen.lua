Hooks:PostHook(HUDBlackScreen, "init", "MenuBgsInit", function(self, hud)
	if not MenuBackgrounds.Options.blackscreen then
		return
	end
	MenuBackgrounds:AddBackground(self._blackscreen_panel, "blackscreen")
end)