
------------
-- Purpose: Hooks ContourExt:_upd_color() to override the contour color seen on a minion unit for the local player (only)
------------

-- This hook is unnecessary if the PocoHud hack is active
if IntimidatedOutlines.PocoHudHack_Register then
	return
end

local idstr_contour_color = Idstring("contour_color")

-- This hook is needed because of how useless ContourExt:change_color() is. Its downside is performance - it runs every single
-- time a new contour appears or an existing one changes (e.g. when special enemies are marked). Also note that this hook
-- completely disregards the topmost (i.e. the contour with the highest priority) contour's type. It could be a
-- "mark_enemy_damage_bonus", "taxman", or "mark_unit" contour and not a "friendly" one - this hook does not care. It simply
-- forces the color to that of the minion's master (yes, PocoHud's hook disregards contour types as well, which is why there is a
-- contour color bug when a minion re-surrenders because PocoHud still thinks that the minion is in its normal, active state)

--[[
-- Old hook stuff, disregard this block

if IntimidatedOutlines_ContourExt___upd_color_actual == nil then
	IntimidatedOutlines_ContourExt___upd_color_actual = ContourExt._upd_color
else
--	log("Warning: IntimidatedOutlines_ContourExt___upd_color_actual() already defined, ignoring")
	return
end
function ContourExt:_upd_color(is_retry)

	-- Call the original function so it will set the contour up as usual, whose color will be overriden by the following code
--	IntimidatedOutlines_ContourExt___upd_color_actual(self, is_retry)
]]
if IntimidatedOutlines_ContourExt___upd_color_Hook ~= nil then
--	log("Warning: IntimidatedOutlines_ContourExt___upd_color_Hook() already defined, ignoring")
	return
end
IntimidatedOutlines_ContourExt___upd_color_Hook = function(self, is_retry)

	local masterunit = IntimidatedOutlines.TrackedUnits[self._unit]
	-- Disregard untracked units (e.g. marked special enemy) and dominated units that have not been converted into minions
	if masterunit == nil or type(masterunit) == "boolean" then
		return
	end

	-- Determine the color to use based on the master player's index

	local playerindex = 1

	if IntimidatedOutlines.ActiveTrackMasterMode == IntimidatedOutlines.TrackMasterModes.Unit then
		-- Yay for PlayerManager:player_id() failing to do the one job it had: getting the ID of any player unit. Instead, all it
		-- does is search the PlayerManager._players table and default to the host player unit if it is unable to find the given
		-- player unit. That's fine and well, but there's just one problem. What /is/ in that table? Surprise, surprise - *only*
		-- the host player unit. Yes, even when playing as a client and not a host. Seriously - traverse its contents and see for
		-- yourself [/EndRant]
--		playerindex = managers.player:player_id(masterunit) or 5
		-- Proper fix
		playerindex = managers.network:session():peer_by_unit(masterunit):id() or 5
	else
		-- No derivation necessary - the master's index is already stored in the table
		playerindex = masterunit
	end

	-- Shamelessly stolen from PocoHud
	local minionClr = Vector3(tweak_data.chat_colors[playerindex]:unpack())
	for __, material in ipairs(self._materials or {}) do
		material:set_variable(idstr_contour_color, minionClr)
	end
end

-- Setting this up as a post hook to allow the original function to set the contour up as usual, whose color will then be
-- overriden by the hook


-- Hooks are automatically removed when a heist starts or restarts, so no cleanup code is necessary
