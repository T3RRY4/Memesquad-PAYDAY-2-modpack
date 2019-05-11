local old_blm_set_revive_boost = PlayerDamage.set_revive_boost
local old_blm_revive = PlayerDamage.revive
local old_blm_init = PlayerDamage.init
local old_blm_set_health = PlayerDamage.set_health

function PlayerDamage:init(unit)
	old_blm_init(self,unit)
	if not Berserker_Help_mod._diff_mult_loaded then
		Berserker_Help_mod.available_mult_num[1] = tweak_data.player.damage.REVIVE_HEALTH_STEPS[1]
		Berserker_Help_mod._diff_mult_loaded = true
	end
	Berserker_Help_mod:Set_Player_Damage(self)
	Berserker_Help_mod:AdjustFixed()
	self:replenish()
end

function PlayerDamage:set_revive_boost(revive_health_level)
	if not Berserker_Help_mod._settings.combat_cancer then
		old_blm_set_revive_boost(self,revive_health_level)
	else
		if not Berserker_Help_mod:AffectedBuild() then
			old_blm_set_revive_boost(self,revive_health_level)
		end
	end
end

function PlayerDamage:revive(helped_self)
	
	if Berserker_Help_mod:AffectedBuild() and Berserker_Help_mod._enabled and not Berserker_Help_mod._settings.disable then
		tweak_data.player.damage.REVIVE_HEALTH_STEPS = { Berserker_Help_mod.available_mult_num[Berserker_Help_mod._settings.multiplier] }
	else
		tweak_data.player.damage.REVIVE_HEALTH_STEPS ={ Berserker_Help_mod.available_mult_num[1] }
	end
	old_blm_revive(self,helped_self)
end