if not _G.RebuyContract then
	_G.RebuyContract = _G.RebuyContract or {}
	RebuyContract.job_data = {
	difficulty = nil,
	professional = nil,
	job_id = nil,
	customize_contract = nil,
	difficulty_id = nil,
	competitive = nil,
	contract_visuals ={
	max_mission_xp = nil,
	min_mission_xp = nil,}}
	RebuyContract._data_path = SavePath .. "RebuyContract.txt"
	if RebuyContract_ModPath == nil then
		RebuyContract_ModPath = ModPath
	end
end

function RebuyContract:Load()
	local file = io.open(self._data_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			self.job_data[k] = v
		end
		file:close()
	end
end
RebuyContract:Load()

Hooks:PostHook(MenuCallbackHandler, "start_job", "RebuyContract_Save_to_File", function(self, job_data)
	RebuyContract.job_data = job_data
	local file = io.open(RebuyContract._data_path, "w+")
	if file then
		file:write(json.encode(RebuyContract.job_data))
		file:close()
	end
end)

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_RebuyContract", function(loc)
	for __, filename in pairs(file.GetFiles(RebuyContract_ModPath .. "localizations/")) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(RebuyContract_ModPath .. "localizations/" .. filename)
			break
		end
	end
	loc:load_localization_file(RebuyContract_ModPath .. "localizations/english.txt", false)
end)

Hooks:Add("MenuManagerBuildCustomMenus", "BuildCreateRebuyContract", function(menu_manager, nodes)
	local lobby = nodes.lobby
	if lobby == nil then
		return
	end
	local new_button = lobby:create_item(
	{type = "CoreMenuItem.Item"},
	{name = "rebuy_contract_btn",
	text_id = "rebuy_contract_title",
	help_id = "rebuy_contract_desc",
	callback = "Rebuy_Recent_Job"})

	new_button.dirty_callback = callback(lobby, lobby, "item_dirty")
	if lobby.callback_handler then
		new_button:set_callback_handler(lobby.callback_handler)
	end

	local position = 12
	for index, item in pairs(lobby._items) do
		if item:name() == "fbi_file" then
			position = index + 1
			break
		end
	end
	table.insert(lobby._items, position, new_button)
end)

function MenuCallbackHandler:Rebuy_Recent_Job()
	local job_data = RebuyContract.job_data
	if job_data.difficulty ~= nil and Network:is_server() then
		if managers.money:can_afford_buy_premium_contract(job_data.job_id, job_data.difficulty_id or 3) then
			managers.money:on_buy_premium_contract(job_data.job_id, job_data.difficulty_id or 3) -- pre order
			managers.job:on_buy_job(job_data.job_id, job_data.difficulty_id or 3) -- normal
			if not managers.job:activate_job(job_data.job_id) then
				return
			end
			Global.game_settings.level_id = managers.job:current_level_id()
			Global.game_settings.mission = managers.job:current_mission()
			Global.game_settings.world_setting = managers.job:current_world_setting()
			Global.game_settings.difficulty = job_data.difficulty
			local matchmake_attributes = self:get_matchmake_attributes()
			local job_id_index = tweak_data.narrative:get_index_from_job_id(managers.job:current_job_id())
			local level_id_index = tweak_data.levels:get_index_from_level_id(Global.game_settings.level_id)
			local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
			managers.network:session():send_to_peers("sync_game_settings", job_id_index, level_id_index, difficulty_index)
			managers.network.matchmake:set_server_attributes(matchmake_attributes)
			managers.menu_component:on_job_updated()
			managers.menu:active_menu().logic:refresh_node("lobby", true)
			MenuCallbackHandler:save_progress()
			managers.chat:_receive_message(1, "[Rebuy Contract]", managers.localization:text("rebuy_contract_success"), Color.green)
		else
			managers.chat:_receive_message(1, "[Rebuy Contract]", managers.localization:text("rebuy_contract_no_funds"), Color.red)
		end
	end
end