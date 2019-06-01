
Hooks:PostHook( CopDamage , "sync_damage_bullet" , "DmgPop_PostCopDamageSyncDamageBullet" , function( self, attacker_unit, damage_percent, i_body, ... )

	if i_body then
		self._sync = i_body
	end

end )

Hooks:PostHook( CopDamage , "sync_damage_melee" , "DmgPop_PostCopDamageSyncDamageMelee" , function( self, attacker_unit, damage_percent, damage_effect_percent, i_body, ... )

	if i_body then
		self._sync = i_body
	end
	
end )

Hooks:PreHook( CopDamage , "_on_damage_received" , "DmgPop_PreCopDamageOnDamageReceived" , function( self , damage_info )
	
	self._sync = nil
	
	if self._uws and alive( self._uws ) then
		self._uws:panel():stop()
		World:newgui():destroy_workspace( self._uws )
		self._uws = nil
	end
	
	self._uws = World:newgui():create_world_workspace( 165 , 100 , self._unit:movement():m_head_pos() + Vector3( 0 , 0 , 70 ) , Vector3( 50 , 0 , 0 ) , Vector3( 0 , 0 , -50 ) )
	self._uws:set_billboard( self._uws.BILLBOARD_BOTH )
	
	local panel = self._uws:panel():panel({
		visible = DmgPopUp.options.show_damage_popup,
		name 	= "damage_panel",
		layer = 0,
		alpha = 0
	})
	
	local glow_panel = panel:bitmap({
		name = "glow_panel",
		texture = "guis/textures/pd2/crimenet_marker_glow",
		visible = damage_info.result.type == "death" and headshot,
		w = 192,
		h = 192,
		blend_mode = "add",
		alpha = 0.55,
		color = DmgPopUp.colors[(DmgPopUp.options.damage_popup_headshot_flash_color)],
		x = -100,
		y = -35,
		h = 200,
		w = 300,
		rotation = 360,
		align = "left",
		layer = 1
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
	
	local body = damage_info.col_ray and damage_info.col_ray.body or self._sync and self._unit:body(self._sync)
	local headshot = body and self.is_head and self:is_head(body) or false
	if damage_info.result.type == "death" then
		text:set_text( managers.localization:get_default_macro( "BTN_SKULL" ) .. text:text() )
		text:set_range_color( 0 , 1 , headshot and DmgPopUp.colors[(DmgPopUp.options.damage_popup_headshot_color)] or DmgPopUp.colors[(DmgPopUp.options.damage_popup_kill_color)] )
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
	
	local anim_pulse_glow = function(o)
				local t = 0
	
	while true do
	
		t = t + coroutine.yield()
		panel:set_alpha( ( math.abs( math.sin( ( 4 + t ) * 360 * 4 / 4 ) ) ) )
	end
				panel:remove( text )
				World:newgui():destroy_workspace( self._uws )
			end
			--glow:set_center(cost_text:center())
			if damage_info.result.type == "death" and headshot then
			panel:animate(anim_pulse_glow)
			end

end )

Hooks:PostHook( CopDamage , "destroy" , "DmgPop_PostCopDamageDestroy" , function( self , ... )

	if self._uws and alive( self._uws ) then
		World:newgui():destroy_workspace( self._uws )
		self._uws = nil
	end

end )