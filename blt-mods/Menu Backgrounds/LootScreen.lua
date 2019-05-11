Hooks:PostHook(HUDLootScreen, "init", "MenuBGsInit", function(self)
	self._backdrop:set_background("loot")
end)

Hooks:PostHook(HUDLootScreen, "show", "MenuBGsShow", function(self)
	if MenuBackgrounds.Options.loot and alive(self._video) then
		self._video:hide()
	end
end)