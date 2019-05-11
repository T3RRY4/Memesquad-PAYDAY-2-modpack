local init_orig = ElementAreaTrigger.init
function ElementAreaTrigger:init(...)
	init_orig(self, ...)
	if self._values.interval and self._values.interval < 0.1 then
		self._values.interval = 0.1
	end
end