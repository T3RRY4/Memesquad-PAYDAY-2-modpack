local start_eff_orig = FireManager._start_enemy_fire_effect
function FireManager:_start_enemy_fire_effect(...)
	if #self._doted_enemies > 3 then
		return
	end
	return start_eff_orig(self, ...)
end