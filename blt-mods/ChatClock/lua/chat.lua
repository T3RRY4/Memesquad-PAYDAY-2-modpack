Hooks:RegisterHook("ChatManagerOnReceiveMessage")
function ChatManager._receive_message(this, channel_id, name, message, color, icon)
	name = ChatClock:GetFormattedTimestamp() .. name
	Hooks:Call("ChatManagerOnReceiveMessage", channel_id, name, message, color, icon)
	return this.orig._receive_message(this, channel_id, name, message, color, icon)
end

function ChatClock:GetFormattedTimestamp()
	if ChatClock:GetUseHeistTimeValue() == true and managers.game_play_central then --TODO: Verify we're not in briefing as get_heist_timer() will return the amount of time you've been in the briefing screen
		local timestamp = managers.game_play_central:get_heist_timer()				--TODO: Stop using heist time in the rewards screen
		local minute = ((timestamp % 3600) / 60) - ((timestamp % 60) / 60) --((timestamp % 60) / 60) gives us everything past the decimal point since I can't get math.floor() to work
		if minute < 10 then
			minute = "0" .. minute --Add padding so that formatting is consistent
		end
		local second = (timestamp % 60) - (timestamp % 1)
		if second < 10 then
			second = "0" .. second
		end
		if ChatClock:GetHeistTimeFormatValue() == 1 or (timestamp > 3600 and ChatClock:GetHeistTimeFormatValue() == 3) then --If we're forcing hours to show up or if an hour has passed and we're using dynamic time formatting
			local hour = (timestamp / 3600) - ((timestamp % 3600) / 3600)
			if hour < 10 then
				hour = "0" .. hour
			end
			return "[" .. hour .. ":" .. minute .. ":" .. second .. "] "
		else
			return "[" .. minute .. ":" .. second .. "] "
		end
	else
		if ChatClock:GetRealTimeFormatValue() == 1 then
			return "[" .. os.date("%H:%M:%S") .. "] "
		elseif ChatClock:GetRealTimeFormatValue() == 2 then
			return "[" .. os.date("%H:%M") .. "] "
		elseif ChatClock:GetRealTimeFormatValue() == 3 then
			return "[" .. os.date("%I:%M:%S %p") .. "] "
		else
			return "[" .. os.date("%I:%M %p") .. "] "
		end
	end
	return ""
end