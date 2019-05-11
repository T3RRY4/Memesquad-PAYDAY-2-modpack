local _update_check_actions = PlayerBipod._update_check_actions

local function nop() end

function PlayerBipod:_update_check_actions(t, dt, paused)
	local projectile_entry = managers.blackmarket:equipped_projectile()
	local projectile_tweak = tweak_data.blackmarket.projectiles[projectile_entry]

	if projectile_tweak.ability then
		local _check_action_use_ability = PlayerBipod._check_action_use_ability
		local getInput = PlayerBipod._get_input
		local input = self:_get_input(t, dt, paused)

		PlayerBipod._get_input = function(t, dt, paused)
			return input
		end

		self:_check_action_use_ability(t, input)
		PlayerBipod._check_action_use_ability = nop
		_update_check_actions(self, t, dt, paused)
		PlayerBipod._check_action_use_ability = _check_action_use_ability
		PlayerBipod._get_input = getInput
	else
		_update_check_actions(self, t, dt, paused)
	end
end
