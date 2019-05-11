local orig_damage = PlayerDamage.damage_fall
function PlayerDamage:damage_fall(...)
	if self._unit:movement():current_state()._state_data.on_ladder then
		return --no damage if you're using the slide-down-ladders feature
	end
	return orig_damage(self,...)
end