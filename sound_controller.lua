dofile_once( "mods/mnee/_penman.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )

local storage_state = pen.magic_storage( entity_id, "is_playing" )
local is_playing = ComponentGetValue2( storage_state, "value_float" )

local gamer_time = 1000/60
local last_time = storage_time or 0
local this_time = GameGetRealWorldTimeSinceStarted()*1000
storage_time = this_time
local frame_time = this_time - last_time

done_frame = done_frame or 0
if( is_playing ~= 0 ) then
	if( done_frame > 0 ) then
		local ratio = frame_time/gamer_time
		done_frame = done_frame - ratio
		
		local volume = pen.magic_storage( entity_id, "current_volume", "value_float" )
		if( done_frame <= 0 ) then
			volume = 0
			ComponentSetValue2( storage_state, "value_float", 0 )
			pen.magic_storage( entity_id, "gonna_purge", "value_bool", true )
		end
		
		pen.magic_storage( entity_id, "time_sync", "value_float", done_frame, false )
		
		for i = 1,2 do
			local dud = pen.get_child( entity_id, i == 1 and "left" or "right" )
			GameEntityPlaySoundLoop( dud, "sound", 0.5 )
			pen.magic_comp( dud, "AudioLoopComponent", function( comp_id, v, is_enabled )
				if( volume ~= ComponentGetValue2( comp_id, "m_volume" )) then
					ComponentSetValue2( comp_id, "m_volume", volume ) end
				if( not( is_enabled )) then done_frame = is_playing end
			end)
		end
	else
		done_frame = is_playing
		
		for i = 1,2 do
			local dud = pen.get_child( entity_id, i == 1 and "left" or "right" )
			pen.magic_comp( dud, "AudioLoopComponent", function( comp_id, v, is_enabled )
				ComponentSetValue2( comp_id, "file", pen.magic_storage( entity_id, "sound_bank", "value_string" ))
				ComponentSetValue2( comp_id, "event_name",
					pen.magic_storage( entity_id, "sound_event", "value_string" )..( i == 1 and "_l" or "_r" ))
				ComponentSetValue2( comp_id, "m_volume", pen.magic_storage( entity_id, "sound_volume", "value_float" ))
				ComponentSetValue2( comp_id, "volume_autofade_speed", 0.25 )
			end)
		end
	end
elseif( done_frame > 0 ) then
	done_frame = 0
end