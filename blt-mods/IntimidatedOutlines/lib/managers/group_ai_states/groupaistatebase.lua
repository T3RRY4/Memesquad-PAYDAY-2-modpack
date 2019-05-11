
------------
-- Purpose: Hooks GroupAIStateBase:convert_hostage_to_criminal() to properly handle conversions of dominated units to minions
--          (server-side). Also hooks GroupAIStateBase:on_police_called() and GroupAIStateBase:sync_event() to mark all tracked
--          units if / when a heist goes loud
------------

-- This code only runs on the server, the corresponding client-side code is in UnitNetworkHandler:mark_minion(). Much of this
-- function is stock code, changes are denoted between -- BEGIN MOD -- and -- END MOD --
-- Maintenance notice: Since this is essentially mirroring the game's code verbatim, future updates to the game's code might
-- cause the code in this function to become stale and outdated, leading to unexplained bugs or other strange issues. As much as
-- I would like to avoid doing so, this function does not return anything that could be used to determine if conversion was
-- successful. Sure, I could check unit:brain()._logic_data.is_converted since this code is server-side, but by that point the
-- contour would already have been applied on the unit (i.e. too late). At this point, I can only hope that this function's code
-- does not change further down the road...
function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit)
	local player_unit = peer_unit or managers.player:player_unit()
	if not alive(player_unit) or not self._criminals[player_unit:key()] then
		return
	end
	if not alive(unit) then
		return
	end
	local u_key = unit:key()
	local u_data = self._police[u_key]
	if not u_data then
		return
	end
	local minions = self._criminals[player_unit:key()].minions or {}
	self._criminals[player_unit:key()].minions = minions
	local max_minions = 0
	if peer_unit then
		max_minions = peer_unit:base():upgrade_value("player", "convert_enemies_max_minions") or 0
	else
		max_minions = managers.player:upgrade_value("player", "convert_enemies_max_minions", 0)
	end
	Application:debug("GroupAIStateBase:convert_hostage_to_criminal", "Player", player_unit, "Minions: ", table.size(minions) .. "/" .. max_minions)
	if alive(self._converted_police[u_key]) or max_minions <= table.size(minions) then
		local peer = managers.network:session():peer_by_unit(player_unit)
		if peer then
			if peer:id() == managers.network:session():local_peer():id() then
				managers.hint:show_hint("convert_enemy_failed")
			else
				managers.network:session():send_to_peer(peer, "sync_show_hint", "convert_enemy_failed")
			end
		end
		return
	end
	local group = u_data.group
	u_data.group = nil
	if group then
		self:_remove_group_member(group, u_key, nil)
	end
	self:set_enemy_assigned(nil, u_key)
	u_data.is_converted = true
	unit:brain():convert_to_criminal(peer_unit)
	local clbk_key = "Converted" .. tostring(player_unit:key())
	u_data.minion_death_clbk_key = clbk_key
	u_data.minion_destroyed_clbk_key = clbk_key
	unit:character_damage():add_listener(clbk_key, {"death"}, callback(self, self, "clbk_minion_dies", player_unit:key()))
	unit:base():add_destroy_listener(clbk_key, callback(self, self, "clbk_minion_destroyed", player_unit:key()))
	if not unit:contour() then
		debug_pause_unit(unit, "[GroupAIStateBase:convert_hostage_to_criminal]: Unit doesn't have Contour Extension")
	end
	-- BEGIN MOD --
	if IntimidatedOutlines.TrackedUnits[unit] then
		-- This tracked unit is about to become a minion, store the minion's master in the TrackedUnits table

		local playerindex = managers.network:session():peer_by_unit(player_unit):id()

		if IntimidatedOutlines.ActiveTrackMasterMode == IntimidatedOutlines.TrackMasterModes.Unit then
			IntimidatedOutlines.TrackedUnits[unit] = player_unit
		else
			IntimidatedOutlines.TrackedUnits[unit] = playerindex
		end

		-- HACK: Force PocoHud to register this minion
		-- Here you go, PocoHud! The downside of this hackish workaround? It only works for the local player, so all other
		-- PocoHud users who do not have this mod installed are still screwed anyway  :<
		if IntimidatedOutlines.PocoHudHack_Register and PocoHud3 and PocoHud3.Stat and PocoHud3Class and PocoHud3Class.O and PocoHud3Class.O:get('float', 'showConvertedEnemy') then
			PocoHud3:Stat(playerindex, "minion", unit)
		end

		-- Honestly, though, the best way to deal with this race condition is to delay the calls to ContourExt:add() (for the
		-- host) and mark_minion (for connected clients). That should allow enough time for all PocoHud instances on all players
		-- to register the minion, after which enabling the contour will cause it to have its color overridden correctly (by
		-- PocoHud)
		-- HACK --

		-- Remove the synced contour that was added on this unit earlier in CopMovement:action_request()
		unit:contour():remove(IntimidatedOutlines.ContourTypeToApply, true)
	end
	-- This is /the/ contour that PocoHud acts on (and this mod's own hook, too). Unfortunately for PocoHud, the interval between
	-- contour removal (above) and re-application (below) is so short that its ContourExt:_upd_color() hook gets called before it
	-- even has a chance to store the minion in its own stat table, which causes its hook to disregard the contour instead of
	-- overriding its color. Race conditions, yay
	-- END MOD --
	unit:contour():add("friendly")
	u_data.so_access = unit:brain():SO_access()
	self:_set_converted_police(u_key, unit)
	minions[u_key] = u_data
	unit:movement():set_team(self._teams.converted_enemy)
	local convert_enemies_health_multiplier_level = 0
	local passive_convert_enemies_health_multiplier_level = 0
	if alive(peer_unit) then
		convert_enemies_health_multiplier_level = peer_unit:base():upgrade_level("player", "convert_enemies_health_multiplier") or 0
		passive_convert_enemies_health_multiplier_level = peer_unit:base():upgrade_level("player", "passive_convert_enemies_health_multiplier") or 0
	else
		convert_enemies_health_multiplier_level = managers.player:upgrade_level("player", "convert_enemies_health_multiplier")
		passive_convert_enemies_health_multiplier_level = managers.player:upgrade_level("player", "passive_convert_enemies_health_multiplier")
	end
	local owner_peer_id = managers.network:session():peer_by_unit(player_unit):id()
	managers.network:session():send_to_peers_synched("mark_minion", unit, owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level)
	if not peer_unit then
		managers.player:count_up_player_minions()
	end
end

local on_police_called_actual = GroupAIStateBase.on_police_called
function GroupAIStateBase:on_police_called(called_reason)
	on_police_called_actual(self, called_reason)

	IntimidatedOutlines.MarkAllTrackedUnits()
end

local sync_event_actual = GroupAIStateBase.sync_event
function GroupAIStateBase:sync_event(event_id, blame_id)
	sync_event_actual(self, event_id, blame_id)

	if self.EVENT_SYNC[event_id] == "police_called" then
		IntimidatedOutlines.MarkAllTrackedUnits()
	end
end
