--[[ Counts objects of a given type
	arguments:
		pickups		--ammo pickups
		enemies		
		all
		persons
		civilians
		all_criminals
		meds	--total amount of charges in all of the deployed medic bags
		ammo	--total amount of ammo in the deployed ammo bags
		bodybags	--total amount of body bags in the deployed body bag cases
		bags

	examples:
		count meds ammo

--]]

_G.PowerChat = _G.PowerChat or {}
_G.PowerChatCommands = _G.PowerChatCommands or {}

local cmdName = 'count'

local chatName = 'COUNT'

PowerChatCommands[cmdName] = {}
PowerChatCommands[cmdName].Parse = function(args, ops, need_return)
	table.remove(args, 1)
	
	if #args == 0 then
		PowerChatCommands[cmdName].Help()
	end
	
	if not CopDamage 
		or not BaseNetworkHandler._verify_gamestate(BaseNetworkHandler._gamestate_filter.any_ingame_playing)
	then
		PowerChat:OutPut(chatName, 'This command can only be used while playing', Color.red)
		return
	end
	
	for i,s in pairs(args) do
		--local slow = s:lower()
		local units
		if PowerChatCommands[cmdName].Masks[s] then
			if type(PowerChatCommands[cmdName].Masks[s]) == 'string' then
				units = World:find_units_quick('all', PowerChatCommands[cmdName].Masks[s]) or {}
			else
				units = PowerChatCommands[cmdName].Masks[s]() or {}
			end
		else
			units = PowerChatCommands[cmdName].World_find(managers.slot:get_mask(s)) or {}
		end
		
		local amount = #units
		
		if PowerChatCommands[cmdName].Special[s] then
			amount = 0
			for k,v in pairs(units) do
				amount = amount + PowerChatCommands[cmdName].Special[s](v)
			end
		end
		
		if need_return then return amount end
		PowerChat:OutPut(chatName, 'There are '..amount..' of \''..s..'\'', Color.green)
	end
	if need_return then return '?' end
end

PowerChatCommands[cmdName].Help = function()
	PowerChat:OutPut(chatName, 'Counts objects', Color.yellow)
	PowerChat:OutPut(chatName, 'count [mask1 mask2 mask3...]', Color.yellow)
end

PowerChatCommands[cmdName].Parse_Return = function(args, ops)
	return tostring(PowerChatCommands[cmdName].Parse(args, ops, true))
end

PowerChatCommands[cmdName].Special = {}

PowerChatCommands[cmdName].Special['meds'] = function(unit)
	return unit:base() and (unit:base()._amount or 0) or 0
end

PowerChatCommands[cmdName].Special['bodybags'] = function(unit)
	return unit:base() and (unit:base()._bodybag_amount  or 0) or 0
end

PowerChatCommands[cmdName].Special['ammo'] = function(unit)
	return unit:base() and (unit:base()._ammo_amount  or 0) or 0
end

PowerChatCommands[cmdName].Special['bags'] = function(unit)
	local inter = unit:interaction()
	if not inter then return 0 end
	local td = inter.tweak_data
	if not td then return 0 end
	return td:match('carry_drop') and 1 or 0
end

PowerChatCommands[cmdName].World_find = function(mask)
	return World:find_units_quick('all', mask or World:make_slot_mask(14))
end

PowerChatCommands[cmdName].GetInteractables = function()
	return managers.interaction and managers.interaction._interactive_units or nil
end

PowerChatCommands[cmdName].Masks = {
	meds = PowerChatCommands[cmdName].World_find,
	ammo = PowerChatCommands[cmdName].World_find,
	bodybags = PowerChatCommands[cmdName].World_find,
	bags = PowerChatCommands[cmdName].GetInteractables
}