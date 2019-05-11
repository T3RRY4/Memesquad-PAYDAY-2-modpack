
local toggle1 = true
local toggle2 = true
local upd_orig = NetworkManager.update
function NetworkManager:update(t, dt)
	if self._stop_next_frame then
		self:stop_network(true)

		self._stop_next_frame = nil

		return
	end

	if toggle1 then
		if toggle2 then
			if self._session then
				self._session:update()
			end
			toggle2 = false
		else
			if self.matchmake then
				self.matchmake:update()
			end
			toggle2 = true
			toggle1 = false
		end
	else
		if toggle2 then
			if self.voice_chat then
				self.voice_chat:update(t)
			end
			toggle2 = false
		else
			if self.account then
				self.account:update()
			end
			toggle2 = true
			toggle1 = true
		end
	end
end