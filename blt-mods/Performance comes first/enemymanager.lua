local upd_gfx_lod_orig = EnemyManager._update_gfx_lod
local toggle = true
function EnemyManager:_update_gfx_lod(...)
	if toggle then
		upd_gfx_lod_orig(self, ...)
		toggle = false
	else
		toggle = true
	end
end