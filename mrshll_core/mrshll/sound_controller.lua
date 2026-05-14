dofile_once( "mods/mnee/lib.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )

local storage_state = pen.magic_storage( entity_id, "is_playing" )
local is_playing = ComponentGetValue2( storage_state, "value_float" )

pen.c.done_frame = pen.c.done_frame or {}
pen.c.storage_time = pen.c.storage_time or {}

local gamer_time = 1000/60
local last_time = pen.c.storage_time[ entity_id ] or 0
local this_time = GameGetRealWorldTimeSinceStarted()*1000
pen.c.storage_time[ entity_id ] = this_time
local frame_time = this_time - last_time

pen.c.done_frame[ entity_id ] = pen.c.done_frame[ entity_id ] or 0
if( is_playing ~= 0 ) then
	if( pen.c.done_frame[ entity_id ] > 0 ) then
		local ratio = frame_time/gamer_time
		pen.c.done_frame[ entity_id ] = pen.c.done_frame[ entity_id ] - ratio
		
		local volume = pen.magic_storage( entity_id, "current_volume", "value_float" )
		if( pen.c.done_frame[ entity_id ] <= 0 ) then
			volume = 0
			ComponentSetValue2( storage_state, "value_float", 0 )
			pen.magic_storage( entity_id, "gonna_purge", "value_bool", true )
		end
		
		pen.magic_storage( entity_id, "time_sync", "value_float", pen.c.done_frame[ entity_id ], false )
		
		for i = 1,2 do
			local dud = pen.get_child( entity_id, i == 1 and "left" or "right" )
			GameEntityPlaySoundLoop( dud, "sound",
				pen.magic_storage( entity_id, "current_energy", "value_float" ))
			pen.magic_comp( dud, "AudioLoopComponent", function( comp_id, v, is_enabled )
				if( volume ~= ComponentGetValue2( comp_id, "m_volume" )) then
					ComponentSetValue2( comp_id, "m_volume", volume ) end
				if( not( is_enabled )) then pen.c.done_frame[ entity_id ] = is_playing end
			end)
		end
	else
		pen.c.done_frame[ entity_id ] = is_playing
		
		for i = 1,2 do
			local dud = pen.get_child( entity_id, i == 1 and "left" or "right" )
			pen.magic_comp( dud, "AudioLoopComponent", function( comp_id, v, is_enabled )
				ComponentSetValue2( comp_id, "file", pen.magic_storage( entity_id, "sound_bank", "value_string" ))
				ComponentSetValue2( comp_id, "event_name",
					pen.magic_storage( entity_id, "sound_event", "value_string" )..( i == 1 and "_l" or "_r" ))
				ComponentSetValue2( comp_id, "m_volume", pen.setting_get( "mrshll_core.VOLUME" ))
				ComponentSetValue2( comp_id, "volume_autofade_speed", 0.25 )
			end)
		end
	end
elseif( pen.c.done_frame[ entity_id ] > 0 ) then
	pen.c.done_frame[ entity_id ] = 0
end