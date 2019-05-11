--[[ 	
--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'event'
local chatName = 'EVENT'

local hook_cmd_name = 'hook'
local unhook_cmd_name = 'unhook'

PowerChatCommands[cmdName] = {}

--deployedEquipment
-- assaultStart, assaultEnd, playerCustody
--Alarm, swansong, wintersSpawns
-- civilianTied, OutOfCustody, pagerAnswered

PowerChatCommands[cmdName].eventIDs = {
	EnemyDied = 'EnemyManager:on_enemy_died',
	Downed = 'PlayerBleedOut:_enter',
	Custody = 'TradeManager:on_player_criminal_death',
	PlayerJoined = 'NetworkManager:on_peer_added',
	BagTaken = 'PlayerManager:set_carry',
	Achievement = 'AchievmentManager:award',
	AmmoBoxPickUp = 'AmmoClip:_pickup',
	Incapacitated = 'PlayerIncapacitated:enter',
	Tased = 'PlayerTased:enter',
	SpecOpsItemPickUp = 'TangoManager:award',
	ZipLineInteract = 'ZipLineInteractionExt:interact',
	CameraInteract = 'SecurityCameraInteractionExt:interact',
	CopConverted = 'GroupAIStateBase:convert_hostage_to_criminal',
	GagePackageInteract = 'GageAssignmentManager:on_unit_interact',
	CivilianDied = 'EnemyManager:on_civilian_died',
	LootSecured = 'LootManager:sync_secure_loot'
}

PowerChatCommands[cmdName].hooks = {}

PowerChatCommands[cmdName].Parse = function(args, ops)
	ops = ops or {}
	local event_str = ops[1] and ops[1]:sub(2) or nil
	
	if event_str and PowerChatCommands[cmdName].eventIDs[event_str] then
		ops[1] = PowerChat.settings.opt_sym..PowerChatCommands[cmdName].eventIDs[event_str]
		
		if PowerChatCommands[hook_cmd_name] then
			PowerChatCommands[hook_cmd_name].Parse(args, ops)
			return
		end
	elseif event_str and event_str == 'list' then
		local list = ''
		for k,v in pairs(PowerChatCommands[cmdName].eventIDs) do
			list = list .. k .. '  '
		end
		PowerChat:OutPut(chatName, list, Color.green)
	else
		PowerChat:OutPut(chatName, 'You must specify an event you want to hook to.', Color.red)
		return
	end
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'A friendlier interface for \'hook\' command', Color.yellow)
	PowerChat:OutPut(chatName, 'event -EventName [message]', Color.yellow)
	PowerChat:OutPut(chatName, 'Use \'event -list\' to see available events', Color.yellow)
	PowerChat:OutPut(chatName, 'Use \'event-stop\' command to stop an event message', Color.yellow)
end

local cmdName2 = 'event-stop'
PowerChatCommands[cmdName2] = {}
PowerChatCommands[cmdName2].Parse = function(args, ops)
	ops = ops or {}
	local event_str = ops[1] and ops[1]:sub(2) or nil
	
	if event_str and PowerChatCommands[cmdName].eventIDs[event_str] then
		ops[1] = PowerChat.settings.opt_sym..PowerChatCommands[cmdName].eventIDs[event_str]
		
		if PowerChatCommands[unhook_cmd_name] then
			PowerChatCommands[unhook_cmd_name].Parse(args, ops)
			return
		end
	else
		PowerChat:OutPut(chatName, 'You must specify an event.', Color.red)
	end
end