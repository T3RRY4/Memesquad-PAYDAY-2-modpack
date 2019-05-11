if not _G.Berserker_Help_mod then
	_G.Berserker_Help_mod = _G.Berserker_Help_mod or {}
	Berserker_Help_mod._path = ModPath
	Berserker_Help_mod._data_path = SavePath .. "berserker_live_matters.txt"
	Berserker_Help_mod.available_mult_num = {1,0.1,0.001}
	Berserker_Help_mod._settings = {}
	Berserker_Help_mod._settings["multiplier"] = 1
	Berserker_Help_mod._settings["combat_cancer"] = true
	Berserker_Help_mod._settings["hacker_cancer"] = true
	Berserker_Help_mod._settings["disable"] = false
	Berserker_Help_mod._settings.active = 2	
	Berserker_Help_mod._diff_mult_loaded = false
	Berserker_Help_mod._player_damage = nil
	Berserker_Help_mod._orig_pocket_ecm_team_heal = nil
	Berserker_Help_mod._enabled = true
	Berserker_Help_mod._fresh_joined = {}
	Berserker_Help_mod._disable_msg = "BLM: Disable mod"
	Berserker_Help_mod._disable_dlg = "BLM: Show disable message"
	Berserker_Help_mod._enable_dlg = "BLM: Enable mod"
end

function Berserker_Help_mod:Set_Player_Damage(plDam)
	Berserker_Help_mod._player_damage = plDam
end

function Berserker_Help_mod:AdjustFixed()
	if Berserker_Help_mod._player_damage then
		if Berserker_Help_mod._settings.fixed and Berserker_Help_mod:AffectedBuild() and Berserker_Help_mod._enabled and not Berserker_Help_mod._settings.disable then
			Berserker_Help_mod._player_damage._max_health_reduction = Berserker_Help_mod.available_mult_num[Berserker_Help_mod._settings.multiplier]
		else
			Berserker_Help_mod._player_damage._max_health_reduction = managers.player:upgrade_value("player", "max_health_reduction", 1)
		end
		Berserker_Help_mod._player_damage._current_max_health = Berserker_Help_mod._player_damage:_max_health() * Berserker_Help_mod._player_damage._max_health_reduction
	end
end


function Berserker_Help_mod:Load()
	local file = io.open(Berserker_Help_mod._data_path, "r")
	if file then
		local decoded = json.decode(file:read("*all")) or {}
		for k, v in pairs(decoded) do
			Berserker_Help_mod._settings[k] = v
		end
		file:close()
	end
	if not Berserker_Help_mod._orig_pocket_ecm_team_heal then
		Berserker_Help_mod._orig_pocket_ecm_team_heal = tweak_data.upgrades.values.team.pocket_ecm_heal_on_kill

	end
end

function Berserker_Help_mod:Save()
	local file = io.open(Berserker_Help_mod._data_path, "w+")
	if file then
		file:write(json.encode(Berserker_Help_mod._settings))
		file:close()
	end
end

function Berserker_Help_mod:AffectedBuild()
	return Berserker_Help_mod:Berserker_Level() >= Berserker_Help_mod._settings.active
end

function Berserker_Help_mod:Berserker_Level()
	if managers.player:has_category_upgrade("player", "damage_health_ratio_multiplier") then
		return 3
	end
	if managers.player:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") then
		return 2
	end
	return 1
end

function Berserker_Help_mod:Update_disable_mod()
	if LuaNetworking:IsHost() then
		for i=2,4 do
			local peer = managers.network:session() and managers.network:session():peer(i)
			if peer then
				for _, mod in ipairs(peer:synced_mods()) do
					if mod.name == "Berserker Live Matters" then
						if Berserker_Help_mod._settings.disable then
							peer:send("send_chat_message", 4, Berserker_Help_mod._disable_dlg)
							peer:send("send_chat_message", 4, Berserker_Help_mod._disable_msg)
						else
							peer:send("send_chat_message", 4, Berserker_Help_mod._enable_dlg)
						end
					end
				end
			end
		end
	end
end
							

---------------------------------------------- Localization ------------------------------------------------



Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_Berserker_Help_mod", function(loc)

	for _, filename in pairs(file.GetFiles(Berserker_Help_mod._path .. "loc/")) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(Berserker_Help_mod._path .. "loc/" .. filename)
			break
		end
	end

	loc:load_localization_file(Berserker_Help_mod._path .. "loc/english.txt", false)
end)


----------------------------------------------- Menu ------------------------------------------------------



Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_Berserker_Help_mod", function(menu_manager)

	MenuCallbackHandler.Berserker_Help_mod_mult_callback  = function(this,item)
		Berserker_Help_mod._settings.multiplier = item:value()
		Berserker_Help_mod:AdjustFixed()
	end

	MenuCallbackHandler.Berserker_Help_mod_active_callback  = function(this,item)
		Berserker_Help_mod._settings.active = item:value()
		Berserker_Help_mod:AdjustFixed()
	end

	MenuCallbackHandler.Berserker_Help_mod_fixed_callback  = function(this,item)
		Berserker_Help_mod._settings.fixed = Utils:ToggleItemToBoolean(item)
		Berserker_Help_mod:AdjustFixed()
	end
	
	MenuCallbackHandler.Berserker_Help_mod_combat_cancer_callback = function(this,item)
		Berserker_Help_mod._settings.combat_cancer = Utils:ToggleItemToBoolean(item)
	end

	MenuCallbackHandler.Berserker_Help_mod_hacker_cancer_callback = function(this,item)
		Berserker_Help_mod._settings.hacker_cancer = Utils:ToggleItemToBoolean(item)
	end

	MenuCallbackHandler.Berserker_Help_mod_disable_callback = function(this,item)
		Berserker_Help_mod._settings.disable = Utils:ToggleItemToBoolean(item)
		local menu = MenuHelper:GetMenu("Berserker_Help_mod_main_menu")
		menu:item("Berserker_Help_mod_mult"):set_enabled(not Berserker_Help_mod._settings.disable)
		menu:item("Berserker_Help_mod_fixed"):set_enabled(not Berserker_Help_mod._settings.disable)
		Berserker_Help_mod:Update_disable_mod()
	end

	MenuCallbackHandler.Berserker_Help_mod_back = function(this, item)
		Berserker_Help_mod:Save()
	end
	
	Berserker_Help_mod:Load()
	-- Main Menu
	Hooks:Add("MenuManagerSetupCustomMenus", "Base_SetupCustomMenus_Json_Berserker_Help_mod_main_menu", function( menu_manager, nodes )
			MenuHelper:NewMenu( "Berserker_Help_mod_main_menu" )
		end)

	Hooks:Add("MenuManagerBuildCustomMenus", "Base_BuildCustomMenus_Json_Berserker_Help_mod_main_menu", function( menu_manager, nodes )

			local parent_menu = "blt_options"
			local menu_id = "Berserker_Help_mod_main_menu"
			local menu_name = "Berserker_Help_mod_main_menu_title"
			local menu_desc = "Berserker_Help_mod_main_menu_desc"

			local data = {
				focus_changed_callback = nil,
				back_callback = "Berserker_Help_mod_back",
				area_bg = nil,
			}
			nodes[menu_id] = MenuHelper:BuildMenu( menu_id, data )

			MenuHelper:AddMenuItem( nodes[parent_menu], menu_id, menu_name, menu_desc, nil )

		end)

	Hooks:Add("MenuManagerPopulateCustomMenus", "Base_PopulateCustomMenus_Json_Berserker_Help_mod_main_menu", function( menu_manager, nodes )
			MenuHelper:AddToggle({
				id = "Berserker_Help_mod_disable",
				title = "Berserker_Help_mod_disable_title",
				desc = "Berserker_Help_mod_disable_desc",
				callback = "Berserker_Help_mod_disable_callback",
				value = Berserker_Help_mod._settings.disable,
				menu_id = "Berserker_Help_mod_main_menu",
				priority = 7,
				localized = true
			})

			MenuHelper:AddDivider({
				id = "Berserker_Help_mod_divider_0",
				size = 24,
				menu_id = "Berserker_Help_mod_main_menu",
				priority = 6
			})
		
			local to_add = {"Berserker_Help_mod_active_1" , "Berserker_Help_mod_active_2", "Berserker_Help_mod_active_3"}
			MenuHelper:AddMultipleChoice({
				id = "Berserker_Help_mod_active",
				title = "Berserker_Help_mod_active_title",
				desc = "Berserker_Help_mod_active_desc",
				callback = "Berserker_Help_mod_active_callback",
				items = to_add,
				value = Berserker_Help_mod._settings.active,
				menu_id = "Berserker_Help_mod_main_menu",
				priority = 5,
				localized = true
			})

			MenuHelper:AddDivider({
				id = "Berserker_Help_mod_divider_1",
				size = 12,
				menu_id = "Berserker_Help_mod_main_menu",
				priority = 4
			})

			MenuHelper:AddToggle({
				id = "Berserker_Help_mod_combat_cancer",
				title = "Berserker_Help_mod_combat_cancer_title",
				desc = "Berserker_Help_mod_combat_cancer_desc",
				callback = "Berserker_Help_mod_combat_cancer_callback",
				value = Berserker_Help_mod._settings.combat_cancer,
				menu_id = "Berserker_Help_mod_main_menu",
				priority = 3,
				localized = true
			})

			MenuHelper:AddToggle({
				id = "Berserker_Help_mod_hacker_cancer",
				title = "Berserker_Help_mod_hacker_cancer_title",
				desc = "Berserker_Help_mod_hacker_cancer_desc",
				callback = "Berserker_Help_mod_hacker_cancer_callback",
				value = Berserker_Help_mod._settings.hacker_cancer,
				menu_id = "Berserker_Help_mod_main_menu",
				priority = 2,
				localized = true
			})


			to_add = {}
			for k, _ in pairs(Berserker_Help_mod.available_mult_num) do
				table.insert(to_add,"Berserker_Help_mod_" .. k .. "mult")
			end
			MenuHelper:AddMultipleChoice({
				id = "Berserker_Help_mod_mult",
				title = "Berserker_Help_mod_mult_title",
				desc = "Berserker_Help_mod_mult_desc",
				callback = "Berserker_Help_mod_mult_callback",
				items = to_add,
				value = Berserker_Help_mod._settings.multiplier,
				menu_id = "Berserker_Help_mod_main_menu",
				disabled = Berserker_Help_mod._settings.disable,
				priority = 1,
				localized = true
			})
			MenuHelper:AddToggle({
				id = "Berserker_Help_mod_fixed",
				title = "Berserker_Help_mod_fixed_title",
				desc = "Berserker_Help_mod_fixed_desc",
				callback = "Berserker_Help_mod_fixed_callback",
				value = Berserker_Help_mod._settings.fixed,
				menu_id = "Berserker_Help_mod_main_menu",
				disabled = Berserker_Help_mod._settings.disable,
				priority = 0,
				localized = true
			})

		end)
	
end)
