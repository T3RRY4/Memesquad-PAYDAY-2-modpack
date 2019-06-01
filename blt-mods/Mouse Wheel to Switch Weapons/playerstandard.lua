local function held(key)
	if not (managers and managers.hud) or managers.hud._chat_focus then
		return false
	end
	
	key = tostring(key)
	if key:find("mouse ") then 
		if not key:find("wheel") then 
			key = key:sub(7)
		end
		return Input:mouse():down(Idstring(key))
	else
		return Input:keyboard():down(Idstring(key))
	end
end

Hooks:PreHook(PlayerStandard,"_get_input","scrollwheelweapon_update",function(self,t,dt)
	
	local inputs = {}
	local release_inputs = {}
	local key_1 = "mouse wheel up"
	local key_2 = "mouse wheel down"
	
	if HoldTheKey then 
		local h_1 = HoldTheKey:Get_BLT_Keybind("sws_bind_1")
		local h_2 = HoldTheKey:Get_BLT_Keybind("sws_bind_2")
		if h_1 and (h_1 ~= "") then
			key_1 = h_1
		end
		if h_2 and (h_2 ~= "") then
			key_2 = h_2
		end
	
		if HoldTheKey:Key_Held(key_1) or HoldTheKey:Key_Held(key_2) then 
			self:force_input({btn_switch_weapon_press = true})
		end
	else
		if held(key_1) or held(key_2) then 
			self:force_input({btn_switch_weapon_press = true})
		end
	end
	
end)