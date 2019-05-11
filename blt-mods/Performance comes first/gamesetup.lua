PerformanceComesFirstFPS = PerformanceComesFirstFPS or 50

local mans = {
	'enemy',
	'groupai',
	'spawn',
	'navigation',
	'killzone',
	'game_play_central',
	'trade',
	'dot',
	'fire',
	'statistics',
	'time_speed',
	'objectives',
	'explosion',
	'motion_path',
	'wait',
	'achievment',
	'skirmish'
}
local dts = {}
local current = 1
local allowed = 10
local FPS_on_screen
local upd_orig = GameSetup.update
function GameSetup:update(t, dt)
	-- Another reason not to use BLT's hooks
	if BLT and Hooks then
		Hooks:Call("GameSetupUpdate", t, dt)
	end

	Setup.update(self, t, dt)
	
	managers.interaction:update(t, dt)
	
	for k,v in ipairs(mans) do
		dts[v] = (dts[v] or 0) + dt
	end
	
	local fps = 1/dt
	if CopDamage then
		if fps < PerformanceComesFirstFPS then
			allowed = allowed - 1
		else
			allowed = allowed + 1
		end
		allowed = math.min(10, math.max(2, allowed))
	end
	
	for i = 1, allowed do
		managers[mans[current]]:update(t, dts[mans[current]])
		dts[mans[current]] = 0
		if current == #mans then
			current = 1
		else
			current = current + 1
		end
	end
	
	managers.hud:update(t, dt)

	if current == 6 or current == 14 then
		FPS_on_screen(fps)
	end

	if script_data.level_script and script_data.level_script.update then
		script_data.level_script:update(t, dt)
	end

	self:_update_debug_input()
end

local FPS_ws
local FPS_pnl
local FPS_text
local good_fps = 1
local total_fps = 1
FPS_on_screen = function(fps_value)
	if not FPS_ws then
		FPS_ws = managers.gui_data:create_fullscreen_workspace()
		FPS_pnl = FPS_ws:panel():panel({ name = 'fps_pnl' , layer = 1000})
		FPS_text = FPS_pnl:text{text='FPS PANEL', font='fonts/font_medium_mf', font_size = 22, color = Color(0,0,1), x=50,y=100, layer=0}
	end
	
	if not PerformanceComesFirstDisplay then
		FPS_text:set_visible(false)
		return
	else
		FPS_text:set_visible(true)
	end
	
	fps_value = math.floor(fps_value + 0.5)
	
	local good = fps_value >= PerformanceComesFirstFPS
	
	if good then
		good_fps = good_fps + 1
	end
	
	total_fps = total_fps + 1
	
	local percentage = math.floor(100 * good_fps/total_fps)
	
	FPS_text:set_text(tostring(fps_value) .. ' (' .. (total_fps > 3 and percentage or '?').. '%)')
	FPS_text:set_color(percentage > 49 and Color(0,1,0) or Color(1,0,0))
	
	if total_fps > 3 * fps_value then
		good_fps = 1
		total_fps = 1
	end
end