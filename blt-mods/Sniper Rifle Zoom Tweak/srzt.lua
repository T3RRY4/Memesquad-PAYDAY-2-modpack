-- Those who live by the sword get shot by those who don't.

local old_init = WeaponTweakData.init

function WeaponTweakData:init(tweak_data)
    old_init(self, tweak_data)
	--Sniper rifle zoom levels
	self.m95.stats.zoom = 3
	self.msr.stats.zoom = 3
	self.r93.stats.zoom = 3
	self.mosin.stats.zoom = 3
	self.winchester1874.stats.zoom = 3
	self.wa2000.stats.zoom = 3
	self.model70.stats.zoom = 3
	self.desertfox.stats.zoom = 3
	self.tti.stats.zoom = 3
	self.siltstone.stats.zoom = 3	
end