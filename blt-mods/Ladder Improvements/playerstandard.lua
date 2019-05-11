


--too lazy to check which of these are actually needed, especially since i might need them again later if i change the mod
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize

local temp_vec1 = Vector3()

local tmp_ground_from_vec = Vector3()
local tmp_ground_to_vec = Vector3()
local up_offset_vec = math.UP * 30
local down_offset_vec = math.UP * -40

local win32 = SystemInfo:platform() == Idstring("WIN32")

local mvec_pos_new = Vector3()
local mvec_achieved_walk_vel = Vector3()
local mvec_move_dir_normalized = Vector3()


local orig_check_jump = PlayerStandard._check_action_jump
function PlayerStandard:_check_action_jump(t, input)
	if input.btn_jump_press then 
		--don't need to check for action forbidden or cooldown, since this only applies to ladders
		if self._state_data.ducking then 
			--nothing
		elseif self._state_data.on_ladder then
			self:_interupt_action_ladder(t)
			return --this is the only thing i've really changed: no jumping on ladders >:(
		end
	end
	return orig_check_jump(self,t,input)
end

function PlayerStandard:_check_action_ladder(t, input)
	
	

		local downed = self._controller:get_any_input() --input.downed
		local hold_jump = downed and self._controller:get_input_bool("jump")
		local release_jump = released and self._controller:get_input_released("jump")
		local hold_duck = downed and self._controller:get_input_bool("duck")
		
	if self._state_data.on_ladder then
		local ladder_unit = self._unit:movement():ladder_unit()
		
		
--[[ now redundant since i had to stop players from jumping while on ladders in check_action_jump anyway
		if input.btn_jump_press then 
			self:_end_action_ladder()
		end
		--]]
		if not hold_jump and ladder_unit:ladder():check_end_climbing(self._unit:movement():m_pos(), self._normal_move_dir, self._gnd_ray) then
--			OffyLib:c_log("Quitting ladder from check #1")
			self:_end_action_ladder(t,input) --doesn't really need any arguments but just in case some other modder wants to do something with that
			return
		elseif hold_jump then 
--			OffyLib:c_log("Quitting ladder from check #2")
			self:_end_action_ladder(t,input)
			return
		end

		if hold_duck and self._unit:mover() then
			self._unit:mover():set_gravity(Vector3(0, 0, -982))
			return
		elseif input.btn_duck_release and self._unit:mover() then
			self._unit:mover():set_gravity(Vector3(0,0,0))
			self._unit:mover():set_velocity(Vector3())
		end

	elseif hold_jump then 
		return --if hold jump, don't try to detect ladders + start climbing
	end

--[[ not needed since static checking for ladders uses player cam direction if not moving anyway
	if not (self._move_dir or release_jump) then
		return
	end
--]]

	local u_pos = self._unit:movement():m_pos()
	local ladder_unit

	for i = 1, math.min(Ladder.LADDERS_PER_FRAME, #Ladder.active_ladders), 1 do
		ladder_unit = Ladder.next_ladder()

		if alive(ladder_unit) then

			local can_access = ladder_unit:ladder():can_access(u_pos, self._move_dir or self._ext_camera:forward())
			--if not moving (self._move_dir) then check for valid ladder positions using camera direction
			--this way, player will automatically grab any ladder that they are facing
			--TACTICOOL REALISM WINS AGAIN WOOOO
	
			
			if can_access then
				self:_start_action_ladder(t, ladder_unit)
				break
			end
		end
	end
end

--[[ code scraps

--			local dis = mvector3.distance_sq(self._unit:position(),ladder_unit:position())

function PlayerStandard:_determine_move_direction()
	self._stick_move = self._controller:get_input_axis("move")

	if self._state_data.on_zipline then
		return
	end

	if mvector3.length(self._stick_move) < PlayerStandard.MOVEMENT_DEADZONE or self:_interacting() or self:_does_deploying_limit_movement() then
		self._move_dir = nil
		self._normal_move_dir = nil
	else
		local ladder_unit = self._unit:movement():ladder_unit()

		if alive(ladder_unit) then
			local ladder_ext = ladder_unit:ladder()
			self._move_dir = mvector3.copy(self._stick_move)
			self._normal_move_dir = mvector3.copy(self._move_dir)
			local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)

			mvector3.rotate_with(self._normal_move_dir, cam_flat_rot)

			local cam_rot = Rotation(self._cam_fwd, self._ext_camera:rotation():z())

			mvector3.rotate_with(self._move_dir, cam_rot)

			local up_dot = math.dot(self._move_dir, ladder_ext:up())
			local w_dir_dot = math.dot(self._move_dir, ladder_ext:w_dir())
			local normal_dot = math.dot(self._move_dir, ladder_ext:normal()) * -1
			local normal_offset = ladder_ext:get_normal_move_offset(self._unit:movement():m_pos())

			mvector3.set(self._move_dir, ladder_ext:up() * (up_dot + normal_dot))
			mvector3.add(self._move_dir, ladder_ext:w_dir() * w_dir_dot)
			mvector3.add(self._move_dir, ladder_ext:normal() * normal_offset)
		else
			self._move_dir = mvector3.copy(self._stick_move)
			local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)

			mvector3.rotate_with(self._move_dir, cam_flat_rot)

			self._normal_move_dir = mvector3.copy(self._move_dir)
		end
	end
end

	--don't need to use holdthekey, since i'm tapping input from vanilla pd2 binds directly
	local continue_l = false
	if HoldTheKey:Keybind_Held("keybindid_lad_dismount") then 
		OffyLib:c_log("Dismount ladder")
		OffyLib.doing_ladder = false
		self:_end_action_ladder(t,input)
		return
	elseif not OffyLib.doing_ladder then 
		OffyLib.doing_ladder = true
		OffyLib:c_log("Stopped dismounting ladder keybind")
	end

Hooks:PostHook(PlayerStandard,"_check_action_ladder","playerstandard__check_action_ladder_lad",function(self,t,input)
	if HoldTheKey:Held_Keybind("keybindid_lad_dismount") then 
		OffyLib:c_log("Dismount ladder")
		OffyLib.doing_ladder = false
		self:_end_action_ladder(t,input)
	elseif not OffyLib.doing_ladder then 
		OffyLib.doing_ladder = true
		OffyLib:c_log("Stopped dismounting ladder keybind")
	end
end)

function PlayerStandard:_start_action_ladder(t, ladder_unit)
	self._state_data.on_ladder = true

	self:_interupt_action_running(t)
	self._unit:mover():set_velocity(Vector3())
	self._unit:mover():set_gravity(Vector3(0, 0, 0))
	self._unit:mover():jump()
	self._unit:movement():on_enter_ladder(ladder_unit)
end

function PlayerStandard:_end_action_ladder(t, input)
	if not self._state_data.on_ladder then
		return
	end

	self._state_data.on_ladder = false

	if self._unit:mover() then
		self._unit:mover():set_gravity(Vector3(0, 0, -982))
	end

	self._unit:movement():on_exit_ladder()
end
--]]
