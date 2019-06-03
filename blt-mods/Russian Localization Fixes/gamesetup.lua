if Network:is_client() then
	return
end

if Global.job_manager
	and Global.job_manager.current_job
	and Global.job_manager.current_job.job_id
then 
	local level = ''
	if Global.job_manager.current_job.job_id == 'crime_spree' then
		level = Global.job_manager.current_job.level_id:gsub('_?%d$','')
	else
		level = Global.job_manager.current_job.job_id
	end
	
	if level ~= 'nmh' then
		return
	end
else
	return
end

local init_fin_orig = GameSetup.init_finalize
function GameSetup:init_finalize(...)
	init_fin_orig(self, ...)
	
	if not ElementFunction then
		ElementFunction = ElementFunction or class(CoreMissionScriptElement.MissionScriptElement)

		function ElementFunction:init(...)
			ElementFunction.super.init(self, ...)
		end

		function ElementFunction:client_on_executed(...)
			self:on_executed(...)
		end

		function ElementFunction:on_executed(instigator)
			if not self._values.enabled then
				return
			end

			if self._values.func then
				self._values.func(instigator)
			end
			
			ElementFunction.super.on_executed(self, instigator)
		end
	end
	
	local lastId = 999999
	local function GetId()
		lastId = lastId + 1
		while managers.mission:get_element_by_id(lastId) do
			lastId = lastId + 1
		end
		return lastId
	end

	GetId()
	local RusLocFixes_truespeech = {
		class = 'ElementFunction',
		editor_name = 'RusLocFixes_truespeech',
		id = lastId,
		values = {
			enabled = true,
			trigger_times = -1,
			base_delay = 0,
			set_trigger_times = -1,
			func = function()
				local id = 'rlf_nmh_true_0'..math.random(1,6)
				managers.subtitle:presenter():show()
				managers.subtitle:show_subtitle(id, 5)
			end,
			on_executed = {}
		}
	}
	local truespeech = managers.mission:get_element_by_id(102809)
	if truespeech then
		lastIndex = #truespeech._values.on_executed
		truespeech._values.on_executed[lastIndex + 1] = { id = lastId, delay = 5 }
	end
	GetId()
	local RusLocFixes_falsespeech = {
		class = 'ElementFunction',
		editor_name = 'RusLocFixes_falsespeech',
		id = lastId,
		values = {
			enabled = true,
			trigger_times = -1,
			base_delay = 0,
			set_trigger_times = -1,
			func = function()
				local id = 'rlf_nmh_false_0'..math.random(1,8)
				managers.subtitle:presenter():show()
				managers.subtitle:show_subtitle(id, 5)
			end,
			on_executed = {}
		}
	}
	local talkedFalse = managers.mission:get_element_by_id(102826)
	if talkedFalse then
		lastIndex = #talkedFalse._values.on_executed
		talkedFalse._values.on_executed[lastIndex + 1] = { id = lastId, delay = 5 }
	end
	local talkedFalse_2 = managers.mission:get_element_by_id(102827)
	if talkedFalse_2 then
		lastIndex = #talkedFalse_2._values.on_executed
		talkedFalse_2._values.on_executed[lastIndex + 1] = { id = lastId, delay = 5 }
	end
	local talkedFalse_3 = managers.mission:get_element_by_id(102828)
	if talkedFalse_3 then
		lastIndex = #talkedFalse_3._values.on_executed
		talkedFalse_3._values.on_executed[lastIndex + 1] = { id = lastId, delay = 5 }
	end
	for name, script in pairs(managers.mission._scripts) do
		if script:element(102809) then
			script:_create_elements({ RusLocFixes_truespeech, RusLocFixes_falsespeech })
			break
		end
	end
end