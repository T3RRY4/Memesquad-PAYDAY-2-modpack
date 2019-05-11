local _modpath = ModPath
Hooks:Add("LocalizationManagerPostInit", "VELOSync_Localization", function(loc)
	LocalizationManager:load_localization_file(_modpath.."/loc/en.txt")

	if Idstring("german"):key() == SystemInfo:language():key() then
		LocalizationManager:load_localization_file(_modpath.."/loc/de.txt")
	elseif Idstring("czech"):key() == SystemInfo:language():key() then
		LocalizationManager:load_localization_file(_modpath.."/loc/cz.txt")
	elseif Idstring("italian"):key() == SystemInfo:language():key() then
		LocalizationManager:load_localization_file(_modpath.."/loc/it.txt")
	end
end)
