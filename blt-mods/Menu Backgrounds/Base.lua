MenuBackgrounds = MenuBackgrounds or {}
local self = MenuBackgrounds 
self.ModPath = ModPath
self.AssetsPath = self.ModPath .. "Assets/"
self.SavePath = SavePath .. "MenuBgs.txt"
self.Options = self.Options or {BGsSet = "The Diamond"} 
self.Sets = self.Sets or {} 
self.OptMenuId = "MenuBGsOpt"
self.Updaters = {}

function self:load_sets()
	self.Sets = {}
	for _, set in pairs(SystemFS:list(self.AssetsPath, true)) do
		table.insert(self.Sets, set)
	end
end

function self:load_textures()
	self._files = {}
	if not table.contains(self.Sets, self.Options.BGsSet) then
		self.Options.BGsSet = self.Sets[1]
		self:Save()
	end
	local ids_strings = {}
	local set_path = self.AssetsPath .. self.Options.BGsSet .. "/"
	for _, file in pairs(SystemFS:list(set_path)) do
		local path = set_path .. file
		local in_path = "guis/textures/backgrounds/" .. file:gsub(".png", ""):gsub(".dds", ""):gsub(".texture", ""):gsub(".tga", ""):gsub(".movie", "")
		table.insert(ids_strings, Idstring(in_path))
		DB:create_entry(Idstring(file:match(".movie") and "movie" or "texture"), Idstring(in_path), path)
		self._files[in_path] = path 
	end		
	Application:reload_textures(ids_strings)
	if managers.menu_scene then
		managers.menu_scene:RefreshBackground()
	end
end

function self:AddUpdate(pnl, bg)
	self.Updaters[pnl] = bg
end

function self:AddBackground(pnl, bg)
	if not alive(pnl) then
		return false
	end
	if alive(pnl:child("bg_mod")) then
		pnl:remove(pnl:child("bg_mod"))
	end
	local _bg = bg
	bg = "guis/textures/backgrounds/" .. (self.Options.UseStandard and "standard" or bg)
	if not SystemFS:exists(self._files[bg]) then
		bg = "guis/textures/backgrounds/standard"
	end
	local f = self._files
	if f and f[bg] and f[bg]:match(".movie") and SystemFS:exists(f[bg]) then
		pnl:video({
			name = "bg_mod",
			video = bg,
			valign = "scale",
			halign = "scale",	
			loop = true,
			layer = 1
		})
	else
		pnl:bitmap({
		    name = "bg_mod",
			valign = "scale",
			halign = "scale",	
		    texture = bg,
		    layer = 1
		})
	end	
	self:AddUpdate(pnl, _bg)	
	return true
end

function self:Save()
	local file = io.open(self.SavePath, "w+")
	if file then
		file:write(json.encode(self.Options))
		file:close()
	end
end

function self:Load()
	local file = io.open(self.SavePath, "r")
	if file then
		self.Options = json.decode(file:read("*all"))
		file:close()
	else
		self:Save()
	end
end

function self:UpdateSetsItem()
	local item = managers.menu:active_menu().logic:get_item("BGsSet")
	if item then
		item:clear_options()
		for k, set in pairs(self.Sets) do
			table.insert(item._all_options, CoreMenuItemOption.ItemOption:new({value = set, text_id = set, localize = false}))
		end		
		item._options = item._all_options
		if not table.contains(self.Sets, self.Options.BGsSet) then
			item:set_value(self.Sets[1])	
			MenuCallbackHandler:MenuBgsClbk(item)	
		else
			item:set_value(self.Options.BGsSet)
		end			
	end
end

function self:Update()
	self:load_sets()
	self:UpdateSetsItem()
	self:load_textures()
	for pnl, bg in pairs(self.Updaters) do
		if not self:AddBackground(pnl, bg) then
			table.delete(self.Updaters, bg)
		end
	end
end

Hooks:PostHook(MenuManager, "_node_selected", "MenuBackgroundsNodeSelected", function(this, name, node)
	if node and node:parameters().menu_id == self.OptMenuId then
		self:UpdateSetsItem()
	end
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenusMenuBackgrounds", function(this, nodes)
	World:effect_manager():set_rendering_enabled(Global.load_level)
	self:Load()
	self:load_sets()
	self:load_textures()
 	function MenuCallbackHandler:MenuBgsClbk(item)
		MenuBackgrounds.Options.BGsSet = item:value()		
		MenuBackgrounds:Save()	
		MenuBackgrounds:Update()		
    end      			
	function MenuCallbackHandler:MenuBgsToggleClbk(item)
		MenuBackgrounds.Options[item._parameters.name] = item:value() == "on"
		MenuBackgrounds:Save()
	end			
	function MenuCallbackHandler:MenuBgsRefresh(item) MenuBackgrounds:Update() end		
	local menus = {
		"standard",
		"inventory",
		"blackmarket",
		"blackmarket_crafting",
		"blackmarket_mask",
		"blackmarket_item",
		"blackmarket_customize",
		"blackmarket_screenshot",
		"blackmarket_armor",
		"crime_spree_lobby",
		"lobby",
		"safe",
		"crimenet",
		"briefing",
		"blackscreen",
		"endscreen",
		"loot"
	}
	local options = {
		{id = "BGsSet", type = "MultipleChoice", items = self.Sets, callback = "MenuBgsClbk"},
		{id = "UseStandard", type = "Toggle", callback = "MenuBgsToggleClbk"},
		{id = "FadeToBlack", type = "Toggle", callback = "MenuBgsToggleClbk"},
		{id = "Refresh", type = "Button", callback = "MenuBgsRefresh"},
	}
	for _, menu in pairs(menus) do
		if self.Options[menu] == nil then self.Options[menu] = true end
		LocalizationManager:add_localized_strings({
			["MenuBgs/"..menu] = menu,
			["MenuBgs/"..menu.."Desc"] = string.format("If enabled this will set the background of the menu '%s' to the selected background set", menu)
		})
		table.insert(options, {id = menu, type = "Toggle", callback = "MenuBgsToggleClbk"})
	end
	for k, v in pairs(options) do
	    MenuHelper["Add" .. v.type](MenuHelper, {
	        id = v.id,
	        title = "MenuBgs/" .. v.id,
	        desc = "MenuBgs/" .. v.id .. "Desc",
	        callback = v.callback,
	        items = v.items,
	        priority = 999 - k,
	        value = self.Options[v.id],
	        menu_id = self.OptMenuId,
	    })      
	end
	self:Save()
end)

Hooks:Add("LocalizationManagerPostInit", "MenuBackgrounds_loc", function(loc)
	LocalizationManager:add_localized_strings({
	    ["MenuBgs/Opt"] = "Menu Backgrounds",
	    ["MenuBgs/OptDesc"] = "Change the way the mod acts",
	    ["MenuBgs/BGsSet"] = "Backgrounds Set",
	    ["MenuBgs/BGsSetDesc"] = "Choose the backgrounds set the mod will use(default : standard)",
	    ["MenuBgs/UseStandard"] = "Use standard texture for all menus",
	    ["MenuBgs/UseStandardDesc"] = "If enabled the mod will use the standard texture for all menus(default : not enabled)",	   
	    ["MenuBgs/FadeToBlack"] = "Fade To Black",
	    ["MenuBgs/FadeToBlackDesc"] = "Normally if enabled the game fades from the current menu into a black screen and then into the next menu(default: not enabled)",
	    ["MenuBgs/Refresh"] = "Refresh",
  	})
end)

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenusMenuBackgrounds", function(this, nodes)
	MenuHelper:NewMenu(self.OptMenuId)
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusMenuBackgrounds", function(this, nodes)
	nodes[self.OptMenuId] = MenuHelper:BuildMenu(self.OptMenuId)
	MenuHelper:AddMenuItem(nodes.blt_options, self.OptMenuId, "MenuBgs/Opt", "MenuBgs/OptDesc")
end)

local plt = MenuComponentManager.play_transition 
function MenuComponentManager:play_transition(...)
	if MenuBackgrounds.Options.FadeToBlack then
		plt(self, ...)
	end
end 