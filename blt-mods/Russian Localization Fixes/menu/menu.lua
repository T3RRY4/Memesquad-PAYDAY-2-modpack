local settings = {}

local options = {
	menu_difficulty_easy_wish = { 'Хаос', 'Беспредел', 'Mayhem' },
	heist_run = { 'Жара на улице', 'Уличная схватка', 'Heat street' },
	heist_nmh = { 'Нет милосердию', 'Госпиталь "Милосердие"', 'Госпиталь Mercy', 'No Mercy' },
	heist_des = { 'Утес Генри', 'Скала Генри', 'Henry\'s Rock' },
	heist_red2 = { 'Первый Мировой Банк', 'Первый Всемирный Банк', 'First World Bank' },
	heist_peta = { 'Симулятор козла', 'Goat Simulator' },
	heist_dah = { 'Кража бриллиантов', 'Diamond Heist' },
	heist_born = { 'Разборки на поезде', 'Ограбление байкеров', 'The Biker Heist' },
	heist_glace = { 'Мост Green', 'Зеленый мост', 'Green bridge' },
	heist_sah = { 'Аукцион Shacklethorne', 'Аукцион Шаклторн', 'Аукцион', 'Shacklethorne auction' },
	heist_mia = { 'Горячая линия Майами', 'Hotline Miami' },
	heist_friend = { 'Особняк Лица со шрамом', 'Особняк Тони Монтана', 'Scarface Mansion' },
	menu_jowi = { 'Джон Уик', 'Уик', 'John Wick' },
	menu_toggle_one_down = { 'Одно падение', 'One Down' },
	menu_chico = { 'Лицо со шрамом', 'Тони', 'Scarface' }
}

local current_version = 3
local versions = {
	version_2 = { heist_nmh = { { 3, 4 }, { 4, 5 } } },
	version_3 = { menu_difficulty_easy_wish = { { 2, 3 }, { 3, 4 } } }
}

local ee_triggered = false
local options_more = {
	heist_rat = { 'Варка мета', 'Жарка мета', 'Cook off' },
	heist_nmh = { 'Жара в госпитале' },
	heist_des = { 'Утес Жары' },
	heist_red2 = { 'Первая всемирная Жара' },
	heist_peta = { 'Симулятор Жары' },
	heist_born = { 'Жаркие разборки' },
	heist_glace = { 'Зеленая Жара' },
	heist_sah = { 'Аукцион Жары' },
	heist_dah = { 'Кража Жары' },
	heist_shoutout_raid = { 'Ядерная угроза', 'Жаркая угроза', 'Meltdown' },
	heist_kenaz = { 'Казино Golden Grin', 'Казино Золотой Жары', 'Golden Grin Casino' },
	heist_rvd = { 'Бешеные псы', 'Бешеная Жара', 'Reservoir Dogs' },
	heist_bph = { 'Адский остров', 'Адская Жара', 'Hell\'s Island' },
	heist_pal = { 'Подделка', 'Поджарка', 'Counterfeit' },
	heist_wwh = { 'Дело на Аляске', 'Жара на Аляске', 'Alaskan Deal' },
	heist_pbr2 = { 'Рождение небес', 'Рождение Жары', 'Birth of Sky' },
	heist_spa = { 'Бруклин 10-10', 'Жара 10-10', 'Brooklyn 10-10' },
	heist_cage = { 'Автосалон', 'Жаросалон', 'Car shop' },
	heist_family = { 'Бриллиантовый магазин', 'Бриллиантовая жара', 'Diamond Store' },
	heist_election_day = { 'День выборов', 'День Жары', 'Election Day' },
	heist_nightclub = { 'Ночной клуб', 'Жаркий клуб', 'Nightclub' },
	heist_help = { 'Тюремный кошмар', 'Жара в тюрьме', 'Prison Nightmare' },
	heist_pbr = { 'У подножия горы', 'У подножия Жары', 'Beneath the Mountain' },
	heist_firestarter = { 'Поджигатель', 'Поджариватель', 'Firestarter' },
	heist_welcome_to_the_jungle = { 'Нефтяное дело', 'Жаркое дело', 'Big Oil' },
	menu_difficulty_easy_wish = { 'Жара' }
}

for k,v in pairs(options) do
	settings[k] = 1
end
settings.menu_difficulty_easy_wish = 3
settings.heist_mia = 2

local default_settings = {}
for k,v in pairs(settings) do
	default_settings[k] = v
end

local menu_titles = {}
for k,v in pairs(options) do
	menu_titles[k] = #v
end

local text_original = LocalizationManager.text
function LocalizationManager:text(string_id, ...)
	local res = text_original(self, string_id, ...)
	for k,v in pairs(settings) do
		local def = default_settings[k] or 1
		if def ~= v then
			res = res:gsub(options[k][def], options[k][v])
		end
	end
	return res
end

local thisPath
local thisDir
local upDir
local function Dirs()
	thisPath = debug.getinfo(2, "S").source:sub(2)
	thisDir = string.match(thisPath, '.*/')
	upDir = thisDir:match('(.*/).-/')
end
Dirs()
Dirs = nil

local function ReloadStrings()
	local strs = {}
	for k,v in pairs(settings) do
		strs[k] = options[k][v]
	end
	strs['ruslocfixes'] = 'Русская локализация'
	LocalizationManager:add_localized_strings(strs)
end

local function LoadSettings()
	local file = io.open(SavePath .. 'Russian localization.txt', "r")
	if file then
		local res = json.decode(file:read("*all")) or {}
		file:close()
		
		res.version = res.version or 1
		
		while res.version < current_version do
			res.version = res.version + 1
			local changes = versions['version_'..tostring(res.version)]
			for k,v in pairs(changes or {}) do
				if res[k] then
					for k2,v2 in ipairs(v or {}) do
						if res[k] == v2[1] then
							res[k] = v2[2]
							break
						end
					end
				end
			end
		end
		
		for k,v in pairs(res) do
			if options[k] then
				settings[k] = options[k][v] and v or 1
			elseif options_more[k] then
				ee_triggered = true
				for k2,v2 in pairs(options_more) do
					options[k2] = options[k2] or {}
					local size = #options[k2]
					for k3,v3 in pairs(v2) do
						options[k2][size + k3] = v3
					end
				end
				settings[k] = options[k][v] and v or 1
			end
		end
	end
end
LoadSettings()
ReloadStrings()

local function SaveSettings()
	local file = io.open(SavePath .. 'Russian localization.txt', "w")
	if file then
		local data = {}
		for k,v in pairs(settings or {}) do
			data[k] = v
		end
		data.version = current_version
		
		file:write(json.encode(data))
		file:close()
	end
end

local function AddMenuItem(item_id, choices)
	MenuHelper:AddMultipleChoice({
					id = item_id,
					title = choices[menu_titles[item_id] or #choices],
					desc = '',
					callback = 'ruslocfixes_toggle',
					items = choices,
					value = settings[item_id] or 1,
					default_value = 1,
					menu_id = 'ruslocfixes_opt',
					localized = false
				})
end

local function UnLocalizeMenuItems()
	local menu = MenuHelper:GetMenu('ruslocfixes_opt')
	if menu then
		for k,v in pairs(menu._items_list or {}) do
			if v._options then
				for k2,v2 in pairs(v._options) do
					if v2._parameters then
						menu._items_list[k]._options[k2]._parameters.localize = false
					end
				end
			end
		end
	end
end

local ee = ''
local ee_req = '12121234'
function MenuCallbackHandler:ruslocfixes_toggle(item)
	local index = item._parameters.name
	local val = item:value() or 1
	if options[index] then
		settings[index] = val
	end
	
	if not ee_triggered then
		ee = ee .. tostring(val)
		log(ee)
		if ee == ee_req then
			ee_triggered = true
			
			local menu = MenuHelper:GetMenu('ruslocfixes_opt')
			menu._items_list = {}
			menu:clean_items()
			
			for k,v in pairs(options_more) do
				options[k] = options[k] or {}
				local size = #options[k]
				for k2,v2 in pairs(v) do
					options[k][size + k2] = v2
				end
			end
			
			for k,v in pairs(options) do
				AddMenuItem(k,v)
			end
			
			UnLocalizeMenuItems()
			
			MenuHelper:BuildMenu('ruslocfixes_opt')
			
			managers.menu:back()
			managers.menu:open_node('ruslocfixes_opt')
		elseif not ee_req:match('^'..ee) then
			ee = ''
		end
	end
end

function MenuCallbackHandler:ruslocfixes_save()
	SaveSettings()
	ReloadStrings()
end

MenuHelper:LoadFromJsonFile(thisDir .. 'main.json', settings, settings)

Hooks:Add("MenuManagerPopulateCustomMenus", "PopulateCustomMenus_RusLocFixes", function( menu_manager, nodes )
	for k,v in pairs(options) do
		AddMenuItem(k,v)
	end
	
	UnLocalizeMenuItems()
end)