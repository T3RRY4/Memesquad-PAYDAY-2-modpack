

-- Mod Shop
_G.ModShop = _G.ModShop or {}
--local ModShop = _G.GageModShop.ModShop
local ExtendedInv = _G.GageModShop.ExtendedInventory

ModShop.PurchaseCurrency = "gage_coin"
ModShop.CostRegular = 1
ModShop.CostInfamous = 24
ModShop.MaskPricing = {
	["default"] = 6,
	["dlc"] = 6,
	["normal"] = 6,
	["pd2_clan"] = 6,
	["halloween"] = 12,
	["infamous"] = 24,
	["infamy"] = 24,
}

ModShop.ExclusionList = {
	["nothing"] = true,
	["no_material"] = true,
	["no_color_no_material"] = true,
	["no_color_full_material"] = true,
	["plastic"] = true,
	["character_locked"] = true,
}

ModShop.NonDLCGlobalValues = {
	["normal"] = true,
	["pd2_clan"] = true,
	["halloween"] = true,
	["infamous"] = true,
	["infamy"] = true,
}

ModShop.MaskMods = {
	["materials"] = true,
	["textures"] = true,
	["colors"] = true,
}

ModShop.NamePriceOverrides = {
	["wpn_fps_upg_bonus_"] = 1,
}

function ModShop:IsItemExluded( item )
	return ModShop.ExclusionList[item] or false
end

function ModShop:IsGlobalValueDLC( gv )
	if not ModShop.NonDLCGlobalValues[gv] then
		return true
	end
	return false
end

function ModShop:IsInfamyLocked( data )

	local infamy_lock = data.tweak_data.infamy_lock
	if infamy_lock then
		local is_unlocked = managers.infamy:owned(infamy_lock)
		if not is_unlocked then
			return true
		end
	end

	return false

end

function ModShop:IsItemMaskMod( item )
	return ModShop.MaskMods[item.category] or false
end

function ModShop:GetItemPrice( data )

	if data.category == "masks" then
		local gv = self:IsGlobalValueDLC( data.global_value ) and "dlc" or data.global_value
		return ModShop.MaskPricing[ gv ]
	end

	if data.global_value == "infamy" or data.global_value == "infamous" then
		return ModShop.CostInfamous
	end

	for pattern, cost_override in pairs(self.NamePriceOverrides) do
		if data.name and string.find(data.name, pattern) then
			return cost_override
		end
	end

	return ModShop.CostRegular

end

function ModShop:_ReloadBlackMarket()
	local blackmarket_gui = managers.menu_component._blackmarket_gui
	if blackmarket_gui then
		blackmarket_gui:reload()
		blackmarket_gui:on_slot_selected( blackmarket_gui._selected_slot )
	end
end

function ModShop:AttemptItemPurchase( data, weapon_part )

	if not data then
		return
	end

	local verified, purchase_data = self:VerifyItemPurchase( data, weapon_part )
	if verified then
		if purchase_data.price <= managers.custom_safehouse:coins() then
			self:ShowItemPurchaseMenu( purchase_data )
		else
			self:ShowItemCannotAffordMenu( purchase_data )
		end
	end

end

function ModShop:VerifyItemPurchase( data, weapon_part )

	if not data then
		return
	end

	local name = data.name
	local category = weapon_part and "parts" or data.category

	local entry
	if weapon_part then
		entry = tweak_data:get_raw_value("weapon", "factory", category, name)
	else
		entry = tweak_data:get_raw_value("blackmarket", category, name)
	end

	if not entry then
		local str = "[Error] Could not retrieve tweak_data for {1} item '{2}', weapon_part: {3}"
		str = str:gsub("{1}", tostring(category))
		str = str:gsub("{2}", tostring(name))
		str = str:gsub("{3}", tostring(weapon_part or false))
		Print(str)
		return
	end

	local global_value = entry.infamous and "infamous" or entry.global_value or entry.dlc or entry.dlcs and entry.dlcs[math.random(#entry.dlcs)] or "normal"
	local purchase_data = {
		name = data.name,
		name_localized = data.name_localized,
		category = weapon_part and "weapon_mods" or data.category,
		is_weapon_part = weapon_part,
		bitmap_texture = data.bitmap_texture,
		global_value = global_value,
		tweak_data = entry,
		price = 1,
	}
	purchase_data.price = self:GetItemPrice( purchase_data )

	if self:IsItemExluded( purchase_data.name ) then
		return false
	end

	if self:IsGlobalValueDLC( purchase_data.global_value ) and not managers.dlc:is_dlc_unlocked( purchase_data.global_value ) then
		return false
	end

	if self:IsInfamyLocked( purchase_data ) then
		return false
	end

	for k, v in pairs( tweak_data.dlc ) do
		if v.achievement_id ~= nil and v.content ~= nil and v.content.loot_drops ~= nil then
			for i, loot in pairs( v.content.loot_drops ) do
				if loot.item_entry ~= nil and loot.item_entry == purchase_data.name and loot.type_items == purchase_data.category then

					if not managers.achievment.handler:has_achievement(v.achievement_id) then

						local achievement_tracker = tweak_data.achievement[ purchase_data.is_weapon_part and "weapon_part_tracker" or "mask_tracker" ]
						local achievement_progress = achievement_tracker[purchase_data.name]
						if achievement_progress then
							return false
						end

						if not purchase_data.is_weapon_part then
							return false
						end
						
					end

				end
			end
		end
	end

	if purchase_data.tweak_data.is_a_unlockable then
		return false
	end

	return true, purchase_data

end

function ModShop:ShowItemPurchaseMenu( purchase_data )

	local currency_name = "menu_cs_coins"
	local title = managers.localization:text("gm_gms_purchase_window_title")
	local message = managers.localization:text("gm_gms_purchase_window_message")
	message = message:gsub("{1}", purchase_data.name_localized)
	message = message:gsub("{2}", tostring(purchase_data.price))
	message = message:gsub("{3}", managers.localization:text(currency_name))

	local dialog_data = {}
	dialog_data.title = title
	dialog_data.text = message
	dialog_data.id = "gms_purchase_item_window"

	local ok_button = {}
	ok_button.text = managers.localization:text("dialog_yes")
	ok_button.callback_func = callback( self, self, "_PurchaseItem", purchase_data )

	local cancel_button = {}
	cancel_button.text = managers.localization:text("dialog_no")
	cancel_button.cancel_button = true

	dialog_data.button_list = {ok_button, cancel_button}
	dialog_data.purchase_data = purchase_data
	managers.system_menu:show( dialog_data )

end

function ModShop:ShowItemCannotAffordMenu( purchase_data )

	local currency_name = "menu_cs_coins"
	local title = managers.localization:text("gm_gms_purchase_failed")
	local message = managers.localization:text("gm_gms_cannot_afford_message")
	message = message:gsub("{1}", purchase_data.name_localized)
	message = message:gsub("{2}", tostring(purchase_data.price))
	message = message:gsub("{3}", managers.localization:text(currency_name))

	local dialog_data = {}
	dialog_data.title = title
	dialog_data.text = message
	dialog_data.id = "gms_purchase_item_window"

	local cancel_button = {}
	cancel_button.text = managers.localization:text("dialog_ok")
	cancel_button.cancel_button = true

	dialog_data.button_list = { cancel_button }
	managers.system_menu:show( dialog_data )

end


function ModShop:_PurchaseItem( purchase_data )

	if not purchase_data then
		return
	end

	local name = purchase_data.name
	local category = purchase_data.category
	local global_value = purchase_data.global_value
	local price = purchase_data.price

	log(string.format( "Purchased item with continental coins:\n\tItem name: %s\n\tCategory: %s", tostring(name), tostring(category) ))
	managers.blackmarket:add_to_inventory(global_value, category, name, true)

	managers.custom_safehouse:deduct_coins( price )

	-- Record mask mods that were purchased so we can immediately add them to the gui when it reloads
	if self:IsItemMaskMod( purchase_data ) then
		self._purchased_mask_mods = ModShop._purchased_mask_mods or {}
		self._purchased_mask_mods[category] = self._purchased_mask_mods[category] or {}
		table.insert(self._purchased_mask_mods[category], name)
	end

	self:_ReloadBlackMarket()
	if Global.wallet_panel then
		WalletGuiObject.refresh()
	end

end

-- Hooks
Hooks:Add("BlackMarketGUIPostSetup", "BlackMarketGUIPostSetup_", function(gui, is_start_page, component_data)

	gui.modshop_purchase_weaponmod_callback = function(self, data)
		ModShop:AttemptItemPurchase( data, true )
	end

	gui.modshop_purchase_mask_callback = function(self, data)
		ModShop:AttemptItemPurchase( data )
	end

	gui.modshop_purchase_mask_part_callback = function(self, data)
		ModShop:AttemptItemPurchase( data )
	end

	local wm_modshop = {
		prio = 5,
		btn = "BTN_BACK",
		pc_btn = "toggle_chat",
		name = "gm_gms_purchase",
		callback = callback(gui, gui, "modshop_purchase_weaponmod_callback")
	}

	local bm_modshop = {
		prio = 5,
		btn = "BTN_BACK",
		pc_btn = "toggle_chat",
		name = "gm_gms_purchase",
		callback = callback(gui, gui, "modshop_purchase_mask_callback")
	}

	local mp_modshop = {
		prio = 5,
		btn = "BTN_BACK",
		pc_btn = "toggle_chat",
		name = "gm_gms_purchase",
		callback = callback(gui, gui, "modshop_purchase_mask_part_callback")
	}

	local btn_x = 10
	gui._btns["wm_modshop"] = BlackMarketGuiButtonItem:new(gui._buttons, wm_modshop, btn_x)
	gui._btns["bm_modshop"] = BlackMarketGuiButtonItem:new(gui._buttons, bm_modshop, btn_x)
	gui._btns["mp_modshop"] = BlackMarketGuiButtonItem:new(gui._buttons, mp_modshop, btn_x)

end)

Hooks:Add("BlackMarketGUIOnPopulateModsActionList", "BlackMarketGUIOnPopulateModsActionList_", function(gui, data)
	if ModShop:VerifyItemPurchase( data, true ) then
		table.insert(data, "wm_modshop")
	end
end)

Hooks:Add("BlackMarketGUIOnPopulateBuyMasksActionList", "BlackMarketGUIOnPopulateBuyMasksActionList_", function(gui, data)
	if ModShop:VerifyItemPurchase( data, false ) then
		table.insert(data, "bm_modshop")
	end
end)

Hooks:Add("BlackMarketGUIOnPopulateMaskModsActionList", "BlackMarketGUIOnPopulateMaskModsActionList_", function(gui, data)
	if ModShop:VerifyItemPurchase( data, false ) then
		table.insert(data, "mp_modshop")
	end
end)

Hooks:Add("BlackMarketGUIOnPopulateMaskMods", "BlackMarketGUIOnPopulateMaskMods_", function(gui, data)

	local category = data.category

	-- If we've purchased an item from this category then forcefully add that item when we force reload the gui
	-- That way we don't have to stop customizing the mask and reload the gui for it to appear anymore
	if data.on_create_data and ModShop._purchased_mask_mods and ModShop._purchased_mask_mods[category] then

		for k, v in pairs( ModShop._purchased_mask_mods[category] ) do

			for i, mods in pairs(data.on_create_data) do
				if mods.id == v then
					mods.amount = mods.amount + 1
				end
			end

		end

		ModShop._purchased_mask_mods[category] = nil

		-- Search compatibility, repopulate our inventory and then re-filter it
		if gui._search_bar and gui._search_bar:has_search() then
			gui._search_bar:do_search()
		end

	end

end)

Hooks:Add("BlackMarketManagerModifyGetInventoryCategory", "BlackMarketManagerModifyGetInventoryCategory_", function(blackmarket, category, data)

	local blackmarket_table = {}
	for k, v in pairs( tweak_data.blackmarket[category] ) do

		local already_in_table = blackmarket_table[v.id]
		for x, y in pairs( data ) do
			blackmarket_table[y.id] = true
			if y.id == k then
				already_in_table = true
			end
		end

		local global_value = v.infamous and "infamous" or v.global_value or v.dlc or v.dlcs and v.dlcs[math.random(#v.dlcs)] or "normal"
		if not already_in_table and not ModShop:IsItemExluded(k) then
			
			local add_item = true
			if ModShop:IsGlobalValueDLC( global_value ) and not managers.dlc:is_dlc_unlocked( global_value ) then
				add_item = false
			end

			if add_item then
				local item_data = {
					id = k,
					global_value = global_value,
					amount = 0
				}
				table.insert(data, item_data)
			end

		end
		
	end

end)

-- Extended Inventory
_G.GageModShop.ExtendedInventory = _G.GageModShop.ExtendedInventory or {}
local ExtendedInv = _G.GageModShop.ExtendedInventory
ExtendedInv.InitialLoadComplete = false
ExtendedInv.RegisteredItems = {}
ExtendedInv.SaveFile = SavePath .. "goonmod_inventory.txt"
ExtendedInv.OldFormatSaveFile = SavePath .. "inventory.ini"

ExtendedInv.Items = {}
ExtendedInv.RedeemedCodes = {}

ExtendedInv.APIRedeem = "http://api.paydaymods.com/goonmod/redeem/{1}"
ExtendedInv.APIRedeemInfo = "http://api.paydaymods.com/goonmod/redeem_info/{1}"

-- Menu Layout
local redeem_max_items_w = 5
local item_padding = 8
local function make_fine_text(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
	return text:x(), text:y(), w, h
end

-- Initialize
Hooks:RegisterHook("ExtendedInventoryInitialized")
Hooks:Add("GoonBasePostLoadedMods", "GoonBasePostLoadedMods_ExtendedInv", function()
	Hooks:Call("ExtendedInventoryInitialized")
end)

-- Functions
function _MissingItemError(item)
	Print("[Error] Could not find item '" .. item .. "' in Extended Inventory!")
end

function ItemIsRegistered(id)
	return ExtendedInv.RegisteredItems[id] == true
end

function RegisterItem(data)

	if not ExtendedInv.InitialLoadComplete then
		Load()
		ExtendedInv.InitialLoadComplete = true
	end

	ExtendedInv.RegisteredItems[data.id] = true
	ExtendedInv.Items[data.id] = ExtendedInv.Items[data.id] or {}
	for k, v in pairs( data ) do
		ExtendedInv.Items[data.id][k] = v
	end
	ExtendedInv.Items[data.id].amount = ExtendedInv.Items[data.id].amount or 0

end

function AddItem(item, amount)
	if ExtendedInv.Items[item] ~= nil then
		ExtendedInv.Items[item].amount = ExtendedInv.Items[item].amount + amount
		Save()
	else
		_MissingItemError(item)
	end
end

function TakeItem(item, amount)
	if ExtendedInv.Items[item] ~= nil then
		ExtendedInv.Items[item].amount = ExtendedInv.Items[item].amount - amount
		Save()
	else
		_MissingItemError(item)
	end
end

function SetItemAmount(item, amount)
	if ExtendedInv.Items[item] ~= nil then
		ExtendedInv.Items[item].amount = amount
		Save()
	else
		_MissingItemError(item)
	end
end


function GetItem(item)
	return ExtendedInv.Items[item] or nil
end

function HasItem(item)
	if ExtendedInv.Items[item] == nil then
		return false
	end
	return ExtendedInv.Items[item].amount > 0 or nil
end

function GetAllItems()
	return ExtendedInv.Items
end

function GetReserveText(item)
	return item.reserve_text or managers.localization:text("bm_ex_inv_in_reserve")
end

-- Code Redemption
function GetDisplayDataForItem( data )

	local category = data.category
	local name = data.item

	if category == "extended_inv" then
		local item_data = self:GetItem( name )
		return managers.localization:text(item_data.name), item_data.texture
	end

	local item_data = tweak_data:get_raw_value("blackmarket", category, name)
	if not item_data then
		return nil, nil
	end

	local guis_catalog = "guis/"
	local bundle_folder = item_data.texture_bundle_folder
	if bundle_folder then
		guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
	end

	local bitmap_texture = guis_catalog  .. "textures/pd2/blackmarket/icons/{1}/" .. name
	local render_template = nil

	if category == "masks" then
		bitmap_texture = bitmap_texture:gsub("{1}", "masks")
	end
	if category == "weapon_mods" then
		bitmap_texture = bitmap_texture:gsub("{1}", "mods")
	end
	if category == "materials" then
		if item_data.bitmap_texture_override then
			bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/materials/" .. item_data.bitmap_texture_override
		else
			bitmap_texture = bitmap_texture:gsub("{1}", "materials")
		end
	end
	if category == "textures" then
		bitmap_texture = tweak_data.blackmarket[category][name].texture
		render_template = "VertexColorTexturedPatterns"
	end
	if category == "colors" then
		bitmap_texture = "guis/textures/pd2/blackmarket/icons/colors/color_bg"
	end

	return managers.localization:text(item_data.name_id), bitmap_texture, render_template

end

function IsItemColour( data )
	local category = data.category
	return category == "colors"
end

function GetColourSwatchColours( data )

	if not self:IsItemColour( data ) then
		return
	end

	local category = data.category
	local name = data.item
	local item_data = tweak_data:get_raw_value("blackmarket", category, name)
	if not item_data then
		return nil, nil
	end

	return item_data.colors[1], item_data.colors[2]

end

function HasUsedCode( code )
	for k, v in pairs( ExtendedInv.RedeemedCodes ) do
		if v == code then
			return true
		end
	end
	return false
end

function _ShowCodeRedeemWindow()

	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeem_window_title")
	dialog_data.text = managers.localization:text("gm_ex_inv_redeem_window_message")
	dialog_data.id = "ex_inv_redeem_window"

	local ok_button = {}
	ok_button.text = managers.localization:text("gm_ex_inv_redeem_window_accept")

	dialog_data.button_list = {ok_button}
	managers.system_menu:show_redeem_code_window( dialog_data )

end

function EnteredRedeemCode( code )

	if code:is_nil_or_empty() then
		return
	end

	self._code_to_redeem = code
	self:ShowContactingServerWindow()

	local api_url = ExtendedInv.APIRedeemInfo:gsub( "{1}", code:lower() )
	dohttpreq( api_url, function(data, id) self:RetrievedServerData( data, id ) end )

end

function RetrievedServerData( data, id )

	managers.system_menu:close("ex_inv_redeem_attempt")

	if data:is_nil_or_empty() then
		self:ShowFailedToContactServerWindow()
		return
	end

	local code_data = json.decode( data )
	if code_data.success then
		if not self:HasUsedCode( code_data.code ) then
			self:ShowRedeemInfoWindow( code_data.data )
		else
			self:ShowCodeRedeemFailureWindow( "already_used" )
		end
	else
		self:ShowCodeRedeemFailureWindow( code_data.code )
	end

end

function ShowContactingServerWindow()
	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeem_contact_title")
	dialog_data.text = managers.localization:text("gm_ex_inv_redeem_contact_message")
	dialog_data.id = "ex_inv_redeem_attempt"
	dialog_data.no_buttons = true
	dialog_data.indicator = true
	managers.system_menu:show(dialog_data)
end

function ShowFailedToContactServerWindow()
	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeem_contact_failed_title")
	dialog_data.text = managers.localization:text("gm_ex_inv_redeem_contact_failed_message")
	dialog_data.id = "ex_inv_redeem_failed"
	local ok_button = {}
	ok_button.text = managers.localization:text("dialog_ok")
	dialog_data.button_list = {ok_button}
	managers.system_menu:show(dialog_data)
end

function ShowCodeRedeemFailureWindow( error )

	local errors = {
		["not_found"] = "gm_ex_inv_redeem_invalid_not_found",
		["no_uses_remaining"] = "gm_ex_inv_redeem_invalid_no_uses_left",
		["already_used"] = "gm_ex_inv_redeem_invalid_already_used"
	}

	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeem_invalid_title")
	dialog_data.text = managers.localization:text( errors[error] )
	dialog_data.id = "ex_inv_redeem_failed"
	local ok_button = {}
	ok_button.text = managers.localization:text("dialog_ok")
	dialog_data.button_list = {ok_button}
	managers.system_menu:show(dialog_data)

end

function ShowRedeemInfoWindow( data )
	
	data = json.decode( data )

	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeem_info_title")
	dialog_data.text = managers.localization:text("gm_ex_inv_redeem_info_message")
	dialog_data.id = "ex_inv_redeem_attempt"

	local ok_button = {}
	ok_button.text = managers.localization:text("gm_ex_inv_redeem_info_accept")
	ok_button.callback_func = callback(self, self, "RedeemCode")

	local cancel_button = {}
	cancel_button.text = managers.localization:text("gm_ex_inv_redeem_info_cancel")
	cancel_button.cancel_button = true

	dialog_data.button_list = {ok_button, cancel_button}
	dialog_data.items = data
	managers.system_menu:show_redeem_code_items_window( dialog_data )

end

function RedeemCode()

	if not self._code_to_redeem then
		return
	end

	local code = self._code_to_redeem
	self._code_to_redeem = nil

	self:ShowContactingServerWindow()

	local api_url = ExtendedInv.APIRedeem:gsub( "{1}", code:lower() )
	dohttpreq( api_url, function(data, id) self:RedeemedCode( data, id ) end )

end

function RedeemedCode( data, id )

	managers.system_menu:close("ex_inv_redeem_attempt")

	if data:is_nil_or_empty() then
		self:ShowFailedToContactServerWindow()
		return
	end

	local code_data = json.decode( data )
	code_data.data = json.decode( code_data.data )

	if code_data.success then

		self:AddRedeemedItemsToInventory( code_data.data )
		self:ShowRedeemedCodeWindow( code_data.data )

		table.insert( ExtendedInv.RedeemedCodes, code_data.code )
		self:Save()

	else
		self:ShowCodeRedeemFailureWindow( code_data.code )
	end

end

function ShowRedeemedCodeWindow( data )

	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeemed_confirm_title")
	dialog_data.text = managers.localization:text("gm_ex_inv_redeemed_confirm_message")
	dialog_data.id = "ex_inv_redeemed_items"

	local ok_button = {}
	ok_button.text = managers.localization:text("gm_ex_inv_redeemed_confirm_accept")
	ok_button.cancel_button = true

	dialog_data.button_list = {ok_button}
	dialog_data.items = data
	managers.system_menu:show_redeem_code_items_window( dialog_data )

end

function AddRedeemedItemsToInventory( data )

	for k, v in pairs( data ) do

		local name = v.item
		local category = v.category
		local quantity = v.quantity

		if category == "extended_inv" then
			self:AddItem(name, quantity)
		else

			local entry = tweak_data:get_raw_value("blackmarket", category, name)
			if entry then
				for i = 1, quantity or 1 do
					local global_value = entry.infamous and "infamous" or entry.global_value or entry.dlc or entry.dlcs and entry.dlcs[math.random(#entry.dlcs)] or "normal"
					managers.blackmarket:add_to_inventory(global_value, category, name)
				end
			end

		end

	end

end

-- Hooks
Hooks:Add("BlackMarketGUIPostSetup", "BlackMarketGUIPostSetup_ExtendedInventory", function(gui, is_start_page, component_data)
	gui.identifiers.extended_inv = Idstring("extended_inv")
end)

function ExtendedInv.do_populate_extended_inventory(self, data)

	local new_data = {}
	local guis_catalog = "guis/"
	local index = 0

	for i, item_data in pairs( GetAllItems() ) do

		local hide = item_data.hide_when_none_in_stock or false
		if ItemIsRegistered(i) and (hide == false or (hide == true and item_data.amount > 0)) then

			local item_id = item_data.id
			local name_id = item_data.name
			local desc_id = item_data.desc
			local texture_id = item_data.texture

			index = index + 1
			new_data = {}
			new_data.name = item_id
			new_data.name_localized = managers.localization:text( name_id )
			new_data.desc_localized = managers.localization:text( desc_id )
			new_data.category = "extended_inv"
			new_data.slot = index
			new_data.amount = item_data.amount
			new_data.unlocked = (new_data.amount or 0) > 0
			new_data.level = item_data.level or 0
			new_data.skill_based = new_data.level == 0
			new_data.skill_name = new_data.level == 0 and "bm_menu_skill_locked_" .. new_data.name
			new_data.bitmap_texture = texture_id
			new_data.lock_texture = self:get_lock_icon(new_data)
			data[index] = new_data

		end

	end

	-- Fill empty slots
	local max_items = data.override_slots[1] * data.override_slots[2]
	for i = 1, max_items do
		if not data[i] then
			new_data = {}
			new_data.name = "empty"
			new_data.name_localized = ""
			new_data.desc_localized = ""
			new_data.category = "extended_inv"
			new_data.slot = i
			new_data.unlocked = true
			new_data.equipped = false
			data[i] = new_data
		end
	end

end

Hooks:Add("BlackMarketGUIStartPageData", "BlackMarketGUIStartPageData_ExtendedInventory", function(gui, data)

	local should_hide_tab = true
	for k, v in pairs( GetAllItems() ) do
		if v.hide_when_none_in_stock == false or (v.hide_when_none_in_stock == true and v.amount > 0) then
			should_hide_tab = false
		end
	end
	if should_hide_tab then
		return
	end

	gui.populate_extended_inventory = ExtendedInv.do_populate_extended_inventory

	table.insert(data, {
		name = "bm_menu_extended_inv",
		category = "extended_inv",
		on_create_func_name = "populate_extended_inventory",
		identifier = gui.identifiers.extended_inv,
		override_slots = {5, 2},
		start_crafted_item = 1
	})

end)

Hooks:Add("BlackMarketGUIUpdateInfoText", "BlackMarketGUIUpdateInfoText_ExtendedInventory", function(gui)

	local self = gui
	local slot_data = self._slot_data
	local tab_data = self._tabs[self._selected]._data
	local prev_data = tab_data.prev_node_data
	local ids_category = slot_data and slot_data.category and Idstring(slot_data.category)
	local identifier = tab_data.identifier
	local updated_texts = {
		{text = ""},
		{text = ""},
		{text = ""},
		{text = ""},
		{text = ""}
	}
	
	if ids_category == self.identifiers.extended_inv then

		updated_texts[1].text = slot_data.name_localized or ""
		updated_texts[2].text = tostring(slot_data.amount or 0) .. " " .. GetReserveText(slot_data.name)
		updated_texts[4].text = slot_data.desc_localized or ""

		gui:_update_info_text(slot_data, updated_texts)

	end

end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_", function(menu_manager, menu_nodes)

	-- Menu
	MenuCallbackHandler.extended_inv_open_redeem_code = function(this, item)
		_ShowCodeRedeemWindow()
	end

	MenuHelper:AddButton({
		id = "gm_ex_inv_redeem_button",
		title = "gm_ex_inv_redeem_code",
		desc = "gm_ex_inv_redeem_code_desc",
		callback = "extended_inv_open_redeem_code",
		menu_id = "goonbase_options_menu",
		priority = 100,
	})

	MenuHelper:AddDivider({
		id = "gm_ex_inv_divider",
		menu_id = "goonbase_options_menu",
		size = 16,
		priority = 0,
	})

end)

Hooks:Add("GageAssignmentManagerOnMissionCompleted", "GageAssignmentManagerOnMissionCompleted_", function(assignment_manager)

	local self = assignment_manager
	local total_pickup = 0

	if self._progressed_assignments then
		for assignment, value in pairs(self._progressed_assignments) do

			if value > 0 then

				local collected = Application:digest_value(self._global.active_assignments[assignment], false) + value
				local to_aquire = self._tweak_data:get_value(assignment, "aquire") or 1
				while collected >= to_aquire do
					collected = collected - to_aquire
					managers.custom_safehouse:add_coins( tweak_data.safehouse.rewards.challenge )
				end

			end

			total_pickup = total_pickup + value
		end
	end

end)