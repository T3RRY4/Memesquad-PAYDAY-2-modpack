-- Remove Visual Shake
-- INITIAL RELEASE
-- NO DL
-- It removes visual kicking
-- NO OTHER

function PlayerCamera:play_shaker(effect, amplitude, frequency, offset)
	if _G.IS_VR then
		return
	end
	return self._shaker:play(effect, amplitude or 0, frequency or 0, offset or 0)
end