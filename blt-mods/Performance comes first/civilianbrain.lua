local upd_orig = CivilianBrain.update
local updated = false
function CivilianBrain:update(unit, t, dt, ...)
	if self.updated == nil then
		if not updated then
			upd_orig(self, unit, t, dt*2, ...)
			updated = true
			self.updated = true
		else
			updated = false
		end
	else
		if self.updated then
			self.updated = false
			updated = false
		else
			upd_orig(self, unit, t, dt*2, ...)
			self.updated = true
		end
	end
end