function MenuBackdropGUI:set_background(menu)
	if not MenuBackgrounds.Options[menu] then
		return
	end
	local bg = "guis/textures/backgrounds/" .. (MenuBackgrounds.Options.UseStandard and "standard" or menu)
	for _, child in pairs(self._panel:children()) do
		child:hide()
		child:set_alpha(0)
	end
	self._panel:child("item_background_layer"):show()
	self._panel:child("item_background_layer"):set_alpha(1)			
	self._panel:child("item_foreground_layer"):show()
	self._panel:child("item_foreground_layer"):set_alpha(1)
	MenuBackgrounds:AddBackground(self._panel, menu)
end