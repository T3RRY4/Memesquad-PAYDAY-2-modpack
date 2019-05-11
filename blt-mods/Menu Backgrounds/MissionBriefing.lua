Hooks:PostHook(HUDMissionBriefing, "init", "MenuBGsInit", function(self)
	if not MenuBackgrounds.Options.briefing then
		return
	end
	self._backdrop:set_background("briefing")
	if alive(self._background_layer_two) and alive(self._background_layer_two:child("panel")) then
		self._background_layer_two:child("panel"):hide()
	end
end)