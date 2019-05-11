local _update_check_actions_driver = PlayerDriving._update_check_actions_driver

function PlayerDriving:_update_check_actions_driver(t, dt, input)
	local projectile_entry = managers.blackmarket:equipped_projectile()
	local projectile_tweak = tweak_data.blackmarket.projectiles[projectile_entry]
	
	_update_check_actions_driver(self, t, dt, input)

	if projectile_tweak.ability then
		self:_check_action_use_ability(t, input)
	end
end