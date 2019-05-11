_G.VELOSync = _G.VELOSync or {}
VELOSync._path = ModPath
VELOSync._data_path = ModPath .. "save/velosync_options.txt"
VELOSync._data = {}

local function isInGame()
	if not game_state_machine then
		return false
	end
	return string.find( game_state_machine:current_state_name(), "ingame" )
end


function VELOSync:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end
function VELOSync:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
		if not self._data.vs_pingloader_enabled then self._data.vs_pingloader_enabled=false VELOSync:Save() end
	end
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_VELOSync", function(menu_manager)
	MenuCallbackHandler.callback_huskspeedchange_d = function(self, item)
		VELOSync._data.vshusk_default = item:value()
		if isInGame() and VELOSync.loaddefhusk then
			VELOSync:loaddefhusk()
		end
	end

	MenuCallbackHandler.callback_huskspeedchange_f = function(self, item)
		VELOSync._data.vshusk_fast = item:value()
	end

	MenuCallbackHandler.velosync_save = function(self, item)
		VELOSync:Save()
	end

	VELOSync.vs_keybind = function(self)
		if isInGame() then
			VELOSync:startfastresolve()
		end
	end

	VELOSync:Load()
	MenuHelper:LoadFromJsonFile(VELOSync._path .. "menu/options.txt", VELOSync, VELOSync._data)
end)
