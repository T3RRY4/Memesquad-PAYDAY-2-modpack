PerformanceComesFirstFPS = PerformanceComesFirstFPS or 50

local mans = {
	'weapon_factory',
	'platform',
	'dyn_resource',
	'savefile',
	'menu_component',
	'player',
	'blackmarket',
	'vote',
	'vehicle',
	'mutators',
	'crime_spree'
}
local dts = {}
local current = 1
local allowed = 8
local toggle = true
local upd_orig = Setup.update
function Setup:update(t, dt)
	local main_t = TimerManager:main():time()
	local main_dt = TimerManager:main():delta_time()

	self:_upd_unload_packages()

	if _G.IS_VR then
		managers.vr:update(t, dt)
	end

	call_next_update_functions()
	
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
		allowed = math.min(8, math.max(2, allowed))
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
	

	managers.system_menu:update(main_t, main_dt)


	if managers.menu_scene then
		managers.menu_scene:update(t, dt)
	end
	
	managers.menu:update(main_t, main_dt)
	
	if toggle then
		game_state_machine:update(t, dt)
	end
	toggle = not toggle

	if self._main_thread_loading_screen_gui_visible then
		self._main_thread_loading_screen_gui_script:update(-1, dt)
	end

	TestAPIHelper.update(t, dt)
end