function PlayerTweakData:ApplyPVMSaveOnTweak()
	self.default_stances = self.default_stances or {}
	local saved = PVM.Options:GetValue("Saved")
	local apply_on_all = PVM.Options:GetValue("ApplyOnAll")	
	for name, stance in pairs(self.stances) do
		for mode_name, mode in pairs(stance) do
			if mode.shoulders then
				local default_stance = self.default_stances[name][mode_name]
				mode.shoulders.translation = mvector3.copy(default_stance.translation)
				mode.shoulders.rotation = mrotation.copy(default_stance.rotation)
				local saved_weapon = apply_on_all and saved.__All or saved[name]
				if saved_weapon and saved_weapon[mode_name] and saved_weapon[mode_name].shoulders then
					local shoulders = saved_weapon[mode_name].shoulders
					if shoulders.translation then
                        mode.shoulders.translation = mvector3.copy(shoulders.translation)
					end
					if shoulders.rotation then
                        mode.shoulders.rotation = mrotation.copy(shoulders.rotation)
					end
				end
			end
		end
	end
end

Hooks:PostHook(PlayerTweakData, "init", "PVMInit", function(self)
	self.default_stances = {}
	for name, stance in pairs(self.stances) do
		self.default_stances[name] = {}
		for mode_name, mode in pairs(stance) do
			if mode.shoulders then
				self.default_stances[name][mode_name] = {
					translation = mvector3.copy(mode.shoulders.translation or Vector3()),
					rotation = mrotation.copy(mode.shoulders.rotation or Rotation())
				}
			end
		end
	end
	self:ApplyPVMSaveOnTweak()
end)