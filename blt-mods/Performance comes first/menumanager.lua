PerformanceComesFirstFPS = 50

local function LoadSettings()
	local file = io.open(SavePath .. 'PerformanceComesFirst.txt', "r")
	if file then
		local data = json.decode(file:read("*all"))
		if data.fps and type(data.fps) == 'number' then
			PerformanceComesFirstFPS = math.floor(data.fps)
		end
		if data.display then
			PerformanceComesFirstDisplay = true
		end
		file:close()
	end
end
LoadSettings()

local function SaveSettings()
	local file = io.open(SavePath .. 'PerformanceComesFirst.txt', "w")
	if file then
		file:write(json.encode({ fps = math.floor(PerformanceComesFirstFPS), display = PerformanceComesFirstDisplay }))
		file:close()
	end
end

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_PerformanceComesFirst", function()
	MenuCallbackHandler.PerformanceComesFirst = function(this, item)
		PerformanceComesFirstFPS = math.floor(item:value())
	end
	
	MenuCallbackHandler.PerformanceComesFirstDisplay = function(this, item)
		PerformanceComesFirstDisplay = item:value() == 'on'
	end
	
	MenuCallbackHandler.PerformanceComesFirstSave = function(this)
		SaveSettings()
	end
	
	MenuHelper:AddSlider({
				id = 'fps',
				title = 'YOUR AVERAGE FPS',
				desc = 'Set FPS value that you want to get most of the time',
				callback = 'PerformanceComesFirst',
				min = 10,
				max = 60,
				step = 2,
				show_value = true,
				value = PerformanceComesFirstFPS or 50,
				default_value = 50,
				menu_id = 'PerformanceComesFirstMenu',
				localized = false,
				priority = 10
			})
			
	MenuHelper:AddToggle({
				id = 'fps_display',
				title = 'DISPLAY FPS',
				desc = 'Displays FPS value and the quality of the wanted FPS value you set',
				callback = 'PerformanceComesFirstDisplay',
				value = PerformanceComesFirstDisplay or false,
				default_value = false,
				menu_id = 'PerformanceComesFirstMenu',
				localized = false
			})
			
	local menu_msgs = MenuHelper:GetMenu('PerformanceComesFirstMenu')
	for k,v in pairs(menu_msgs._items_list or {}) do
		v:set_parameter('localize_help', false)
	end
end)

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_PerformanceComesFirst", function()
	MenuHelper:NewMenu('PerformanceComesFirstMenu')
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_PerformanceComesFirst", function(menu_manager, nodes)
	LocalizationManager:add_localized_strings({
		menu_PerformanceComesFirst_name = 'Performance Comes First',
		menu_PerformanceComesFirst_desc = 'Performance Comes First'
	})
	
	nodes['PerformanceComesFirstMenu'] = MenuHelper:BuildMenu('PerformanceComesFirstMenu', { back_callback = 'PerformanceComesFirstSave' })
	MenuHelper:AddMenuItem(nodes["blt_options"], 'PerformanceComesFirstMenu', "menu_PerformanceComesFirst_name", "menu_PerformanceComesFirst_desc")
end)