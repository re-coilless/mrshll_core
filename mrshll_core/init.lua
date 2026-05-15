ModRegisterAudioEventMappings( "mods/mrshll_core/GUIDs.txt" )
ModRegisterMusicBank( "mods/mrshll_core/silence.bank" )

if( ModIsEnabled( "mnee" )) then
	ModLuaFileAppend( "mods/mnee/bindings.lua", "mods/mrshll_core/mnee.lua" )
end

function OnModInit()
	if( not( ModIsEnabled( "mnee" ))) then return end
	dofile_once( "mods/mnee/lib.lua" )
	pen.add_translations( "mods/mrshll_core/mrshll/translations.csv" )
	if( pen.vld( pen.setting_get( "mrshll_core.PLAYLIST" ))) then
		GamePrint( "MRSHLL PURGE SUCCESSFUL" )
		ModSettingRemove( "mrshll_core.PLAYLIST" )    
		ModSettingRemove( "mrshll_core.WHITE_SONGS" )
		ModSettingRemove( "mrshll_core.IGNORE_LIST_1" )
		ModSettingRemove( "mrshll_core.IGNORE_LIST_2" )
		ModSettingRemove( "mrshll_core.IGNORE_LIST_3" )
		ModSettingRemove( "mrshll_core.ORDER_LIST_1" )
		ModSettingRemove( "mrshll_core.ORDER_LIST_2" )
		ModSettingRemove( "mrshll_core.ORDER_LIST_3" )
	end
	
	if( not( ModIsEnabled( "index_core" ))) then return end
	pen.magic_append( "mods/index_core/files/_structure.lua", "mods/mrshll_core/mrshll/index.lua", true )
end

function OnWorldPreUpdate()
	if( not( ModIsEnabled( "mnee" ))) then
		GamePrint( "[M-NEE IS REQUIRED] - check the mod's page" )
		return
	end

	dofile_once( "mods/mnee/lib.lua" )
	local queue = pen.t.pack( GlobalsGetValue( "MRSHLL_OST_QUEUE", "" ))
	if( not( pen.vld( queue ))) then return end

	local playlist = {}
	pen.t.loop( queue, function( i, file )
		if( not( ModDoesFileExist( file ))) then return end
		playlist = dofile_once( file )( playlist )
	end)
	if( not( pen.vld( playlist ))) then return end

	local hooman = pen.get_hooman()
	if( not( pen.vld( hooman, true ))) then return end
	local energy = GlobalsGetValue( "MRSHLL_OST_ENERGY", "" ) --from 0 to 1
	if( ModIsEnabled( "vector_core" )) then
		if( pen.vld( hooman, true )) then
			local stress = pen.magic_storage( hooman, "stress", "value_float" )
			if( pen.vld( stress )) then
				local peak_stress = tonumber( GlobalsGetValue( "VECTOR_PEAK_STRESS", "1000" ))
				energy = stress/peak_stress
			end
		end
	end
	if( energy == "" ) then
		energy = tonumber( energy ) or 0
	end
	
	local event = {}
	local is_biome = true
	local frame_num = GameGetFrameNum()
	local cam_x, cam_y = GameGetCameraPos()
	pen.c.mrshll_ost_data = pen.c.mrshll_ost_data or {}
	pen.c.mrshll_ost_biome = pen.c.mrshll_ost_biome or {}
	local biome_id = DebugBiomeMapGetFilename( cam_x, cam_y )
	local track_override = pen.t.pack( GlobalsGetValue( "MRSHLL_OST_FORCED", "" ))
	if( pen.vld( track_override )) then
		event = track_override
		is_biome = false
	else
		local biome_name = BiomeMapGetName( cam_x, cam_y )
		local _,_,biome_file = string.find( biome_id, "^.+/(.-).xml$" )
		local track_data = pen.t.loop( pen.t.order( playlist ), function( i,v )
			if( not( pen.ghf( v.is_active, { energy, biome_name, biome_file }))) then return end
			if( energy < v.energy[1] or energy > v.energy[2]) then return end
			local name_check = pen.t.get( pen.ght( v.biome_name ), biome_name )
			local file_check = pen.t.get( pen.ght( v.biome_file ), biome_file )
			if( name_check == 0 and file_check == 0 ) then return end
			return pen.t.clone( v )
		end) or { event = {}}

		pen.t.loop( EntityGetWithTag( "mrshll_ost_marker" ), function( i,marker_id )
			local storage = pen.magic_storage( marker_id, "mrshll_ost_marker" )
			if( not( pen.vld( storage, true ))) then return end
			if( not( ComponentGetValue2( storage, "value_bool" ))) then return end
			local m_x, m_y = EntityGetTransform( marker_id )
			local dist = math.min( math.log(( m_x - cam_x )^2 + ( m_y - cam_y )^2 ), 2 )
			local priority = ComponentGetValue2( storage, "value_float" )
			if( priority > ( track_data.order_id or 0 ) and priority/dist > ( track_data.best_priotity or 0 )) then
				track_data.event = pen.t.pack( ComponentGetValue2( storage, "value_string" ))
				track_data.best_priority = priority/dist
				track_data.order_id = 0
				track_data.name = ""
				is_biome = false
			end
		end)

		if( pen.vld( track_data.name )) then
			GlobalsSetValue( "MRSHLL_OST_NAME", track_data.name ) end
		event = pen.ghf( track_data.event, { energy, biome_name, biome_file })
	end
	
	local x, y = EntityGetTransform( hooman )
	local ost_id = EntityGetWithName( "mrshll_ost" )
	if( not( pen.vld( ost_id, true ))) then
		ost_id = EntityLoad( "mods/mrshll_core/mrshll/ost.xml", x, y )
	else EntitySetTransform( ost_id, x, y ) end

	local fading, track_id = 1, ""
	local is_empty = not( pen.vld( event ))
	pen.c.estimator_memo = pen.c.estimator_memo or {}
	if( not( is_empty )) then track_id = event[1]..event[2] end
	if( pen.c.mrshll_ost_data.track_id ~= track_id ) then
		if(( pen.c.mrshll_ost_data.min_frame or 0 ) < frame_num ) then
			fading = 0
			if( pen.c.estimator_memo[ "mrshll_ost_fade" ] == 0 ) then
				pen.c.mrshll_ost_data.track_id = track_id
				pen.c.mrshll_ost_data.track_memo = is_empty and {} or event
				local duration = type( event[3]) == "number" and ( event[3] + 10 ) or math.huge
				pen.c.mrshll_ost_data.min_frame = frame_num + ( is_empty and 30 or
					math.min( tonumber( GlobalsGetValue( "MRSHLL_OST_DURATION", "600" )), duration ))
				pen.magic_storage( ost_id, "is_playing", "value_float", 0 )
				pen.magic_storage( ost_id, "gonna_purge", "value_bool", true )
			end
		end
	else fading = 1 end
	fading = pen.estimate( "mrshll_ost_fade", { fading, 1 }, "exp50" )

	pen.t.loop({ "left", "right" }, function( i, v )
		local speaker = pen.get_child( ost_id, v )
		if( not( pen.vld( speaker, true ))) then
			speaker = EntityLoad( "mods/mrshll_core/mrshll/speaker.xml", x, y )
			EntitySetName( speaker, v )
			EntityAddChild( ost_id, speaker )
		end
		EntitySetTransform( speaker, x + ( i == 1 and -30 or 30 ), y - 10 )
		
		local a_comp = EntityGetFirstComponentIncludingDisabled( speaker, "AudioLoopComponent" )
		if( not( pen.vld( a_comp, true ))) then return end
		if( ComponentGetIsEnabled( a_comp )) then return end
		EntitySetComponentIsEnabled( speaker, a_comp, true )
	end)

	local track = pen.c.mrshll_ost_data.track_memo
	pen.c.mrshll_ost_purge = pen.c.mrshll_ost_purge or 0
	if( pen.vld( track )) then
		pen.magic_storage( ost_id, "current_energy", "value_float", energy )
		local fading_mrshll = tonumber( GlobalsGetValue( "MRSHLL_OST_VOLUME_", "1" ))
		pen.magic_storage( ost_id, "current_volume", "value_float", 0.251
			+ 0.749*fading_mrshll*tonumber( GlobalsGetValue( "MRSHLL_OST_VOLUME", "1" ))*fading )
		if( pen.magic_storage( ost_id, "is_playing", "value_float" ) == 0 ) then
			if( pen.magic_storage( ost_id, "gonna_purge", "value_bool" )) then
				pen.magic_storage( ost_id, "gonna_purge", "value_bool", false )
				pen.c.mrshll_ost_purge = 10
			end
			
			if( pen.c.mrshll_ost_purge == 0 ) then
				if( not( is_biome ) or ( pen.c.mrshll_ost_biome[ biome_id ] or 0 ) < frame_num ) then
					pen.magic_storage( ost_id, "sound_bank", "value_string", track[1])
					pen.magic_storage( ost_id, "sound_event", "value_string", track[2])
					pen.magic_storage( ost_id, "is_playing", "value_float",
						type( track[3]) == "number" and ( track[3] + 90 ) or 999999999 )
					
					if( is_biome ) then
						local biome_pause = frame_num + math.random(
							tonumber( GlobalsGetValue( "MRSHLL_OST_BIOME_MIN", "2000" )),
							tonumber( GlobalsGetValue( "MRSHLL_OST_BIOME_MAX", "20000" )))
						if( type( track[3] ) == "number" ) then biome_pause = biome_pause + track[3] end
						pen.c.mrshll_ost_biome[ biome_id ] = biome_pause
					end
				end
			else
				pen.c.mrshll_ost_purge = pen.c.mrshll_ost_purge - 1
				if( pen.c.mrshll_ost_purge == 5 ) then
					pen.t.loop({"left","right"}, function( i, v )
						pen.magic_comp( pen.get_child( ost_id, v ), "AudioLoopComponent", function( comp_id, v, is_enabled )
							ComponentSetValue2( comp_id, "file", "" )
							ComponentSetValue2( comp_id, "event_name", "" )
							ComponentSetValue2( comp_id, "m_volume", 0 )
							ComponentSetValue2( comp_id, "volume_autofade_speed", 1 )
						end)
					end)
				end
			end
		end
	else pen.magic_storage( ost_id, "is_playing", "value_float", 0 ) end
	
	if( frame_num%600 ~= 0 ) then return end
	GameTriggerMusicFadeOutAndDequeueAll( 1000 )
	GameTriggerMusicEvent( "music/silence/01", false, x, y )
end

function OnPlayerSpawned( hooman )
	if( not( ModIsEnabled( "mnee" ))) then return end
	dofile_once( "mods/mnee/lib.lua" )
	
	local initer = "HERMES_MARSHALL_MOMENT"
	if( GameHasFlagRun( initer )) then return end
	GameAddFlagRun( initer )
	
	GlobalsSetValue( "HERMES_IS_REAL", "1" )
	
	local mode = ModSettingGetNextValue( "mrshll_core.ITEM_INIT" )
	if( mode > 3 ) then return end
	local x, y = EntityGetTransform( hooman )
	local override = ModIsEnabled( "white_room" ) and mode < 3
	if( override ) then x, y = 1727, 5328 end
	
	local controller = EntityLoad( "mods/mrshll_core/mrshll/item.xml", x, y )
	if( ModIsEnabled( "index_core" )) then
		EntityRemoveComponent( controller, EntityGetComponentIncludingDisabled( controller, "LuaComponent" )[2])
	end
	
	if( mode < 3 ) then
		EntityAddTag( controller, "teleportable_NOT" )
		EntityAddTag( controller, "item_physics" )
		EntityAddTag( controller, "item_pickup" )
		EntitySetComponentIsEnabled( controller, EntityAddComponent( controller, "PhysicsBodyComponent",
		{
			_tags = "enabled_in_world",
			uid = "1", 
			allow_sleep = "1",
			angular_damping = "0", 
			fixed_rotation = "0", 
			is_bullet = "1", 
			linear_damping = "0",
			auto_clean = "0",
			kills_entity = "1",
			hax_fix_going_through_ground = "1",
			on_death_leave_physics_body = "1",
			on_death_really_leave_body = "1",
		}), false )
		EntityAddComponent( controller, "PhysicsImageShapeComponent",
		{
			body_id = "1",
			centered = "1",
			image_file = "mods/mrshll_core/mrshll/item.png",
			material = CellFactory_GetType( "templebrick_diamond_static" ),
		})
		EntitySetComponentIsEnabled( controller, EntityAddComponent( controller, "SpriteComponent",
		{
			_tags = "enabled_in_hand",
			offset_x = "2",
			offset_y = "5",
			image_file = "mods/mrshll_core/mrshll/item.png",
			z_index = "-10",
		}), true )
		EntitySetComponentIsEnabled( controller, EntityAddComponent( controller, "VelocityComponent",
		{
			_tags = "enabled_in_world",
		}), false )
		ComponentObjectSetValue2( EntityAddComponent( controller, "AbilityComponent",
		{
			throw_as_item = "0",
		}), "gun_config", "deck_capacity", 0 )
		
		local item = EntityAddComponent( controller, "ItemComponent",
		{
			_tags = "enabled_in_world",
			item_name = "HermeS Marshall©",
			max_child_items = "0",
			is_pickable = "1",
			is_equipable_forced = "1",
			always_use_item_name_in_ui = "1",
			ui_sprite = "mods/mrshll_core/mrshll/anim/1.png",
			ui_description = "Manufactured by Hermeneutics Superior FRC.\nIt shimmers with tunes.",
			play_spinning_animation = "0",
		})
		ComponentSetValue2( item, "preferred_inventory", "QUICK" )

		local steam = EntityAddComponent( controller, "SpriteParticleEmitterComponent", 
		{
			_tags = "enabled_in_world",
			sprite_file = "mods/mrshll_core/mrshll/gold.png",
			sprite_centered = "1",
			lifetime = "3",
			velocity_slowdown = "0",
			use_velocity_as_rotation = "1",
			z_index = "100",
			delay = "0",
			additive = "1",
			emissive = "1",
			count_min = "0",
			count_max = "1",
			velocity_always_away_from_center = "0",
			emission_interval_min_frames = "2",
			emission_interval_max_frames = "5",
			is_emitting = "1",
			render_back = "0",
		})
		EntitySetComponentIsEnabled( controller, steam, not( override ))
		ComponentSetValue2( steam, "randomize_position", -6, 6, 6, -6 )
		ComponentSetValue2( steam, "velocity", 0, 5 )
		ComponentSetValue2( steam, "randomize_velocity", -0.5, -6, 0.5, -4.99 )
		ComponentSetValue2( steam, "scale", 0.7, 0.7 )
		ComponentSetValue2( steam, "randomize_scale", -0.1, -0.1, 0.1, 0.1 )
		ComponentSetValue2( steam, "color", 199/255, 220/255, 208/255, 0.3 )
		ComponentSetValue2( steam, "color_change", 0.03, 0.03, 0.03, -0.03 )

		-- EntityAddComponent( controller, "VariableStorageComponent",
		-- {
			-- name = "index_pic_anim",
			-- value_string = "|mods/mrshll_core/mrshll/anim/|5|1|",
		-- })

		if( override ) then
			GamePrint( "::Injection Protocol Override:: Destination set to [THE CHAMBER]" )
			EntitySetTransform( controller, x, y, 0, -1, 1 )
		elseif( mode == 1 ) then
			GamePickUpInventoryItem( hooman, controller, false )
		end
	else
		EntityAddComponent( controller, "VariableStorageComponent", {
			name = "is_open",
			value_bool = "0",
		})
		EntityAddComponent( controller, "InheritTransformComponent" )
		EntityAddChild( hooman, controller )
	end
end