Hooks:PostHook(WeaponFactoryTweakData, "init", "akimboanimfactory_init", function(self)

	self.wpn_fps_pis_x_judge.override.wpn_fps_pis_judge_body_standard = {}
	self.wpn_fps_pis_x_judge.override.wpn_fps_pis_judge_body_modern = {}
	
	self.wpn_fps_pis_x_rage.override.wpn_fps_pis_rage_body_standard = {}
	self.wpn_fps_pis_x_rage.override.wpn_fps_pis_rage_body_smooth = {}
	
	self.wpn_fps_pis_x_2006m.override.wpn_fps_pis_2006m_body_standard = {}
	self.wpn_fps_pis_x_2006m.override.wpn_fps_pis_2006m_m_standard = {}
	
	self.wpn_fps_smg_x_m1928.override.wpn_fps_smg_thompson_drummag = {animations = {}}

end)