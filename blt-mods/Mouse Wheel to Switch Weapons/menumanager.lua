local mod_path = ModPath

Hooks:Add("MenuManagerInitialize", "scrollwheelswap_initmenus", function(menu_manager)
	MenuCallbackHandler.scrollwheelswap_showinfo = function(self)
		local title = managers.localization:text("sws_bind_info_title")
		local desc = managers.localization:text("sws_bind_info_long")
		local options = {
			{
				text = managers.localization:text("sws_ok"),
				is_cancel_button = true
			}
		}
		QuickMenu:new(title,desc,options,true)
	end
	MenuCallbackHandler.scrollwheelswap_bind_1 = function(self)
		--doesn't need to do anything. i mean, unless you want it to
	end
	MenuCallbackHandler.scrollwheelswap_bind_2 = function(self)
		--i can exec anything you want me to do baby
	end
	MenuHelper:LoadFromJsonFile(mod_path .. "menu.txt") --no settings, just the two keybinds
end)

Hooks:Add("LocalizationManagerPostInit", "scrollwheelswap_addlocalization", function( loc )
	loc:add_localized_strings(
		{
			sws_menu_title = "Mouse Wheel to Switch Weapons",
			sws_menu_desc = "Replace mousewheel with custom binds",
			sws_ok = "Got it!",
			sws_bind_info_title = "Manual Keybinds",
			sws_bind_info_desc = "Click for more information",
			sws_bind_info_long = "- This panel is for rebinding these two 'weapon switch' binds with keys or buttons of your own choosing.\n- Requires HoldTheKey mod to use custom binds.\n- If HoldTheKey is not installed, this mod will still function, using Mouse Wheel Up and Mouse Wheel Down and ignoring the binds in this panel.\n- Leave unbound to use Mouse Wheel Up/Down instead of custom binds.\n* Tip: You can unbind keys using the 'Escape' key with HoldTheKey.",
			sws_bind_1_title = "Weapon Switch Key 1",
			sws_bind_1_desc = "Defaults to Mouse Wheel Up if blank",
			sws_bind_2_title = "Weapon Switch Key 2",
			sws_bind_2_desc = "Defaults to Mouse Wheel Down if blank"
		}
	)
end)

