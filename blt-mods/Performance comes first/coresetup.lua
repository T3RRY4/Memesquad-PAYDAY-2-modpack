PerformanceComesFirstFPS = PerformanceComesFirstFPS or 50

local mans = {
	'cutscene',
	'sequence',
	'worldcamera',
	'environment_effects',
	'sound_environment',
	'environment_area',
	'expression',
	'overlay_effect',
	'mission',
	'slave',
	'environment_controller'
}
local dts = {}
local current = 1
local allowed = 8

local upd_orig = CoreSetup.__update
function CoreSetup:__update(t, dt)
	
	if self.__firstupdate then
		self:stop_loading_screen()

		self.__firstupdate = false
	end

	managers.controller:update(t, dt)
	
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
	
	managers.subtitle:update(TimerManager:game_animation():time(), TimerManager:game_animation():delta_time())
	managers.viewport:update(t, dt)
	
	self._session:update(t, dt)
	self._input:update(t, dt)
	self._smoketest:update(t, dt)
	
	self:update(t, dt)
end