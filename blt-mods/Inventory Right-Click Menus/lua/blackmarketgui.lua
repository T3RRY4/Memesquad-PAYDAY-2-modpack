function BlackMarketGui:show_right_click_menu( slot , x , y )

	if self._rc_menu then
		self:destroy_right_click_menu()
	end
	
	self._rc_menu = {}
	
	data = slot._data
	local btn_show_funcs = data.btn_show_funcs or {}
	
	self._rc_btns = {}
	local btn_show_func_name , btn_show_func
	for k , v in ipairs( data ) do
		btn_show_func_name = btn_show_funcs[ v ]
		btn_show_func = btn_show_func_name and callback( self , self , btn_show_func_name )
		
		if self._btns[ v ] and ( not btn_show_func or btn_show_func( data ) ) then
			table.insert( self._rc_btns , self._btns[ v ] )
		end
	end
	
	if next( self._rc_btns ) == nil then
		return
	end
	
	table.sort( self._rc_btns , function( x , y )
		return x._data.prio < y._data.prio
	end )
	
	self._rc_menu[ "bg_blur" ] = self._panel:bitmap({
		texture 		= "guis/textures/test_blur_df",
		w 				= 0,
		h 				= 0,
		layer 			= 99,
		render_template = "VertexColorTexturedBlur3D"
	})
	
	self._rc_menu[ "bg" ] = self._panel:rect({
		color 			= Color.black / 1.25,
		w 				= 0,
		h 				= 0,
		layer 			= 100
	})
	
	self._rc_menu[ "bg" ]:set_lefttop( x + 12 , y )
	self._rc_menu[ "bg_blur" ]:set_lefttop( self._rc_menu[ "bg" ]:lefttop() )
	
	for k , v in ipairs( self._rc_btns ) do
		self._rc_menu[ k ] = self._panel:text({
			text 		= v:btn_text(),
			blend_mode 	= "normal",
			font 		= tweak_data.menu.pd2_medium_font,
			font_size 	= 22,
			color 		= tweak_data.screen_colors.button_stage_3,
			vertical 	= "top",
			align 		= "left",
			layer 		= 101
		})
		
		self._rc_menu[ k .. "_select_rect" ] = self._panel:rect({
			blend_mode 	= "normal",
			color 		= tweak_data.screen_colors.button_stage_3,
			alpha 		= 0.3,
			visible 	= false,
			layer 		= 102
		})
		
		local _ , _ , w , h = self._rc_menu[ k ]:text_rect()
		
		if self._rc_menu[ "bg" ]:w() < w + 8 then
			self._rc_menu[ "bg" ]:set_w( w + 8 )
		end
		self._rc_menu[ k ]:set_size( w , h )
		
		
		if k == 1 then
			self._rc_menu[ k ]:set_lefttop( self._rc_menu[ "bg" ]:left() + 4 , self._rc_menu[ "bg" ]:top() )
			self._rc_menu[ k .. "_select_rect" ]:set_lefttop( self._rc_menu[ "bg" ]:left() , self._rc_menu[ "bg" ]:top() )
		else
			self._rc_menu[ k ]:set_lefttop( self._rc_menu[ k - 1 ]:left() , self._rc_menu[ k - 1 ]:bottom() )
			self._rc_menu[ k .. "_select_rect" ]:set_lefttop( self._rc_menu[ "bg" ]:left() , self._rc_menu[ k - 1 ]:bottom() )
		end
	end
	
	for k , v in ipairs( self._rc_btns ) do
		local _ , _ , w , h = self._rc_menu[ k ]:text_rect()
		self._rc_menu[ k .. "_select_rect" ]:set_size( self._rc_menu[ "bg" ]:w() , h )
	end
	
	local _ , _ , w , h = self._rc_menu[ 1 ]:text_rect()
	self._rc_menu[ "bg" ]:set_h( h * #self._rc_btns )
	self._rc_menu[ "bg_blur" ]:set_size( self._rc_menu[ "bg" ]:size() )

end

function BlackMarketGui:destroy_right_click_menu()

	if self._rc_menu then
		for k , v in ipairs( self._rc_menu ) do
			self._panel:remove( self._rc_menu[ k ] )
			self._panel:remove( self._rc_menu[ k .. "_select_rect" ] )
		end
		
		if self._rc_menu[ "bg_blur" ] and alive( self._rc_menu[ "bg_blur" ] ) then
			self._panel:remove( self._rc_menu[ "bg_blur" ] )
		end
		
		if self._rc_menu[ "bg" ] and alive( self._rc_menu[ "bg" ] ) then
			self._panel:remove( self._rc_menu[ "bg" ] )
		end
		
		self._rc_menu = nil
		self._rc_btns = nil
		self._rc_highlight = nil
		self._rc_highlighted = nil
	end

end

Hooks:PreHook( BlackMarketGui , "mouse_pressed" , "IRCMBlackMarketGuiPreMousePressed" , function( self , button , x , y )
	
	self._rc_menu_clicked = nil
	
	if self._rc_menu and not self._selected_slot:inside( x , y ) and button == Idstring( "1" ) then
		self:destroy_right_click_menu()
	end
	
	if not self._rc_menu and button == Idstring( "1" ) then
		self:mouse_pressed( Idstring( "0" ) , x , y )
		self:mouse_released( Idstring( "0" ) , x , y )
	end
	
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end
	if not self._enabled then
		return
	end
	if self._renaming_item then
		self:_stop_rename_item()
		return
	end
	if self._no_input then
		return
	end
	
	if self._rc_menu and ( button == Idstring( "mouse wheel up" ) or button == Idstring( "mouse wheel down" ) ) then
		self:destroy_right_click_menu()
	end
	
	if self._selected_slot and self._selected_slot:inside( x , y ) then
		if button == Idstring( "1" ) then
			if not self._rc_menu then
				self:show_right_click_menu( self._selected_slot , x , y )
			elseif self._rc_menu then
				self:destroy_right_click_menu()
			end
		end
	end
	
	if self._rc_menu then
		if button == Idstring( "0" ) then
			if self._rc_highlight then
				if self._rc_btns[ self._rc_highlight ] and self._rc_menu[ self._rc_highlight .. "_select_rect" ]:inside( x , y ) then
					local data = self._rc_btns[ self._rc_highlight ]._data
					
					if data.callback and ( not self._button_press_delay or self._button_press_delay < TimerManager:main():time() ) then
						managers.menu_component:post_event( "menu_enter" )
						data.callback( self._slot_data , self._data.topic_params )
						self._button_press_delay = TimerManager:main():time() + 0.2
					end
					self._rc_menu_clicked = { self._selected_slot._panel:world_center() }
				end
			end
			self:destroy_right_click_menu()
		end
	end

end )

Hooks:PostHook( BlackMarketGui , "mouse_pressed" , "IRCMBlackMarketGuiPostMousePressed" , function( self , button , x , y )

	if self._rc_menu_clicked then
		self:mouse_pressed( Idstring( "0" ) , self._rc_menu_clicked[ 1 ] , self._rc_menu_clicked[ 2 ] )
		self:mouse_released( Idstring( "0" ) , x , y )
	end

end )

Hooks:PostHook( BlackMarketGui , "mouse_moved" , "IRCMBlackMarketGuiPostMouseMoved" , function( self , o , x , y )

	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end
	if not self._enabled then
		return
	end
	if self._renaming_item then
		return true , "link"
	end
	if alive( self._no_input_panel ) then
		self._no_input = self._no_input_panel:inside( x , y )
	end
	
	self._rc_highlighted = self._rc_highlighted or {}
	
	if self._rc_menu then
		if next( self._rc_btns ) == nil then
			return
		end
	
		for k , v in ipairs( self._rc_menu ) do
			if self._rc_menu[ k .. "_select_rect" ]:inside( x , y ) then
				self._rc_highlight = k
			else
				self._rc_highlighted[ k ] = nil
				self._rc_menu[ k ]:set_color( tweak_data.screen_colors.button_stage_3 )
				self._rc_menu[ k .. "_select_rect" ]:set_visible( false )
			end
		end
		
		if not self._rc_menu[ "bg" ]:inside( x , y ) then
			self._rc_highlight = nil
			self._rc_highlighted = {}
		end
		
		if self._rc_highlight then
			if not self._rc_highlighted[ self._rc_highlight ] then
				self._rc_highlighted[ self._rc_highlight ] = true
				self._rc_menu[ self._rc_highlight ]:set_color( tweak_data.screen_colors.button_stage_2 )
				self._rc_menu[ self._rc_highlight .. "_select_rect" ]:set_visible( true )
				managers.menu_component:post_event( "highlight" )
			end
		end
	end

end )

Hooks:PostHook( BlackMarketGui , "previous_page" , "IRCMBlackMarketGuiPostPreviousPage" , function( self , no_sound )

	if self._rc_menu then
		self:destroy_right_click_menu()
	end

end )

Hooks:PostHook( BlackMarketGui , "next_page" , "IRCMBlackMarketGuiPostNextPage" , function( self , no_sound )

	if self._rc_menu then
		self:destroy_right_click_menu()
	end

end )