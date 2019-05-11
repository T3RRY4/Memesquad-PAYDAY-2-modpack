
------------
-- Purpose: Initializes the IntimidatedOutlines table as defined below. Options are prefixed with the 'OPTION:' tag
------------

IntimidatedOutlines = {}

-- This table will contain all units to be tracked (dominated units, minions and their masters). Entries are accessed by (cop)
-- unit. Dominated units are distinguished from converted minions by the following properties:
-- If a unit has been dominated (but not converted), the stored value will be a boolean
-- When a unit is converted, the boolean value will be replaced with the new minion's master (formerly the actual player unit,
-- now just the player's index - behavior is determined by IntimidatedOutlines.ActiveTrackMasterMode below)
-- Because booleans are used, avoid using brief checks such as:
--    if IntimidatedOutlines.TrackedUnits[unit] then  OR  if not IntimidatedOutlines.TrackedUnits[unit] then
-- Instead, always keep the checks explicit:
--    if IntimidatedOutlines.TrackedUnits[unit] ~= nil then  OR  if IntimidatedOutlines.TrackedUnits[unit] == nil then
-- In other words:
-- type(IntimidatedOutlines.TrackedUnits[unit]) == "boolean"	<-- This is a dominated unit
-- type(IntimidatedOutlines.TrackedUnits[unit]) ~= "boolean"	<-- This is a converted minion
-- IntimidatedOutlines.TrackedUnits[unit] == nil				<-- This is an untracked unit and should be ignored
-- Of course, it's also possible to squeeze a new value into a given unit for the purpose of tracking it, but that feels icky to
-- me as it violates the "Don't Modify Objects You Don't Own" principle
-- UNTESTED: What about players who disconnect after converting a minion? What happens to their entries?
IntimidatedOutlines.TrackedUnits = {}

-- OPTION: See ContourExt._types (lib/units/contourext.lua) for valid contour types. Also note that ContourExt:change_color() is
-- completely worthless when dealing with the "friendly" contour type. Instead, a ContourExt:_upd_color() hook is used to
-- override the color seen by the local player (just like PocoHud does). Recommended to leave it set to "friendly" to avoid
-- unnecessary player confusion
IntimidatedOutlines.ContourTypeToApply = "friendly"

-- 0 = minion masters are tracked by player unit, 1 = minion masters are tracked by player index (more efficient)
IntimidatedOutlines.TrackMasterModes = {Unit = 0, Index = 1}

-- OPTION: Set this to one of the above values for IntimidatedOutlines.TrackMasterModes
IntimidatedOutlines.ActiveTrackMasterMode = IntimidatedOutlines.TrackMasterModes.Index

-- OPTION: This controls whether minions are forcefully registered in PocoHud's stats table by this mod (thus allowing PocoHud to
-- correctly colorize their contours, but only for the local player and not other PocoHud users who do not have this mod
-- installed). It also determines whether this mod's own ContourExt:_upd_color() hook is applied. Set to true to enable the
-- abovementioned behavior and disable this mod's ContourExt:_upd_color() hook, or false to disable writing to PocoHud's table
-- and enable this mod's ContourExt:_upd_color() hook. If uncertain about the implications and / or benefits of either mode, or
-- not using PocoHud, then simply leave this set to false
IntimidatedOutlines.PocoHudHack_Register = false

-- OPTION: This controls whether minions are forcefully deregistered from PocoHud's stats table by this mod (thus allowing
-- PocoHud to correctly remove its contour color override when minions re-surrender for hostage trading, but only for the local
-- player and not other PocoHud users who do not have this mod installed). It should really be fixed in PocoHud and not this mod,
-- but whatever... Set to true to enable the abovementioned behavior, otherwise false. This setting has no effect if PocoHud is
-- not installed
IntimidatedOutlines.PocoHudHack_ReSurrender = true

-- Iterates through all tracked units and applies the "friendly" contour on each. Called whenever the heist goes loud
IntimidatedOutlines.MarkAllTrackedUnits = function()
	local has_contour
	for unit, dummy in pairs(IntimidatedOutlines.TrackedUnits) do
		if dummy ~= nil then
			has_contour = false
			local contour = unit:contour()
			if contour then
				-- Does this unit already have a "friendly" contour?
				if contour._contour_list ~= nil then
					for __, setup in ipairs(contour._contour_list) do
						if setup.type == IntimidatedOutlines.ContourTypeToApply then
							has_contour = true
							break
						end
					end
				end
				if not has_contour then
					-- This unit does not have a "friendly" contour, apply one now
					contour:add(IntimidatedOutlines.ContourTypeToApply, true)
				end
			end
		end
	end
end
