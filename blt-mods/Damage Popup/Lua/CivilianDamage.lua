
Hooks:PreHook( CivilianDamage , "_on_damage_received" , "DmgPopPreCopDamageOnDamageReceived" , function( self , damage_info )
		
	if self._uws and alive( self._uws ) then
		self._uws:panel():stop()
		World:newgui():destroy_workspace( self._uws )
		self._uws = nil
	end
	
	self._uws = World:newgui():create_world_workspace( 165 , 100 , self._unit:movement():m_head_pos() + Vector3( 0 , 0 , 70 ) , Vector3( 50 , 0 , 0 ) , Vector3( 0 , 0 , -50 ) )
	self._uws:set_billboard( self._uws.BILLBOARD_BOTH )
	
	local panel = self._uws:panel():panel({
		visible = DmgPopUp.options.show_civilian_damage_popup,
		name 	= "damage_panel",
		layer = 0,
		alpha = 0
	})
	
	local text = panel:text({
		text 		= string.format( damage_info.damage * 10 >= 10 and "%d" or "%.1f" , damage_info.damage * 10 ),
		layer 		= 1,
		align 		= "left",
		vertical 	= "bottom",
		font 		= tweak_data.menu.pd2_large_font,
		font_size 	= 70,
		color 		= Color.white
	})
	
	local attacker_unit = damage_info and damage_info.attacker_unit
	
	if alive( attacker_unit ) and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end
	
	if attacker_unit and managers.network:session() and managers.network:session():peer_by_unit( attacker_unit ) then
		local peer_id = managers.network:session():peer_by_unit( attacker_unit ):id()
		local c = tweak_data.chat_colors[ peer_id ]
		text:set_color( c )
	end
	
	if damage_info.result.type == "death" then
		text:set_text( managers.localization:get_default_macro( "BTN_SKULL" ) .. text:text() )
		text:set_range_color( 0 , 1 , DmgPopUp.colors[(DmgPopUp.options.damage_popup_kill_color)] )
	end
	
	panel:animate( function( p )
		over( 5 , function( o )
			self._uws:set_world( 165 , 100 , self._unit:movement():m_head_pos() + Vector3( 0 , 0 , 70 ) + Vector3( 0 , 0 , math.lerp( 0 , 50 , o ) ) , Vector3( 50 , 0 , 0 ) , Vector3( 0 , 0 , -50 ) )
			text:set_color( text:color():with_alpha( 0.5 + ( math.sin( o * 750 ) + 0.5 ) / 4 ) )
			panel:set_alpha( math.lerp( 1 , 0 , o ) )
		end )
		panel:remove( text )
		World:newgui():destroy_workspace( self._uws )
	end )

end )

Hooks:PostHook( CivilianDamage , "destroy" , "DmgPopPostCopDamageDestroy" , function( self , ... )

	if self._uws and alive( self._uws ) then
		World:newgui():destroy_workspace( self._uws )
		self._uws = nil
	end

end )
