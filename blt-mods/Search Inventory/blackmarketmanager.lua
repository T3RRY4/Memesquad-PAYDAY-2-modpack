local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

_G.SearchInventory = _G.SearchInventory or {}
SearchInventory._path = ModPath
SearchInventory.filters = {}

function SearchInventory:reset_filters()
	self.filters = {}
end

function SearchInventory:set_filters(str)
	if type(str) == 'string' then
		self.filters = str:split(' ')
	end
end

function SearchInventory:get_filter_str()
	return table.concat(self.filters, ' ')
end

function BlackMarketManager:si_get_search_string(data, slot)
	local category = data.category
	if not category then
		return
	end

	local list = self._global.crafted_items[category] or self._global[category]
	if not list then
		return
	end

	local item = slot and list[slot] or list[data.name]
	if not item then
		return
	end

	local dlc_id = data.global_value
	local result
	local txts = {}

	if category == 'melee_weapons' then
		txts[1] = data.name
		txts[2] = utf8.to_lower(data.name_localized)
		if dlc_id then
			txts[3] = dlc_id
			txts[4] = utf8.to_lower(managers.localization:text(tweak_data.lootdrop.global_values[dlc_id].name_id))
		end

		result = table.concat(txts, ' ')

	elseif category == 'masks' then
		txts[1] = utf8.to_lower(item.custom_name or '')

		txts[2] = tostring(item.mask_id)
		txts[3] = utf8.to_lower(managers.localization:text(tweak_data.blackmarket.masks[item.mask_id].name_id))
		txts[4] = utf8.to_lower(managers.localization:text(tweak_data.blackmarket.colors[item.blueprint.color.id].name_id))

		txts[5] = tostring(item.blueprint.material.id)
		txts[6] = tostring(item.blueprint.color.id)
		txts[7] = tostring(item.blueprint.pattern.id)

		if dlc_id then
			txts[8] = dlc_id
			txts[9] = utf8.to_lower(managers.localization:text(tweak_data.lootdrop.global_values[dlc_id].name_id))
		end

		result = table.concat(txts, ' ')

	elseif category == 'primaries' or category == 'secondaries' then
		if dlc_id then
			txts[dlc_id] = dlc_id
			local tmp = utf8.to_lower(managers.localization:text(tweak_data.lootdrop.global_values[dlc_id].name_id))
			txts[tmp] = tmp
		end

		if item.custom_name then
			tmp = utf8.to_lower(item.custom_name)
			txts[tmp] = tmp
		end

		local td_weapon = tweak_data.weapon[item.weapon_id]
		local name = utf8.to_lower(managers.localization:text(td_weapon.name_id))
		txts[name]= name
		for _, ctg in pairs(td_weapon.categories) do
			txts[ctg]= ctg
			if managers.localization:exists('menu_' .. ctg) then
				local ctg_txt = utf8.to_lower(managers.localization:text('menu_' .. ctg))
				txts[ctg_txt]= ctg_txt
			end
		end

		local td_factory = tweak_data.weapon.factory
		for _, part_name in ipairs(item.blueprint) do
			local name_id = td_factory.parts[part_name].name_id
			if name_id and managers.localization:exists(name_id) then
				local text = utf8.to_lower(managers.localization:text(name_id))
				txts[text] = text
			end
		end

		result = ''
		for text in pairs(txts) do
			result = result .. ' ' .. text
		end
	end

	return result
end
