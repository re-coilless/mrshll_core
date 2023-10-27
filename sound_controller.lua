dofile_once( "mods/mrshll_core/lib.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )

local storage_state = get_storage( entity_id, "is_playing" )
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
		
		local volume = ComponentGetValue2( get_storage( entity_id, "current_volume" ), "value_float" )
		if( done_frame <= 0 ) then
			ComponentSetValue2( storage_state, "value_float", 0 )
			volume = 0
			
			ComponentSetValue2( get_storage( entity_id, "gonna_purge" ), "value_bool", true )
		end
		
		local sync = get_storage( entity_id, "time_sync" )
		if( sync ~= nil ) then
			ComponentSetValue2( sync, "value_float", done_frame )
		end
		
		for i = 1,2 do
			local dud = get_hooman_child( entity_id, i == 1 and "left" or "right" )
			GameEntityPlaySoundLoop( dud, "sound", 0.5 )
			edit_component_ultimate( dud, "AudioLoopComponent", function(comp,vars)
				if( volume ~= ComponentGetValue2( comp, "m_volume" )) then
					ComponentSetValue2( comp, "m_volume", volume )
				end
				
				if( not( ComponentGetIsEnabled( comp ))) then
					done_frame = is_playing
				end
			end)
		end
	else
		done_frame = is_playing
		
		for i = 1,2 do
			local dud = get_hooman_child( entity_id, i == 1 and "left" or "right" )
			edit_component_ultimate( dud, "AudioLoopComponent", function(comp,vars)
				ComponentSetValue2( comp, "file", ComponentGetValue2( get_storage( entity_id, "sound_bank" ), "value_string" ))
				ComponentSetValue2( comp, "event_name", ComponentGetValue2( get_storage( entity_id, "sound_event" ), "value_string" )..( i == 1 and "_l" or "_r" ))
				ComponentSetValue2( comp, "m_volume", ComponentGetValue2( get_storage( entity_id, "sound_volume" ), "value_float" ))
				ComponentSetValue2( comp, "volume_autofade_speed", 0.25 )
			end)
		end
	end
elseif( done_frame > 0 ) then
	done_frame = 0
end