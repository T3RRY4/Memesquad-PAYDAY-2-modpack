local fire_blnk_orig = NewNPCRaycastWeaponBase.auto_fire_blank
local toggle = true
function NewNPCRaycastWeaponBase:auto_fire_blank(...)
	if toggle then
		fire_blnk_orig(self, ...)
	end
	toggle = not toggle
	return true
end