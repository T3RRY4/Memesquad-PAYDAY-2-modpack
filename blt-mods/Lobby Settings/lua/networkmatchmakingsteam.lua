local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local ls_original_networkmatchmakingsteam_setserverjoinable = NetworkMatchMakingSTEAM.set_server_joinable
function NetworkMatchMakingSTEAM:set_server_joinable(state)
	if state then
		if Global.game_settings.max_players - 1 <= table.size(managers.network:session():peers()) then
			state = false
		end
	end

	ls_original_networkmatchmakingsteam_setserverjoinable(self, state)
end
