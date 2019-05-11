
-- Perform initializations relevant to this mod. Piggybacks on this file as BLT offers no way to load a Lua script as a non-hook
-- in its mod definition file format (specifying "null" for hook_id causes the init script to never be executed, and using "*" is
-- obviously out of the question as that executes the file for *everything*)
-- NOTE: Because this script (copmovement.lua) is responsible for loading init.lua, it must *always* be the first hook entry
-- defined in mod.txt
dofile(ModPath .. "init.lua")

------------
-- Purpose: Hooks CopMovement:action_request() for unit tracking and contour application, and CopMovement:pre_destroy() for unit
--          deregistration prior to unit deletion
------------

-- Known action_desc.variant values:
-- hands_up -> The first action a unit does when surrendering ("Hands up!")
-- hands_back -> The unit places the weapon down by their side ("Get down on your knees!" / "Kneel down!")
-- tied -> The unit has completely surrendered ("Handcuff yourself!" / "Cuff yourself!")
-- tied_all_in_one -> Domination in stealth, or when a minion re-surrenders for a hostage trade
-- idle / stand -> Standard actions that any active unit (minions inclusive, but not dominated units) will do
-- attached_collar_enter -> This unit is being converted into a minion (see CopBrain:convert_to_criminal())
-- untie -> This unit is rescuing another unit, such as a civilian or dominated cop (see CopLogicIntimidated.register_rescue_SO())

-- UNDONE: Using a pre-hook for this is unnecessary
local action_request_actual = CopMovement.action_request
function CopMovement:action_request(action_desc)
	-- Allow the game code to do whatever it needs to do first
	local result = action_request_actual(self, action_desc)

	-- The following code is reentrant (due to the way the game code and this hook works) so it may be confusing to read at first

	local thisunit = self._unit

	-- Ignore civilians (yes, they actually /are/ cops)
	if managers.enemy:is_civilian(thisunit) then
		return result
	end

	-- Only interested in actions
	if action_desc.type == nil or action_desc.type ~= "act" then
		return result
	end

	-- Compatibility with Movable Intimidated Cops (ignore all units being manipulated by it)
	if thisunit:base().mic_is_being_moved ~= nil then
		return result
	end

	-- Since the contour is vital and it is going to be referenced repeatedly in the following code, cache a reference to it
	-- now (or bail out early if it doesn't exist on this unit)
	local contour = thisunit:contour()
	if not contour then
		return result
	end

	if action_desc.variant == "hands_up" or action_desc.variant == "hands_back" then
		-- Just in case, but I doubt this actually has any use since only non-specials can be dominated, and since only
		-- specials can be marked... Yeah. Or with Sixth Sense / omniscience. But it was in the original code, so I'm not
		-- going to remove it (yet)
		contour:remove("mark_enemy", true)
		contour:remove("mark_enemy_damage_bonus", true)

		if IntimidatedOutlines.TrackedUnits[thisunit] ~= nil then
			-- Already tracking this unit, do not add another contour as they are reference counted (i.e. every call to add()
			-- /must/ have a matching call to remove() with the same type, unless the contour type has a fadeout value). If you
			-- do not understand the concept of reference counting, read up on mutexes and deadlocks, the reason you should not
			-- call ContourExt:add() twice should then become obvious (albeit with far less severe consequences)
			-- This can occasionally happen when a unit surrenders twice (e.g. getting ignored the first time so it returns to
			-- its normal stance, but then surrendering again on a second domination attempt. This second attempt appears to
			-- bypass the "hands_up" action at random, so the above check catches both of them as a failsafe)
			return result
		end

		-- Don't bother with contour color changing, the friendly contour color is obvious enough for most players to know
		-- that they should stop shooting (field-tested and proven true). If anything, the hostage_trade contour color ends
		-- up confusing players more
		contour:add(IntimidatedOutlines.ContourTypeToApply, true)

		-- This unit needs to be tracked from now on since a contour has been placed on it by this mod
		IntimidatedOutlines.TrackedUnits[thisunit] = true

	elseif action_desc.variant == "tied_all_in_one" then
		-- This will occur under two circumstances: 
		-- 1) When a guard is dominated in stealth (see CopLogicIntimidated._start_action_hands_up())
		-- 2) When a minion re-surrenders for a hostage trade (see CopLogicTrade.hostage_trade())

		-- Is this unit being tracked?
		local masterunit = IntimidatedOutlines.TrackedUnits[thisunit]
		if masterunit ~= nil then
			if type(masterunit) ~= "boolean" then
				-- This is a minion that has re-surrendered, remove the contour that was placed on it earlier so that the correct
				-- contour will be seen
				-- NOTE: If you have enabled PocoHud's 'Show converted enemy' feature, PocoHud's code will continue to
				-- (incorrectly) stomp away the generic_interactable contour color since it does not account for minion
				-- re-surrenders. That is a bug in PocoHud and not this mod. Disabling it will permit this code to function
				-- correctly and allow the contour to revert to the correct color again
				-- HACKHACK --
				-- Forcefully removing the minion from PocoHud's memory to work around this. It only works for the local player,
				-- though
				if IntimidatedOutlines.PocoHudHack_ReSurrender and PocoHud3 and PocoHud3.Stat and PocoHud3Class and PocoHud3Class.O and PocoHud3Class.O:get('float', 'showConvertedEnemy') then
					local playerindex = 0
					if IntimidatedOutlines.ActiveTrackMasterMode == IntimidatedOutlines.TrackMasterModes.Unit then
						playerindex = managers.network:session():peer_by_unit(masterunit):id()
					else
						playerindex = masterunit
					end
					PocoHud3:Stat(playerindex, "minion", 0)
				end
				-- HACKHACK --
				contour:remove(IntimidatedOutlines.ContourTypeToApply, true)
				-- Ignore this unit from now on, whatever happens to it from now on is no longer of concern
				IntimidatedOutlines.TrackedUnits[thisunit] = nil
				-- Ping the contour so it will undo the previous contour color override (and return to generic_interactable)
				-- Since this unit has been unregistered from the TrackedUnits table, the ContourExt:_upd_color() hook will no
				-- longer override its contour color. If PocoHudHack_ReSurrender is true, this ping helps PocoHud revert its
				-- color override
				contour:_upd_color()
			end
		elseif managers.groupai:state():whisper_mode() then
			-- This unit needs to be tracked since it has surrendered so that a contour can be applied on it if the heist
			-- goes loud
			IntimidatedOutlines.TrackedUnits[thisunit] = true
		end

	else
		-- Okay, so it's not an intimidation-specific action. Is it being triggered on a tracked unit?
		local masterunit = IntimidatedOutlines.TrackedUnits[thisunit]
		if masterunit == nil then
			-- Untracked unit; ignore
			return result
		end

		if type(masterunit) == "boolean" then
			-- This is a tracked unit that has not been converted to a minion. CopLogicIdle.on_new_objective() is not hooked as
			-- it only executes on the server, yet this mod must be capable of running independently on clients without any
			-- additional support from the server. Hence these checks being placed here, along with the enclosed code within
			if action_desc.variant == "idle" or action_desc.variant == "stand" then

-- NOTE: Requires a fix in Moveable Intimidated Cop's CopBrain:on_hostage_move_interaction() hook to ensure it sets
-- self._unit:base().mic_is_being_moved before calling action_request(), otherwise this mod will mistakenly untrack the unit

				-- Dominated units are not supposed to be moving around or otherwise doing anything, this unit must have been
				-- freed by a cop (or traded as a hostage). Remove its friendly contour - this unit is now an enemy (again)
				-- This is placed here because these actions can be performed by any active cop, so there is a need
				-- to filter out all the other untracked units. Other related actions (e.g. "run", "turn") could also be
				-- caught here, but there is not much point in doing so as the first thing a unit will do upon being freed is
				-- stand back up again
				contour:remove(IntimidatedOutlines.ContourTypeToApply, true)
				-- Stop tracking this unit, whatever happens to it from now on is no longer of concern
				IntimidatedOutlines.TrackedUnits[thisunit] = nil
			end
		end		-- type(masterunit) == "boolean"
	end		-- action_desc.variant if-elseif-else checks

	return result
end

-- Clean up when the heist is complete if the unit is still being tracked (called on both servers and clients)
local pre_destroy_actual = CopMovement.pre_destroy
function CopMovement:pre_destroy()
	if IntimidatedOutlines.TrackedUnits[self._unit] then
		IntimidatedOutlines.TrackedUnits[self._unit] = nil
	end

	pre_destroy_actual(self)
end
