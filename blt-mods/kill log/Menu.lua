_G.KillLog = _G.KillLog or {}
KillLog.ModPath = ModPath
KillLog.SavePath = SavePath .. "KillLogSave.txt"
KillLog.Opt = {} 
KillLog.OptMenuId = "KillLogOptions"

function KillLog:Init()
	dofile(self.ModPath .. "/KillLogBox.lua")
	
	self.colors = {
		{color = Color(0, 1, 0.2), menu_name = "Green"},
		{color = Color(0, 0.4, 1), menu_name = "Blue"},
		{color = Color(1, 0.5, 0), menu_name = "Orange"},
		{color = Color(1, 0.4, 0.8), menu_name = "Pink"},
		{color = Color(0.6, 0, 0.6), menu_name = "Purple"},
		{color = Color.white, menu_name = "White"},
		{color = Color.black, menu_name = "Black"},
		{color = Color.transparent, menu_name = "Transparent"}
	}

	self:Load()

	self.Opt.reset = self.Opt.reset or false
	self.Opt.bgcolor = self.Opt.bgcolor or 1
	self.Opt.textcolor = self.Opt.textcolor or 7
	self.Opt.fadetime = self.Opt.fadetime or 3
	self.Opt.size = self.Opt.size or 48

	LocalizationManager:add_localized_strings({
	    ["KillLog_options_title"] = "KillLog options",
	    ["KillLog_options_desc"] = "Here you can set when the KillLog needs to play",
	    ["KillLog_reset_title"] = "Reset after killog disappears",
	    ["KillLog_bgcolor_title"] = "KillLog bg color",
	    ["KillLog_textcolor_title"] = "KillLog text color",
	    ["KillLog_fadetime_title"] = "KillLog fade time",
	    ["KillLog_size_title"] = "KillLog size",
	})

	self.colors_loc = {}
	for k, v in pairs(KillLog.colors) do
		LocalizationManager:add_localized_strings({
			["KillLogcolor"..k] = v.menu_name,
		})  	  
	  	table.insert(self.colors_loc, "KillLogcolor"..k)
	end
	  
	self.Box = KillLogBox:new(managers.gui_data:create_fullscreen_workspace():panel())
	  
	self.InitDone = true
end
	
function KillLog:Save()
	local file = io.open(self.SavePath, "w+")
	if file then
		file:write(json.encode(self.Opt))
		file:close()
	end
end

function KillLog:Load()
	local file = io.open(self.SavePath, "r")
	if file then
		self.Opt = json.decode(file:read("*all"))
		file:close()
	end
end

function MenuCallbackHandler:KillLog_toggle(item)
	KillLog.Opt[item._parameters.name:gsub("KillLog_", "")] = item:value() == "on"
	KillLog:Save()
	KillLog.Box:Update()
end

function MenuCallbackHandler:KillLog_value(item)
	KillLog.Opt[item._parameters.name:gsub("KillLog_", "")] = item:value()
	KillLog:Save()
	KillLog.Box:Update()
end

--DAMN THIS IS SO MUCH BETTER THAN CREATING 3 SHITTY HOOKS
Hooks:Add("MenuManagerPopulateCustomMenus", "KillLogOptions", function(self, nodes)
	if not KillLog.InitDone then
		KillLog:Init()
	end

	MenuHelper:NewMenu(KillLog.OptMenuId)
	MenuHelper:AddToggle({
		id = "KillLog_reset",
		title = "KillLog_reset_title",
		callback = "KillLog_toggle",
		menu_id = KillLog.OptMenuId,
		value = KillLog.Opt.reset,
    })		
    MenuHelper:AddMultipleChoice({
		id = "KillLog_bgcolor",
		title = "KillLog_bgcolor_title",
		callback = "KillLog_value",
		menu_id = KillLog.OptMenuId,
		items = KillLog.colors_loc,
		value = KillLog.Opt.bgcolor,
    })	    
    MenuHelper:AddMultipleChoice({
		id = "KillLog_textcolor",
		title = "KillLog_textcolor_title",
		callback = "KillLog_value",
		menu_id = KillLog.OptMenuId,
		items = KillLog.colors_loc,
		value = KillLog.Opt.textcolor,
    })	   
    MenuHelper:AddSlider({
		id = "KillLog_fadetime",
		title = "KillLog_fadetime_title",
		callback = "KillLog_value",
		menu_id = KillLog.OptMenuId,
		max = 60,
		min = 0.5,
		show_value = true,
		value = KillLog.Opt.fadetime,
    })	    
    MenuHelper:AddSlider({
		id = "KillLog_size",
		title = "KillLog_size_title",
		callback = "KillLog_value",
		menu_id = KillLog.OptMenuId,
		max = 120,
		min = 16,
		show_value = true,
		value = KillLog.Opt.size,
	})
	nodes[KillLog.OptMenuId] = MenuHelper:BuildMenu(KillLog.OptMenuId)
	MenuHelper:AddMenuItem(nodes.lua_mod_options_menu or nodes.blt_options, KillLog.OptMenuId, "KillLog_options_title", "KillLog_options_desc")
end)