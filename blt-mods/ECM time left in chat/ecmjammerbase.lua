-- Inform when this number of seconds left
local low_time = 5

-- Message visible only to you (false) or to everyone (true)
local everyone = false

local prefix = 'ECM'
local message = ' seconds left'

----------------------------------
-- Do not change anything below --
----------------------------------

local counter = 0

local init_orig = ECMJammerBase.init
function ECMJammerBase:init(...)
	counter = counter + 1
	return init_orig(self, ...)
end

local upd_orig = ECMJammerBase.update
function ECMJammerBase:update(...)
	if self:active()
		and not self.notified
		and self._battery_life
		and self._battery_life < low_time
		and managers.chat
	then
		self.notified = true
		counter = counter - 1
		if counter == 0 then
			local peer = managers.network and managers.network:session() or nil
			peer = peer and peer:local_peer() or nil
			if everyone then
				managers.chat:send_message(1, peer, prefix..': '..low_time..message)
			elseif peer then
				managers.chat:_receive_message(1, prefix, low_time..message, Color.green)
			end
		end
	end
	return upd_orig(self, ...)
end