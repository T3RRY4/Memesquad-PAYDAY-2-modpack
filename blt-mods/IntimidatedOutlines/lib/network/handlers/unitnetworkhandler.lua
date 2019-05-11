
------------
-- Purpose: Hooks UnitNetworkHandler:mark_minion() to properly handle conversions of dominated units to minions (client-side)
------------

-- This code only runs on the client, the corresponding server-side code is in GroupAIStateBase:convert_hostage_to_criminal()
-- Much of this function is stock code, changes are denoted between -- BEGIN MOD -- and -- END MOD --
-- Maintenance notice: Since this is essentially mirroring the game's code verbatim, future updates to the game's code might
-- cause the code in this function to become stale and outdated, leading to unexplained bugs or other strange issues. As much as
-- I would like to avoid doing so, this function does not return anything that could be used to determine if the conversion was
-- valid. Sure, I could check managers.groupai:state():is_enemy_converted_to_criminal() since this code is client-side, but by
-- that point the contour would already have been applied on the unit (i.e. too late). At this point, I can only hope that this
-- function's code does not change further down the road...
function UnitNetworkHandler:mark_minion(unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end
	local health_multiplier = 1
	if convert_enemies_health_multiplier_level > 0 then
		health_multiplier = health_multiplier * tweak_data.upgrades.values.player.convert_enemies_health_multiplier[convert_enemies_health_multiplier_level]
	end
	if passive_convert_enemies_health_multiplier_level > 0 then
		health_multiplier = health_multiplier * tweak_data.upgrades.values.player.passive_convert_enemies_health_multiplier[passive_convert_enemies_health_multiplier_level]
	end
	unit:character_damage():convert_to_criminal(health_multiplier)
	-- BEGIN MOD --
	if IntimidatedOutlines.TrackedUnits[unit] then
		if IntimidatedOutlines.ActiveTrackMasterMode == IntimidatedOutlines.TrackMasterModes.Unit then
			-- Jumping through all these hoops just to get the master unit, and why? Because PlayerManager:player_unit() has
			-- just one job and doesn't even do it right. Why not? Because PlayerManager._players holds *only* the host unit and
			-- no other players [/EndRant]
			local minion_owner_peer = managers.network:session():peer(minion_owner_peer_id)
			if minion_owner_peer then
				local minion_owner_peer_unit = minion_owner_peer:unit()
				if minion_owner_peer_unit then
					-- This tracked unit is about to become a minion, store the minion's master in the TrackedUnits table
					IntimidatedOutlines.TrackedUnits[unit] = minion_owner_peer_unit
				else
					-- Failed for some obscure reason, stop tracking this minion
					log("[IntimidatedOutlines|UnitNetworkHandler:mark_minion()] minion_owner_peer_unit is nil")
					IntimidatedOutlines.TrackedUnits[unit] = nil
				end
			else
				-- Failed for some obscure reason, stop tracking this minion
				log("[IntimidatedOutlines|UnitNetworkHandler:mark_minion()] minion_owner_peer is nil")
				IntimidatedOutlines.TrackedUnits[unit] = nil
			end
		else
			-- This tracked unit is about to become a minion, store the minion's master in the TrackedUnits table
			IntimidatedOutlines.TrackedUnits[unit] = minion_owner_peer_id
		end
		-- Remove the synced contour that was added on this unit earlier in CopMovement:action_request(). This is placed here to
		-- ensure the contour gets removed even if any of the above checks fail
		unit:contour():remove(IntimidatedOutlines.ContourTypeToApply, true)

		-- HACK: Force PocoHud to register this minion
		-- Here you go, PocoHud! The downside of this hackish workaround? It only works for the local player, so all other
		-- PocoHud users who do not have this mod installed are still screwed anyway  :<
		if IntimidatedOutlines.PocoHudHack_Register and PocoHud3 and PocoHud3.Stat and PocoHud3Class and PocoHud3Class.O and PocoHud3Class.O:get('float', 'showConvertedEnemy') then
			PocoHud3:Stat(minion_owner_peer_id, "minion", unit)
		end

		-- Honestly, though, the best way to deal with this race condition is to delay the calls to ContourExt:add() (for the
		-- host) and mark_minion (for connected clients). That should allow enough time for all PocoHud instances on all players
		-- to register the minion, after which enabling the contour will cause it to have its color overridden correctly (by
		-- PocoHud)
		-- HACK --

	end
	-- This is /the/ contour that PocoHud acts on (and this mod's own hook, too)
	-- END MOD --
	unit:contour():add("friendly", false)
	managers.groupai:state():sync_converted_enemy(unit)
	if minion_owner_peer_id == managers.network:session():local_peer():id() then
		managers.player:count_up_player_minions()
	end
end
