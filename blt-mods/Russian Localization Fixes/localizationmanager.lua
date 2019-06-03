RusLocaleFixes = {}

TheFixesPreventer = TheFixesPreventer or {}
TheFixesPreventer.achi_red_button_localeman = true
TheFixesPreventer.achi_hello_big_friend_localeman = true
TheFixesPreventer.achi_infamy_localeman = true
TheFixesPreventer.achi_euro_bag_sim_localeman = true
TheFixesPreventer.achi_big_brother_localeman = true

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


local locDir = thisDir..'loc/common'
local files = file.GetFiles(locDir)

locDir = locDir .. '/'

if files then
	for k,v in pairs(files) do
		dofile(locDir..v)
	end
end


Hooks:Add("LocalizationManagerPostInit", "RusLocFixes", function(loc)
	LocalizationManager:add_localized_strings(RusLocaleFixes)
	RusLocaleFixes = {}
	
	if Global.job_manager
		and Global.job_manager.current_job
		and Global.job_manager.current_job.job_id
	then 
		local levelFile = ''
		if Global.job_manager.current_job.job_id == 'crime_spree' then
			levelFile = thisDir..'loc/'..(Global.job_manager.current_job.level_id or '000'):gsub('_?%d$','')..'.lua'
		else
			levelFile = thisDir..'loc/'..Global.job_manager.current_job.job_id..'.lua'
		end
		local f,err = io.open(levelFile, 'r')
		if f then
			f:close()
			dofile(levelFile)
			LocalizationManager:add_localized_strings(RusLocaleFixes)
		elseif not Global.job_manager.current_job.level_id then
			local levelsDir = thisDir..'loc'
			local levelFiles = file.GetFiles(levelsDir)
			levelsDir = levelsDir .. '/'

			if levelFiles then
				for k,v in pairs(levelFiles) do
					dofile(levelsDir..v)
				end
			end
			
			LocalizationManager:add_localized_strings(RusLocaleFixes)
		end
	end
	
	RusLocaleFixes = nil
	
	dofile(thisDir..'menu/menu.lua')
end)