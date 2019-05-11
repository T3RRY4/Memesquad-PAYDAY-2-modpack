Hooks:PostHook(NetworkPeer,"register_mod","Berserker_Help_mod_check_mods", function(self, id, friendly)
	if Berserker_Help_mod._settings.disable and friendly == "Berserker Live Matters" and LuaNetworking:IsHost() then
		if Berserker_Help_mod._fresh_joined[self:id()] then
			self:send("send_chat_message", 4, Berserker_Help_mod._disable_dlg)
			Berserker_Help_mod._fresh_joined[self:id()] = false
		end
		self:send("send_chat_message", 4, Berserker_Help_mod._disable_msg)
	end
end)

Hooks:Add("NetworkManagerOnPeerAdded", "Berserker_Help_mod_PeerAdded", function(peer, peer_id)
	Berserker_Help_mod._fresh_joined[peer_id] = true
end)