ModRegisterAudioEventMappings( "mods/mrshll_core/GUIDs.txt" )

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

	local queue = pen.t.pack( GlobalsGetValue( "MRSHLL_OST_QUEUE", "" ))
	if( not( pen.vld( queue ))) then return end

	local playlist = {}
	pen.t.loop( queue, function( i, file )
		if( not( ModDoesFileExist( file ))) then return end
		playlist = dofile_once( file )( playlist )
	end)
	if( not( pen.vld( playlist ))) then return end

	local energy = GlobalsGetValue( "MRSHLL_OST_ENERGY", "" ) --from 0 to 1
	if( ModIsEnabled( "vector_core" )) then
		local hooman = pen.get_hooman()
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

	--use ModRegisterMusicBank( filename:string ) with silent track to remove all vanilla music, add a setting to disable this
	
	local event, duration = {}, 0
	local track_override = pen.t.pack( GlobalsGetValue( "MRSHLL_OST_FORCED", "" ))
	if( pen.vld( track_override )) then
		event = { track_override[1], track_override[2]}
		duration = track_override[3]
	else
		local cam_x, cam_y = GameGetCameraPos()
		local biome_name = BiomeMapGetName( cam_x, cam_y )
		local _,_,biome_file = string.find( DebugBiomeMapGetFilename( cam_x, cam_y ), "^.+/(.-).xml$" )
		local track_data = pen.t.loop( pen.t.order( playlist ), function( i,v )
			if( not( pen.ghf( v.is_active, { energy, biome_name, biome_file }))) then return end
			if( energy < v.energy[1] or energy > v.energy[2]) then return end
			local name_check = pen.t.get( pen.ght( v.biome_name ), biome_name )
			local file_check = pen.t.get( pen.ght( v.biome_file ), biome_file )
			if( name_check == 0 and file_check == 0 ) then return end
			return pen.t.clone( v )
		end) or { event = {}}
		
		-- pen.debug_print( biome_name, 50, 50, true )
		-- pen.debug_print( biome_file, 50, 75, true )

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
			end
		end)

		if( pen.vld( track_data.name )) then
			GlobalsSetValue( "MRSHLL_OST_NAME", track_data.name ) end
		event = { track_data.event[1], track_data.event[2]}
		duration = track_data.event[3]
	end

	if( not( pen.vld( event ))) then return end
	
	--only transition to a new track if the track event is different

	--global to override volume (for cutscenes and mrshll)
	--music shoudl always start playing on new biome ntrance
	--do volume fading out through pen.estimate
	--ensure there's an inherent pause in between biome tracks (support looping tracks), every track has to play for at least 1000 frames
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