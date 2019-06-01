
--[[
	We setup the global table for our mod, along with some path variables, and a data table.
	We cache the ModPath directory, so that when our hooks are called, we aren't using the ModPath from a
		different mod.
]]
DmgPopUp = DmgPopUp or {}
DmgPopUp._path = ModPath
DmgPopUp.options_path = SavePath .. "DmgPopUp.txt"
DmgPopUp.options = {} 

--[[
	A simple save function that json encodes our options table and saves it to a file.
]]
function DmgPopUp:Save()
	local file = io.open( self.options_path, "w+" )
	if file then
		file:write( json.encode( self.options ) )
		file:close()
	end
end

--[[
	A simple load function that decodes the saved json options table if it exists.
]]
function DmgPopUp:Load()
	local file = io.open( self.options_path, "r" )
	if file then
		self.options = json.decode( file:read("*all") )
		file:close()
	else
	log("No previous save found. Creating new using default values")
	local default_file = io.open(self._path .."default_values.txt")
		if default_file then
			self.options = json.decode( default_file:read("*all") )
			self:Save()
		end
	end
end

if not DmgPopUp.setup then
	DmgPopUp:Load()
	DmgPopUp.setup = true
	log("Damage Popup loaded")
end

--DmgPopUp.dofiles = {	}

--Our hook files.  Make sure all hooks in the mod.txt link to this Core.lua.
--If a feature isn't working, just comment it out before pushing a version.  Include a comment of what's broken, if possible.
DmgPopUp.hook_files = {
	["lib/units/civilians/civiliandamage"] = "Lua/CivilianDamage.lua",
	["lib/units/enemies/cop/copdamage"] = "Lua/CopDamage.lua"
}

if not DmgPopUp.setup then

	DmgPopUp:Load()
	--[[
	for p, d in pairs(DmgPopUp.dofiles) do
		dofile(ModPath .. d)
	end
	]]
	DmgPopUp.setup = true
	log("[DmgPopUp] Loaded options")
end



if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if DmgPopUp.hook_files[requiredScript] then
		dofile( ModPath .. DmgPopUp.hook_files[requiredScript] )
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_DmgPopUp", function( loc )
	loc:load_localization_file( DmgPopUp._path .. "Loc/english.txt")
end)

DmgPopUp.colors = DmgPopUp.colors or {
		Color('000000'),
		Color('0000FF'),
		Color('8A2BE2'),
		Color('CD7F32'),
		Color('964B00'),
		Color('00008B'),
		Color('FF8C00'),
		Color('8B0000'),
		Color('9400D3'),
		Color('D4AF37'),
		Color('00FF00'),
		Color('808080'),
		Color('ADD8E6'),
		Color('90EE90'),
		Color('FFB6C1'),
		Color('FFFFE0'),
		Color('FF7F00'),
		Color('FFC0CB'),
		Color('800080'),
		Color('FF0000'),
		Color('C0C0C0'),
		Color('8B00FF'),
		Color('ffffff'),
		Color('FFFF00')
	}

--[[
	Setup our menu callbacks, load our saved data, and build the menu from our json file.
]]
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_DmgPopUp", function( menu_manager )

	--[[
		Setup our callbacks as defined in our item callback keys, and perform our logic on the data retrieved.
	]]
	
	MenuCallbackHandler.callback_show_damage_popup = function(self, item)
		DmgPopUp.options.show_damage_popup = (item:value() == "on")
		DmgPopUp:Save()
	end
	
	MenuCallbackHandler.callback_show_damage_popup_civilian = function(self, item)
		DmgPopUp.options.show_civilian_damage_popup = (item:value() == "on")
		DmgPopUp:Save()
	end
	
	MenuCallbackHandler.callback_damage_popup_headshot_color = function(self, item)
		DmgPopUp.options.damage_popup_headshot_color = item:value()
		DmgPopUp:Save()
 	end
	
	MenuCallbackHandler.callback_damage_popup_headshot_flash_color = function(self, item)
		DmgPopUp.options.damage_popup_headshot_flash_color = item:value()
		DmgPopUp:Save()
 	end
	
	MenuCallbackHandler.callback_damage_popup_kill_color = function(self, item)
		DmgPopUp.options.damage_popup_kill_color = item:value()
		DmgPopUp:Save()
 	end

	--[[
		Load our previously saved data from our save file.
	]]
	DmgPopUp:Load()

	--[[
		Load our menu json file and pass it to our MenuHelper so that it can build our in-game menu for us.
		We pass our parent mod table as the second argument so that any keybind functions can be found and called
			as necessary.
		We also pass our data table as the third argument so that our saved values can be loaded from it.
	]]
	MenuHelper:LoadFromJsonFile( DmgPopUp._path .. "Menu/menu.txt", DmgPopUp, DmgPopUp.options )

end )
