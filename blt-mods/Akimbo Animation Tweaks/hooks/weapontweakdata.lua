Hooks:PostHook(WeaponTweakData, "init", "akimboanim_init", function(self)

    self.x_judge.weapon_hold = "x_chinchilla"
    self.x_judge.animations.reload_name_id = "x_chinchilla"
	self.x_judge.animations.second_gun_versions = self.x_judge.animations.second_gun_versions or {}
    self.x_judge.animations.second_gun_versions.reload = "reload"
	self.x_judge.sounds.reload = {
		wp_chinchilla_cylinder_out = "wp_rbull_drum_open",
		wp_chinchilla_eject_shells = "wp_rbull_shells_out",
		wp_chinchilla_insert = "wp_rbull_shells_in",
		wp_chinchilla_cylinder_in = "wp_rbull_drum_close"
	}
	
    self.x_rage.weapon_hold = "x_chinchilla"
    self.x_rage.animations.reload_name_id = "x_chinchilla"
	self.x_rage.animations.second_gun_versions = self.x_rage.animations.second_gun_versions or {}
    self.x_rage.animations.second_gun_versions.reload = "reload"
	self.x_rage.sounds.magazine_empty = nil
	self.x_rage.sounds.reload = {
		wp_chinchilla_cylinder_out = "wp_rbull_drum_open",
		wp_chinchilla_eject_shells = "wp_rbull_shells_out",
		wp_chinchilla_insert = "wp_rbull_shells_in",
		wp_chinchilla_cylinder_in = "wp_rbull_drum_close"
	}
	
    self.x_2006m.weapon_hold = "x_chinchilla"
    self.x_2006m.animations.reload_name_id = "x_chinchilla"
	self.x_2006m.sounds.magazine_empty = nil
	self.x_2006m.hidden_parts = {
		magazine = {"g_loader_lod0"}
	}
	self.x_2006m.sounds.reload = {
		wp_chinchilla_cylinder_out = "wp_mateba_open_barrel",
		wp_chinchilla_eject_shells = "wp_mateba_empty_barrel",
		wp_chinchilla_insert = "wp_mateba_put_in_bullets",
		wp_chinchilla_twist = "wp_mateba_speedloader_lid",
		wp_rbull_shell_hit_ground = "wp_mateba_shell_hit_ground",
		wp_chinchilla_cylinder_in = "wp_mateba_close_barrel"
	}


    self.x_coal.weapon_hold = "x_akmsu"
    self.x_coal.animations.reload_name_id = "x_akmsu"
	self.x_coal.sounds.reload = {
		wp_akmsu_x_take_new = "wp_coal_take_new_mag",
		wp_akmsu_x_clip_slide_out = "wp_coal_mag_out_back",
		wp_akmsu_x_clip_slide_in = "wp_coal_mag_in_front",	
		wp_akmsu_x_clip_in_contact = "wp_coal_mag_in_back",
		wp_akmsu_x_lever_pull = "wp_coal_pull_lever",
		wp_akmsu_x_lever_release = "wp_coal_release_lever"
	}
	
    self.x_rota.weapon_hold = "x_akmsu"
    self.x_rota.animations.reload_name_id = "x_basset"
	self.x_rota.sounds.reload = {
		wp_foley_generic_clip_take_new = "wp_rota_x_rotate_mag",
		basset_x_mag_out = "wp_rota_x_slide_out",
		basset_x_mag_in = "wp_rota_x_slide_in",	
		basset_x_lever_release = "wp_rota_x_grab_lift"
	}
	
	self.x_sparrow.sounds.reload = {
		wp_g17_clip_slide_out = "wp_sparrow_mag_out",
		wp_g17_clip_slide_in = "wp_sparrow_mag_in",
		wp_g17_lever_release = "wp_sparrow_cock"
	}
	
	self.x_pl14.sounds.reload = {
		wp_g17_clip_slide_out = "wp_sparrow_mag_out",
		wp_g17_clip_slide_in = "wp_sparrow_mag_in",
		wp_g17_lever_release = "wp_sparrow_cock"
	}
	
	self.x_hs2000.sounds.reload = {
		wp_g17_clip_slide_out = "wp_usp_clip_out",
		wp_g17_clip_slide_in = "wp_usp_clip_slide_in"
	}
	
	self.x_1911.sounds.reload = {
		wp_g17_clip_slide_out = "wp_usp_clip_out",
		wp_g17_clip_slide_in = "wp_usp_clip_slide_in"
	}

	self.x_p226.sounds.reload = {
		wp_g17_clip_slide_out = "wp_usp_clip_out",
		wp_g17_clip_slide_in = "wp_usp_clip_slide_in"
	}
	
	self.x_usp.sounds.reload = {
		wp_g17_clip_slide_out = "wp_usp_clip_out",
		wp_g17_clip_slide_in = "wp_usp_clip_slide_in"
	}
	
	self.x_packrat.sounds.reload = {
		wp_g17_clip_slide_out = "wp_packrat_mag_throw",
		wp_g17_clip_slide_in = "wp_packrat_mag_in",
		wp_g17_clip_grab = "wp_packrat_mag_contact",
		wp_g17_lever_release = "wp_packrat_slide_release"
	}
	
	self.x_hajk.sounds.reload = {
		wp_akmsu_x_clip_slide_out = "hajk_throw_mag",
		wp_akmsu_x_clip_slide_in = "hajk_push_in_mag",	
		wp_akmsu_x_clip_in_contact = "hajk_mag_contact",
		wp_akmsu_x_lever_pull = "hajk_pull_lever",
		wp_akmsu_x_lever_release = "hajk_release_lever"
	}
	
	self.x_mac10.sounds.reload = {
		wp_akmsu_x_clip_slide_out = "wp_mac10_clip_slide_out",
		wp_akmsu_x_clip_slide_in = "wp_mac10_clip_slide_in",	
		wp_akmsu_x_clip_in_contact = "wp_mac10_clip_in_contact",
		wp_akmsu_x_lever_pull = "wp_mac10_lever_pull",
		wp_akmsu_x_lever_release = "wp_mac10_lever_release"
	}
	
	self.x_cobray.sounds.reload = {
		wp_akmsu_x_clip_slide_out = "wp_mac10_clip_slide_out",
		wp_akmsu_x_clip_slide_in = "wp_mac10_clip_slide_in",	
		wp_akmsu_x_clip_in_contact = "wp_mac10_clip_in_contact",
		wp_akmsu_x_lever_pull = "wp_cobray_lever_pull",
		wp_akmsu_x_lever_release = "wp_cobray_lever_release"
	}
	
	self.x_scorpion.sounds.reload = {
		wp_akmsu_x_take_new = "wp_scorpion_clip_grab",
		wp_akmsu_x_clip_slide_out = "wp_scorpion_clip_slide_out",
		wp_akmsu_x_clip_slide_in = "wp_scorpion_clip_slide_in",	
		wp_akmsu_x_clip_in_contact = "wp_scorpion_clip_in_contact",
		wp_akmsu_x_lever_pull = "wp_scorpion_lever_pull",
		wp_akmsu_x_lever_release = "wp_scorpion_lever_release"
	}
	
	self.x_baka.sounds.reload = {
		wp_akmsu_x_take_new = "wp_baka_take_new",
		wp_akmsu_x_clip_slide_out = "wp_baka_mag_slide_out",
		wp_akmsu_x_clip_slide_in = "wp_baka_mag_slide_in",	
		wp_akmsu_x_clip_in_contact = "",
		wp_akmsu_x_lever_pull = "wp_baka_lever_pull",
		wp_akmsu_x_lever_release = "wp_baka_lever_release"
	}
	
	self.x_mp9.sounds.reload = {
		wp_akmsu_x_clip_slide_out = "wp_mac10_clip_slide_out",
		wp_akmsu_x_clip_slide_in = "wp_mac10_clip_slide_in",	
		wp_akmsu_x_clip_in_contact = "wp_mac10_clip_in_contact",
		wp_akmsu_x_lever_pull = "wp_mac10_lever_pull",
		wp_akmsu_x_lever_release = "wp_mac10_lever_release"
	}
	
	self.x_olympic.sounds.reload = {
		wp_akmsu_x_take_new = "wp_m4_clip_take_new",
		wp_akmsu_x_clip_slide_out = "wp_m4_clip_grab_out",
		wp_akmsu_x_clip_slide_in = "wp_m4_clip_slide_in",	
		wp_akmsu_x_clip_in_contact = "wp_m4_clip_in_contact",
		wp_akmsu_x_lever_pull = "wp_m4_lever_pull_in",
		wp_akmsu_x_lever_release = "wp_m4_lever_release"
	}
	
	--Reload sounds weren't included in the akimbo soundbank :rage:
	self.x_erma.sounds.reload = {
		wp_akmsu_x_take_new = "wp_erma_mag_grab_new",
		wp_akmsu_x_clip_slide_out = "wp_erma_mag_out",
		wp_akmsu_x_clip_slide_in = "wp_erma_mag_in",	
		wp_akmsu_x_clip_in_contact = "wp_erma_mag_connect",
		wp_akmsu_x_lever_pull = "wp_erma_slide_pull",
		wp_akmsu_x_lever_release = "wp_erma_slide_release"
	}
	
	self.x_tec9.sounds.reload = {
		wp_akmsu_x_take_new = "wp_tec9_clip_take_new",
		wp_akmsu_x_clip_slide_out = "wp_tec9_clip_slide_out",
		wp_akmsu_x_clip_slide_in = "wp_tec9_clip_slide_in",	
		wp_akmsu_x_clip_in_contact = "wp_tec9_clip_in_contact",
		wp_akmsu_x_lever_pull = "wp_tec9_lever_pull",
		wp_akmsu_x_lever_release = "wp_tec9_lever_release"
	}
	
	self.x_uzi.sounds.reload = {
		wp_akmsu_x_take_new = "wp_uzi_clip_take_new",
		wp_akmsu_x_clip_slide_out = "wp_uzi_clip_slide_out",
		wp_akmsu_x_clip_slide_in = "wp_uzi_clip_slide_in",	
		wp_akmsu_x_clip_in_contact = "",
		wp_akmsu_x_lever_pull = "wp_uzi_clip_lever_pull",
		wp_akmsu_x_lever_release = "wp_uzi_clip_lever_release"
	}
	
	self.x_m45.sounds.reload = {
		wp_akmsu_x_take_new = "wp_m45_clip_take_new",
		wp_akmsu_x_clip_slide_out = "wp_m45_clip_grab_out",
		wp_akmsu_x_clip_slide_in = "wp_m45_clip_slide_in",	
		wp_akmsu_x_clip_in_contact = "wp_m45_clip_in_contact",
		wp_akmsu_x_lever_pull = "wp_m45_lever_pull",
		wp_akmsu_x_lever_release = "wp_m45_lever_release"
	}
	
	self.x_mp7.sounds.reload = {
		wp_akmsu_x_take_new = "wp_mp7_clip_take_new",
		wp_akmsu_x_clip_slide_in = "wp_mp7_clip_slide_in"
	}
end)