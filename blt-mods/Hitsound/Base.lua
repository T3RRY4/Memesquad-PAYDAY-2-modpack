if not ModCore then
	log("[ERROR][HitSound] BeardLib is not installed!")
	return
end
HitSound = HitSound or ModCore:new(ModPath .. "Config.xml", true, true)
if not PlayerManager then
	local movie_ids = Idstring("movie")
	function HitSound:Play(sound)
		if not self.Options:GetValue("On"..sound) then
			return
		end
		if not PackageManager:has(movie_ids, Idstring(sound)) then
			return
		end
		local p = managers.menu_component._main_panel
		local name = "hitsound"..sound
		if alive(p:child(name)) then
			managers.menu_component._main_panel:remove(p:child(name))
		end

		--stolen from nepgearsy xd
		local volume = managers.user:get_setting("sfx_volume")
		local percentage = (volume - tweak_data.menu.MIN_SFX_VOLUME) / (tweak_data.menu.MAX_SFX_VOLUME - tweak_data.menu.MIN_SFX_VOLUME)
		managers.menu_component._main_panel:video({
			name = name,
			video = sound,
			visible = false,
			loop = false,
		}):set_volume_gain(percentage)
	end
else
	Hooks:PostHook(PlayerManager, "on_damage_dealt", "HitSound.OnHit", ClassClbk(HitSound, "Play", "Hit"))
	Hooks:PostHook(PlayerManager, "on_killshot", "HitSound.OnKill", ClassClbk(HitSound, "Play", "Kill"))
	Hooks:PostHook(PlayerManager, "on_headshot_dealt", "HitSound.OnHead", ClassClbk(HitSound, "Play", "Head"))
end