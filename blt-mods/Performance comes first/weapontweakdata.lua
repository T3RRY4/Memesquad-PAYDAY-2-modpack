local init_orig = WeaponTweakData.init
function WeaponTweakData:init(...)
    init_orig(self, ...)
	
	for k,v in pairs(self) do
		if type(v) == 'table' and v.categories then
			for k2,v2 in pairs(v.categories) do
				if v2 == 'shotgun' then
					local name = k..'_crew'
					if self[name] then
						self[name].rays = 4
					end
					break
				end
			end
		end
	end
end