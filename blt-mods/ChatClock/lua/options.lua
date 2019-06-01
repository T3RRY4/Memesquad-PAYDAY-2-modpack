--Handle settings
_G.ChatClock = _G.ChatClock or {}
ChatClock._path = ModPath
ChatClock._data_path = SavePath .. "chat_clock.txt"
ChatClock._data = {}

function ChatClock:Save()
	local file = io.open(self._data_path, "w")
	if file then
		file:write(json.encode(self._data))
		file:close()
	end
end

function ChatClock:Load()
	local file = io.open(self._data_path, "r")
	if file then
		self._data = json.decode(file:read("*all"))
		file:close()
	end
end

Hooks:AddHook("LocalizationManagerPostInit" , "LocalizationManagerPostInit_ChatClock", function(loc)
	--TODO: Detect users language setting and load the correct localization file
	loc:load_localization_file(ChatClock._path .. "loc/en.txt")
end)

Hooks:AddHook("MenuManagerInitialize", "MenuManagerInitialize_ChatClock", function(menu_manager)
	MenuCallbackHandler.chat_clock_format_real_time_multi = function(self, item)
		ChatClock._data.chat_clock_format_real_time_value = item:value()
		ChatClock:Save()
	end

	MenuCallbackHandler.chat_clock_use_heist_time_toggle = function(self, item)
		ChatClock._data.chat_clock_use_heist_time_value = (item:value() == "on" and true or false)
		ChatClock:Save()
	end

	MenuCallbackHandler.chat_clock_format_heist_time_multi = function(self, item)
		ChatClock._data.chat_clock_format_heist_time_value = item:value()
		ChatClock:Save()
	end

	ChatClock:Load()
	MenuHelper:LoadFromJsonFile(ChatClock._path .. "menu/options.txt", ChatClock, ChatClock._data)
end)

function ChatClock:GetRealTimeFormatValue()
	return ChatClock._data.chat_clock_format_real_time_value
end

function ChatClock:GetUseHeistTimeValue()
	return ChatClock._data.chat_clock_use_heist_time_value
end

function ChatClock:GetHeistTimeFormatValue()
	return ChatClock._data.chat_clock_format_heist_time_value
end

