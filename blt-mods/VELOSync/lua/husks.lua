local isFastResolve=false
VELOSync.orighusk = HuskPlayerMovement._get_max_move_speed
if VELOSync.orighusk == nil then
	isFastResolve=false
	log("[VELOSync][ERR] HuskPlayerMovement._get_max_move_speed is nil")
	return
end
local function isInGame()
	if not game_state_machine then
		return false
	end
	return string.find( game_state_machine:current_state_name(), "ingame" )
end

function VELOSync:_showhint(_text)
	if managers.hud then
		managers.hud:show_hint({text=_text})
	end
end
function VELOSync:loaddefhusk()
	function HuskPlayerMovement:_get_max_move_speed(...)
    return VELOSync.orighusk(self, ...) * VELOSync._data.vshusk_default
	end
end

function VELOSync:loadcustomhuskspeed(_speed)
	function HuskPlayerMovement:_get_max_move_speed(...)
  	return VELOSync.orighusk(self, ...) * _speed
	end
end

function VELOSync:startfastresolve()
	isFastResolve=true
	VELOSync:_showhint(managers.localization:text("vs_start_fad"))
	VELOSync:loadcustomhuskspeed(VELOSync._data.vshusk_fast)
	DelayedCalls:Add("vs_resetdesync", 3, function()
		isFastResolve=false
		VELOSync:_showhint(managers.localization:text("vs_end_fad"))
		VELOSync:loaddefhusk()
	end)
end

VELOSync:loaddefhusk()
