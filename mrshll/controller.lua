dofile_once( "mods/mnee/lib.lua" )

function play_sound( event )
	pen.play_sound({ "mods/mrshll_core/mrshll.bank", event })
end

function new_tooltip( text, data )
	data = data or {}
	data.frames = data.frames or 15
	data.text_prefunc = function( text, data )
		text = pen.get_hybrid_table( text )
		
		local extra = 0
		if( pen.vld( text[2])) then
			extra = 2
			text[1] = "{>underscore>{{-}|HRMS|GOLD_3|FORCED|{-}"..text[1].."}<underscore<}"
			text[1] = text[1].."\n{>indent>{{>color>{{-}|HRMS|GREY_2|{-}"..string.lower( text[2]).."}<color<}}<indent<}" end
		return text[1], extra, 0
	end
	
	return pen.new_tooltip( text, data, function( text, d )
		local size_x, size_y = unpack( d.dims )
		local pic_x, pic_y, pic_z = unpack( d.pos )
		
		local alpha = pen.animate( 1, d.t, { ease_in = "exp5", frames = d.frames })
		if( pen.vld( text )) then
			pen.new_text( pic_x + d.edging, pic_y + d.edging - 2, pic_z - 0.01, text, {
				dims = { size_x - d.edging, size_y }, line_offset = d.line_offset or -2, fully_featured = true,
				color = pen.PALETTE.HRMS.RED_3, alpha = alpha,
			})
		end
		
		local gui_core = "mods/mrshll_core/mrshll/tooltip/"
		local scale_x = pen.animate({1,size_x/2 + 3}, d.t, { ease_out = { "bck", "sin" }, frames = d.frames })
		local scale_y = pen.animate({1,size_y/2 + 3}, d.t, { ease_out = { "exp1.7", "sin" }, ease_in = "log0.5", frames = d.frames })
		
		local frame_sin = 80*( math.sin( GameGetFrameNum()/10 ) + 1 )
		pen.colourer( gui, { 255 - frame_sin, 255, 255 })
		pen.new_image( pic_x + size_x/2 - scale_x, pic_y + size_y/2 - scale_y, pic_z - 1, gui_core.."corner.png" )
		pen.colourer( gui, { 255 - ( 160 - frame_sin ), 255, 255 })
		pen.new_image( pic_x + size_x/2 + scale_x, pic_y + size_y/2 + scale_y, pic_z - 1, gui_core.."corner.png", { s_x = -1, s_y = -1 })

		pen.new_image( pic_x - 1, pic_y - 1, pic_z, gui_core.."module_A.png", { alpha = alpha })
		pen.new_image( pic_x + 1, pic_y - 1, pic_z, gui_core.."module_B.png", { s_x = size_x - 2, s_y = 1, alpha = alpha })
		pen.new_image( pic_x + size_x + 1, pic_y - 1, pic_z, gui_core.."module_A.png", { s_x = -1, s_y = 1 , alpha = alpha })
		pen.new_image( pic_x + size_x + 1, pic_y + 1, pic_z, gui_core.."module_B.png", {
			s_x = size_y - 2, s_y = 1, angle = math.rad( 90 ), alpha = alpha })
		pen.new_image( pic_x + size_x - 1, pic_y + size_y - 1, pic_z, gui_core.."module_C.png", { alpha = alpha })
		pen.new_image( pic_x + 1, pic_y + size_y + 1, pic_z, gui_core.."module_B.png", { s_x = size_x - 2, s_y = -1, alpha = alpha })
		pen.new_image( pic_x - 1, pic_y + size_y + 1, pic_z, gui_core.."module_A.png", { s_x = 1, s_y = -1, alpha = alpha })
		pen.new_image( pic_x - 1, pic_y + size_y - 1, pic_z, gui_core.."module_B.png", {
			s_x = size_y - 2, s_y = 1, angle = -math.rad( 90 ), alpha = alpha })
		
		pen.new_pixel( pic_x, pic_y, pic_z, pen.PALETTE.W, size_x, size_y, alpha )
		
		local s_alpha = 0.4*alpha
		pen.new_image( pic_x - 3, pic_y - 3, pic_z + 0.001, gui_core.."shadow_A.png", {
			s_x = 0.5, s_y = 0.5, alpha = s_alpha })
		pen.new_image( pic_x + 2.5, pic_y - 3, pic_z + 0.001, gui_core.."shadow_B.png", {
			s_x = size_x/2 - 2.5, s_y = 0.5, alpha = s_alpha })
		pen.new_image( pic_x + size_x + 3, pic_y - 3, pic_z + 0.001, gui_core.."shadow_A.png", {
			s_x = -0.5, s_y = 0.5, alpha = s_alpha })
		pen.new_image( pic_x + size_x + 3, pic_y + 2.5, pic_z + 0.001, gui_core.."shadow_B.png", {
			s_x = size_y/2 - 2, s_y = 0.5, alpha = s_alpha, angle = math.rad( 90 )})
		pen.new_image( pic_x + size_x - 1.5, pic_y + size_y - 1.5, pic_z + 0.001, gui_core.."shadow_C.png", {
			s_x = 0.5, s_y = 0.5, alpha = s_alpha })
		pen.new_image( pic_x + 2.5, pic_y + size_y + 3, pic_z + 0.001, gui_core.."shadow_B.png", {
			s_x = size_x/2 - 2, s_y = -0.5, alpha = s_alpha })
		pen.new_image( pic_x - 3, pic_y + size_y + 3, pic_z + 0.001, gui_core.."shadow_A.png", {
			s_x = 0.5, s_y = -0.5, alpha = s_alpha })
		pen.new_image( pic_x - 3, pic_y + size_y - 2.5, pic_z + 0.001, gui_core.."shadow_B.png", {
			s_x = size_y/2 - 2.5, s_y = 0.5, alpha = s_alpha, angle = -math.rad( 90 )})
	end)
end

function new_button( pic_x, pic_y, pic_z, pic, data )
	data = data or {}
	data.ignore_multihover = false
	data.frames = data.frames or 20
	data.highlight = data.highlight or pen.PALETTE.HRMS.RED_2

	data.lmb_event = data.lmb_event or function( pic_x, pic_y, pic_z, pic, d )
		if( not( d.no_anim )) then pen.atimer( d.auid.."l", nil, true ) end
		return pic_x, pic_y, pic_z, pic, d
	end
	data.rmb_event = data.rmb_event or function( pic_x, pic_y, pic_z, pic, d )
		if( not( d.no_anim )) then pen.atimer( d.auid.."r", nil, true ) end
		return pic_x, pic_y, pic_z, pic, d
	end
	data.hov_event = data.hov_event or function( pic_x, pic_y, pic_z, pic, d )
		if( pen.vld( d.tip )) then
			if( pen.vld( pen.c.cutter_dims )) then
				pen.uncutter( function( cut_x, cut_y, cut_w, cut_h )
					return new_tooltip( d.tip, { is_active = true })
				end)
			else new_tooltip( d.tip, { is_active = true }) end
		end
		if( pen.vld( d.highlight )) then pen.new_pixel(
			pic_x - 1, pic_y - 1, pic_z + 0.001, d.highlight,
			( d.s_x or 1 )*d.dims[1] + 2, ( d.s_y or 1 )*d.dims[2] + 2 ) end
		return pic_x, pic_y, pic_z, pic, d
	end

	return pen.new_button( pic_x, pic_y, pic_z, pic, data )
end

local entity_id = index_mrshll_id or GetUpdatedEntityID()
local hooman = EntityGetRootEntity( entity_id )
local x, y = EntityGetTransform( hooman )

local volume = pen.setting_get( "mrshll_core.VOLUME" )
local no_dragger = pen.setting_get( "mrshll_core.NO_DRAGGER" )
local pos = pen.t.pack( pen.setting_get( "mrshll_core.UI_POS" ))
local is_shuffled = pen.setting_get( "mrshll_core.IS_SHUFFLED" )
local playlist_num = pen.setting_get( "mrshll_core.PLAYLIST_NUM" )

local storage_delay = pen.magic_storage( entity_id, "is_playing" )
local is_playing = ComponentGetValue2( storage_delay, "value_float" )
local storage_sound = pen.magic_storage( entity_id, "current_volume" )
local current_volume = ComponentGetValue2( storage_sound, "value_float" )

local ordered = pen.t.clone( pen.t.parse( pen.setting_get( "mrshll_core.ORDER_LIST" )))
local this_ordered = pen.t.clone( ordered[ playlist_num ])
local ignored = pen.t.clone( pen.t.parse( pen.setting_get( "mrshll_core.IGNORE_LIST" )))
local this_ignored = pen.t.clone( ignored[ playlist_num ])

pen.t.loop({"left","right"}, function( i, v )
	local speaker = pen.get_child( entity_id, v )
	if( not( pen.vld( speaker, true ))) then return end
	
	local pos = { -30, 30 }
	EntitySetTransform( speaker, x + pos[i], y - 10 )
	
	local a_comp = EntityGetFirstComponentIncludingDisabled( speaker, "AudioLoopComponent" )
	if( not( pen.vld( a_comp, true ))) then return end
	if( ComponentGetIsEnabled( a_comp )) then return end
	EntitySetComponentIsEnabled( speaker, a_comp, true )
end)

local num, delay = 0, 10
filtering = filtering or 0
is_moving, is_listing, is_showing = is_moving or false, is_listing or false, is_showing or false
gonna_play = gonna_play or ( is_playing == 0 and last_played == nil and pen.setting_get( "mrshll_core.AUTOPLAY" ))
num_override, last_played = num_override or 0, last_played or 0
switch_delay = switch_delay or ( gonna_play and delay or 0 )
mrshll = dofile( "mods/mrshll_core/mrshll_list.lua" )

local function reset()
	ComponentSetValue2( storage_delay, "value_float", 0 )
	switch_delay, gonna_play, last_played = delay, false, 0
	pen.magic_storage( entity_id, "playlist", "value_string", "" )
end

if( not( pen.vld( this_ordered ))) then
	this_ordered = {}
	for cat,v in pen.t.order( mrshll ) do
		pen.t.loop( v, function( i, song )
			table.insert( this_ordered, { cat, song.id })
		end)
	end
	this_ignored = this_ignored or {}
	ordered[ playlist_num ] = this_ordered
	ignored[ playlist_num ] = this_ignored
	pen.setting_set( "mrshll_core.ORDER_LIST", pen.t.parse( ordered ))
	pen.setting_set( "mrshll_core.IGNORE_LIST", pen.t.parse( ignored ))
end

local goners_order = {}
local goners_ignore = {}
if( playlist_update ) then
	playlist_update = false
	pen.t.loop( this_ordered, function( i, v )
		local is_nuked = this_ignored[ v[2]] ~= nil
		local is_real = pen.vld( pen.t.get( mrshll[ v[1]], v[2], nil, nil, {}))
		if( is_real and not( is_nuked )) then return end
		goners_order[ playlist_num ] = goners_order[ playlist_num ] or {}
		table.insert( goners_order[ playlist_num ], i )
	end)
elseif( playlist_update == nil ) then
	playlist_update = false
	pen.t.loop( ordered, function( k, o )
		pen.t.loop( o, function( i, v )
			local is_nuked = ignored[k][ v[2]] ~= nil
			local is_real = pen.vld( pen.t.get( mrshll[ v[1]], v[2], nil, nil, {}))
			if( is_real and not( is_nuked )) then return end
			goners_order[k] = goners_order[k] or {}
			table.insert( goners_order[k], i )
		end)
		pen.t.loop( ignored[k], function( i,_ )
			if( pen.t.loop( mrshll, function( _,v )
				if( pen.vld( pen.t.get( v, i, nil, nil, {}))) then return true end
			end)) then return end
			goners_ignore[k] = goners_ignore[k] or {}
			table.insert( goners_ignore[k], i )
		end)
		
		local temp = nil
		for cat,v in pen.t.order( mrshll ) do
			pen.t.loop( v, function( i, song )
				local is_nuked = ignored[k][ song.id ] ~= nil
				local is_present = pen.vld( pen.t.get( o, song.id, 2, nil, {}))
				if( not( is_nuked or is_present )) then
					temp = temp or pen.t.clone( o )
					table.insert( temp, { cat, song.id })
				end
			end)
		end
		if( pen.vld( temp )) then
			ordered[k] = temp
			playlist_update = true
		end
	end)
	if( playlist_update ) then
		playlist_update = false
		pen.setting_set( "mrshll_core.ORDER_LIST", pen.t.parse( ordered ))
	end
end

if( pen.vld( goners_order )) then
	pen.t.loop( goners_order, function( k, v )
		local temp = pen.t.clone( ordered[k])
		for e = #v,1,-1 do table.remove( temp, v[e]) end
		ordered[k] = temp
	end)
	pen.setting_set( "mrshll_core.ORDER_LIST", pen.t.parse( ordered ))
end
if( pen.vld( goners_ignore )) then
	pen.t.loop( goners_ignore, function( k, v )
		local temp = pen.t.clone( ignored[k])
		pen.t.loop( v, function( _, i ) temp[i] = nil end)
		ignored[k] = temp
	end)
	pen.setting_set( "mrshll_core.IGNORE_LIST", pen.t.parse( ignored ))
end

if( gonna_play ) then
	pen.t.loop({"left","right"}, function( i, v )
		local speaker = pen.get_child( entity_id, v )
		if( pen.vld( speaker, true )) then return end
		speaker = EntityLoad( "mods/mrshll_core/mrshll/speaker.xml", x, y )
		EntitySetName( speaker, v )
		EntityAddChild( entity_id, speaker )
	end)

	if( is_playing == 0 ) then
		local storage_purge = pen.magic_storage( entity_id, "gonna_purge" )
		if( ComponentGetValue2( storage_purge, "value_bool" )) then
			ComponentSetValue2( storage_purge, "value_bool", false )
			switch_delay = 10
		end
		
		if( switch_delay == 0 ) then
			if( num_override > 0 ) then num = num_override; num_override = 0 end
			num = ( num == 0 and ( is_shuffled and pen.generic_random( 1, #this_ordered ) or ( last_played + 1 )) or num )
			if( num > #this_ordered ) then num = 1 end

			local storage_played = pen.magic_storage( entity_id, "playlist" )
			local played_list = pen.t.unarray( pen.t.pack( ComponentGetValue2( storage_played, "value_string" )))
			pen.hallway( function()
				if( force_the_same ) then return end
				if( not( is_shuffled )) then return end
				if( played_list[ this_ordered[ num ][2]] == nil ) then return end
				
				local is_done = true
				for i,v in ipairs( this_ordered ) do
					if( played_list[ v[2]] == nil ) then is_done, num = false, i; break end
				end

				if( is_done ) then played_list = {} else return end
				if( last_played == num ) then num = num < 2 and #this_ordered or last_played - 1 end
			end)
			force_the_same, last_played, played_list[ this_ordered[ num ][2]] = false, num, 1
			ComponentSetValue2( storage_played, "value_string", pen.t.pack( pen.t.unarray( played_list )))
			
			local v = this_ordered[ num ]
			local song = pen.t.get( mrshll[ v[1]], v[2])
			ComponentSetValue2( storage_delay, "value_float", song.duration + 90 )
			pen.magic_storage( entity_id, "sound_bank", "value_string", song.fmod_bank )
			pen.magic_storage( entity_id, "sound_event", "value_string", song.fmod_event )
			pen.magic_storage( entity_id, "current_volume", "value_float", volume + ( song.custom_volume or 0 ))

			EntityAddTag( entity_id, "index_pic_update" )
			pen.magic_storage( entity_id, "index_pic_anim", "value_string", "|mods/mrshll_core/mrshll/anim/|5|5|" )
		else
			switch_delay = switch_delay - 1
			if( switch_delay == 5 ) then
				pen.t.loop({"left","right"}, function( i, v )
					pen.magic_comp( pen.get_child( entity_id, v ), "AudioLoopComponent", function( comp_id, v, is_enabled )
						ComponentSetValue2( comp_id, "file", "" )
						ComponentSetValue2( comp_id, "event_name", "" )
						ComponentSetValue2( comp_id, "m_volume", 0 )
						ComponentSetValue2( comp_id, "volume_autofade_speed", 1 )
					end)
				end)
			end
		end
	end
elseif( is_playing ~= 0 ) then
	ComponentSetValue2( storage_delay, "value_float", 0 )

	EntityAddTag( entity_id, "index_pic_update" )
	pen.magic_storage( entity_id, "index_pic_anim", "value_string", "|mods/mrshll_core/mrshll/anim/|5|1|" )
end

local gui = pen.gui_builder()
local is_going = pen.get_active_item( hooman ) == entity_id
local pic_x, pic_y, pic_z, clicked, r_clicked = pos[1], pos[2], pen.LAYERS.MAIN, false, false

local play = false
local forward = false
local shuffle = false
local volume_up = false
local volume_down = false
local playlist_next = false
local playlist_last = false

local storage_open = pen.magic_storage( entity_id, "is_open" )
if( pen.vld( storage_open, true ) and not( pen.is_inv_active( hooman ))) then
	is_going = ComponentGetValue2( storage_open, "value_bool" )
	
	if( not( ModIsEnabled( "index_core" ))) then  
		clicked = new_button( 6, 6, pen.LAYERS.FOREGROUND,
			"mods/mrshll_core/mrshll/item.png", {
			auid = "mrshll_main", 
			is_centered = true, no_anim = true,
			hov_event = function( pic_x, pic_y, pic_z, pic, d )
				d.angle = math.rad( 15 )
				new_tooltip( "Toggle Marshall GUI", { is_active = true })
				return pic_x, pic_y, pic_z, pic, d
			end,
		})
		if( clicked ) then
			play_sound( "ass/special_button" )
			ComponentSetValue2( storage_open, "value_bool", not( is_going ))
		end
	end
end
if( is_going and not( pen.is_inv_active( hooman ))) then
	if( not( no_dragger )) then
		if( is_moving ) then
			local new_x, new_y, state, is_hovered = 0, 0, 0, false
			new_x, new_y, state, _, r_clicked, is_hovered = pen.new_dragger( "mnee_window", pic_x, pic_y - 11, 10, 10 )
			if( new_x ~= pic_x or new_y + 11 ~= pic_y ) then pen.setting_set( "mrshll_core.UI_POS", pen.t.pack({ new_x, new_y + 11 })) end
			if( r_clicked ) then play_sound( "ass/special_button" ); is_moving = not( is_moving ) end
			new_tooltip({ GameTextGet( "$mrshll_dragger_aa" ), GameTextGet( "$mrshll_dragger_ab" )}, { is_active = is_hovered and state ~= 2 })
		end

		_,r_clicked = new_button( pic_x, pic_y - 11, pic_z,
			"mods/mrshll_core/mrshll/move_"..( is_moving and "B" or "A" )..".png", {
			auid = "mrshll_move", tip = not( is_moving ) and { GameTextGet( "$mrshll_dragger_ba" ), GameTextGet( "$mrshll_dragger_bb" )} or nil })
		if( r_clicked ) then
			play_sound( "ass/special_button" )
			is_moving = not( is_moving )
		end
	end

	play = new_button( pic_x, pic_y, pic_z,
		"mods/mrshll_core/mrshll/play_"..( gonna_play and "B" or "A" )..".png", {
		auid = "mrshll_play", tip = gonna_play and GameTextGet( "$mrshll_stop" ) or GameTextGet( "$mrshll_play" )})
	forward = new_button( pic_x, pic_y + 11, pic_z,
		"mods/mrshll_core/mrshll/next.png", {
		auid = "mrshll_next", tip = GameTextGet( "$mrshll_next" )})
	volume_up, volume_down = new_button( pic_x, pic_y + 22, pic_z,
		"mods/mrshll_core/mrshll/volume_"..( math.floor( 3.8*math.max( 1.5 - volume, 0 )))..".png", {
		auid = "mrshll_volume", tip = { GameTextGet( "$mrshll_volume_a" )..math.floor( volume*100 + 0.5 ), GameTextGet( "$mrshll_volume_b" )}})
	
	local text, genre, duration = "John Cage - 4'33\"", "Classical", 0
	if( last_played > 0 ) then
		local song_id = this_ordered[ last_played ]
		local song = pen.t.get( mrshll[ song_id[1]], song_id[2])
		text, genre, duration = song.artist.." - "..song.name, song_id[1], song.duration
	end
	local dist = math.max( pen.get_text_dims( text, true ) + 2, is_listing and 94 or 1 )
	pen.new_image( pic_x + 11, pic_y, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
	pen.new_image( pic_x + 12, pic_y, pic_z, "mods/mrshll_core/mrshll/window_B.png", { s_x = dist, s_y = 1 })
	pen.new_image( pic_x + 12 + dist, pic_y, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
	new_button( pic_x + 11, pic_y, pic_z, pen.FILE_PIC_NIL, {
		s_x = dist/2 + 1, s_y = 5, no_anim = true, tip = { GameTextGet( "$mrshll_genre" ), genre }})
	pen.new_text( pic_x + 13, pic_y, pic_z - 0.01, text, { color = pen.PALETTE.HRMS.RED_3 })

	local tm, true_tm = "00:00", 0
	if( last_played > 0 ) then
		true_tm = pen.magic_storage( entity_id, "time_sync", "value_float" )
		local mins = math.floor( true_tm/60/60 )
		local secs = math.floor( true_tm/60 - mins*60 + 0.5 )
		tm = string.sub( tostring( 100 + math.min( mins, 99 )), -2 )..":"..string.sub( tostring( 100 + secs ), -2 )
		true_tm = math.floor( true_tm )
	end
	pen.new_image( pic_x + 11, pic_y + 11, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
	pen.new_image( pic_x + 12, pic_y + 11, pic_z, "mods/mrshll_core/mrshll/window_B.png", { s_x = 27, s_y = 1 })
	pen.new_image( pic_x + 39, pic_y + 11, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
	new_button( pic_x + 11, pic_y + 11, pic_z, pen.FILE_PIC_NIL, {
		s_x = 29/2, s_y = 5, no_anim = true,
		tip = { GameTextGet( "$mrshll_time" ), true_tm > 0 and string.format( "%.1f", 100*math.min( true_tm/duration, 1 )).."%" or "" }})
	pen.new_text( pic_x + 13, pic_y + 11, pic_z - 0.01, tm, { color = pen.PALETTE.HRMS.RED_3 })

	clicked = new_button( pic_x + 11, pic_y + 22, pic_z,
		"mods/mrshll_core/mrshll/"..( is_listing and "close" or "playlist" )..".png", {
		auid = "mrshll_list", tip = GameTextGet( is_listing and "$mrshll_close" or "$mrshll_playlist" )})
	if( clicked ) then
		play_sound( "ass/special_button" )
		is_listing, is_showing = not( is_listing ), false
		if( is_listing ) then pen.atimer( "main_window", nil, true ) end
	end
	if( is_listing ) then
		local filter_list = {}
		for cat,_ in pen.t.order( mrshll ) do table.insert( filter_list, cat ) end

		local cnt = 0
		local scroller_id = ( is_showing and "excluded_" or "playlist_" )..playlist_num
		local anim = -10*( 1 - pen.animate( 1, "main_window", { ease_out = { "exp", "wav1" }, frames = 15, stillborn = true }))
		pen.catch( pen.new_scroller, { scroller_id, pic_x + 12, pic_y + 32, pic_z + 0.01, 95, 111 + anim, function( scroll_pos )
			local height, accum = 0, 0
			pen.t.loop( is_showing and this_ignored or this_ordered, function( i, v )
				cnt = cnt + 1
				local cat, song = "", ""
				if( is_showing ) then
					cat, song = pen.cache({ "mrshll_deleted", i }, function()
						return unpack( pen.t.loop( mrshll, function( cat,v )
							local temp = pen.t.get( v, i, nil, nil, {})
							return pen.vld( temp ) and { cat, temp } or nil
						end))
					end)
				else cat = v[1]; song = pen.t.get( mrshll[ cat ], v[2]) end
				
				if(( filter_list[ filtering ] or cat ) ~= cat ) then accum = accum + 1; return end
				local pos_y = 1 + scroll_pos + 11*(( is_showing and cnt or i ) - ( 1 + accum ))
				if( pos_y < -10 or pos_y > 130 ) then height = height + 11; return end 
				local drift = -2*( 1 - pen.animate( 1, "button_"..song.id, {
					ease_out = { "exp", "wav1" }, frames = 10, stillborn = true }))
				
				if( is_showing or #this_ordered > 1 ) then
					_,r_clicked = new_button( 86, pos_y + drift, pic_z - 0.03,
						"mods/mrshll_core/mrshll/playlist_toggle_"..( is_showing and "B" or "A" )..".png", {
						auid = "mrshll_exclude_"..song.id, tip = { GameTextGet( is_showing and "$mrshll_toggle_aa" or "$mrshll_toggle_ba" ), GameTextGet( is_showing and "$mrshll_toggle_ab" or "$mrshll_toggle_bb" )}})
					if( r_clicked ) then
						play_sound( "ass/special_button" )
						if( is_showing ) then
							this_ignored[ song.id ] = nil
							table.insert( this_ordered, { cat, song.id })
							ordered[ playlist_num ] = this_ordered
							pen.setting_set( "mrshll_core.ORDER_LIST", pen.t.parse( ordered ))
						else this_ignored[ song.id ] = 1 end
						ignored[ playlist_num ] = this_ignored
						pen.setting_set( "mrshll_core.IGNORE_LIST", pen.t.parse( ignored ))
						playlist_update = not( is_showing )
						reset()
					end
				end
				
				pen.new_text( 3, pos_y + drift, pic_z - 0.02, song.name, { aggressive = true, dims = {88,0},
					color = pen.PALETTE.HRMS[ is_showing and "GREY_2" or ( last_played == i and "GOLD_3" or "RED_3" )]})
				
				clicked, r_clicked = new_button( 1, pos_y + drift, pic_z - 0.01,
					"mods/mrshll_core/mrshll/playlist_line.png", { auid = "mrshll_song_"..song.id,
					tip = { song.artist.." - "..song.name, is_showing and "" or GameTextGet( "$mrshll_line" )}})
				if( not( is_showing )) then
					if( clicked ) then
						play_sound( "ass/generic_button" )
						switch_delay, gonna_play = delay, true
						force_the_same, num_override = true, i
						ComponentSetValue2( storage_delay, "value_float", 0 )
					elseif( r_clicked and i > 1 ) then
						play_sound( "ass/tab_hover" )
						pen.atimer( "button_"..song.id, nil, true )
						local memo = this_ordered[ i ]
						this_ordered[ i ], this_ordered[ i - 1 ] = this_ordered[ i - 1 ], memo
						ordered[ playlist_num ] = this_ordered
						pen.setting_set( "mrshll_core.ORDER_LIST", pen.t.parse( ordered ))
						reset()
					end
				end
				
				height = height + 11
			end)

			return height + 5
		end, { color = {
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_3, pen.PALETTE.HRMS.RED_3
		}}})

		clicked = new_button( pic_x + 97, pic_y + 22, pic_z,
			"mods/mrshll_core/mrshll/"..( is_showing and "back" or "excluded" )..".png", {
			auid = "mrshll_excluded", tip = GameTextGet( is_showing and "$mrshll_back" or "$mrshll_goners" )})
		if( clicked ) then
			play_sound( "ass/special_button" )
			is_showing = not( is_showing )
		end

		shuffle = new_button( pic_x + 86, pic_y + 11, pic_z,
			"mods/mrshll_core/mrshll/playlist_order_"..( is_shuffled and "B" or "A" )..".png", {
			auid = "mrshll_order", tip = { GameTextGet( "$mrshll_shuffle" ), ( GameTextGet( is_shuffled and "$mrshll_shuffle_ba" or "$mrshll_shuffle_bb" ))}})
		playlist_next, playlist_last = new_button( pic_x, pic_y + 134 + anim, pic_z,
			"mods/mrshll_core/mrshll/playlist_num.png", {
			auid = "mrshll_playlist", tip = GameTextGet( "$mrshll_switch" )})
		pen.new_text( pic_x + 2, pic_y + 134 + anim, pic_z - 0.01, string.char( playlist_num + 64 ), { color = pen.PALETTE.HRMS.RED_3 })
		
		_,r_clicked = new_button( pic_x + 97, pic_y + 11, pic_z,
			"mods/mrshll_core/mrshll/reset.png", {
			auid = "mrshll_reset", tip = { GameTextGet( "$mrshll_default_a" ), GameTextGet( "$mrshll_default_b" )}})
		if( r_clicked ) then
			play_sound( "ass/special_button" )
			ordered[ playlist_num ] = nil
			pen.setting_set( "mrshll_core.ORDER_LIST", pen.t.parse( ordered ))
			ignored[ playlist_num ] = nil
			pen.setting_set( "mrshll_core.IGNORE_LIST", pen.t.parse( ignored ))
			reset()
		end

		pen.new_text( pic_x + 59.5, pic_y + 22, pic_z,
			string.upper( filter_list[ filtering ] or ( GameTextGet( is_showing and "$mrshll_title_b" or "$mrshll_title_a" ))), {
			dims = {74,0}, aggressive = true, is_centered_x = true, color = pen.PALETTE.HRMS[ filtering == 0 and "RED_3" or "GOLD_3" ]})
		clicked, r_clicked = pen.new_interface( pic_x + 22, pic_y + 22, 74, 10, pic_z )
		new_tooltip( is_showing and GameTextGet( "$mrshll_title_tip_ba" ) or { GameTextGet( "$mrshll_title_tip_aa" ), GameTextGet( "$mrshll_title_tip_ab" )})
		if( clicked or r_clicked ) then
			play_sound( "ass/special_button" )
			if( clicked ) then
				filtering = filtering > #filter_list - 1 and 0 or filtering + 1
			else filtering = filtering < 1 and #filter_list or filtering - 1 end
		end

		pen.new_image( pic_x + 11, pic_y + 22, pic_z + 0.01, "mods/mrshll_core/mrshll/window_playlist.png", { can_click = true })
		pen.new_image( pic_x + 11, pic_y + 122 + anim, pic_z + 0.011, "mods/mrshll_core/mrshll/window_playlist_bottom.png" )
	end
end

pen.gui_builder( true )

if( play or mnee.mnin( "bind", { "mrshll_core", "play" }, { pressed = true, dirty = true })) then
	play_sound( "ass/generic_button" )
	gonna_play = not( gonna_play )
	switch_delay = gonna_play and 0 or delay
	force_the_same, num_override = true, last_played
end

if( forward or mnee.mnin( "bind", { "mrshll_core", "next" }, { pressed = true, dirty = true })) then
	play_sound( "ass/generic_button" )
	switch_delay, gonna_play = delay, true
	ComponentSetValue2( storage_delay, "value_float", 0 )
end

volume_up = volume_up or mnee.mnin( "bind", { "mrshll_core", "volume_up" }, { pressed = true, dirty = true })
volume_down = volume_down or mnee.mnin( "bind", { "mrshll_core", "volume_down" }, { pressed = true, dirty = true })
if( volume_up or volume_down ) then
	play_sound( "ass/generic_button" )
	local v = math.min( math.max( volume + 0.1*( volume_up and 1 or -1 ), 0.3 ), 5 )
	pen.setting_set( "mrshll_core.VOLUME", v )
	ComponentSetValue2( storage_sound, "value_float", current_volume + ( v - volume ))
end

if( shuffle or mnee.mnin( "bind", { "mrshll_core", "shuffle" }, { pressed = true, dirty = true })) then
	play_sound( "ass/generic_button" )
	pen.setting_set( "mrshll_core.IS_SHUFFLED", not( is_shuffled ))
	reset()
end

playlist_next = playlist_next or mnee.mnin( "bind", { "mrshll_core", "playlist_next" }, { pressed = true, dirty = true })
playlist_last = playlist_last or mnee.mnin( "bind", { "mrshll_core", "playlist_last" }, { pressed = true, dirty = true })
if( playlist_next or playlist_last ) then
	play_sound( "ass/special_button" )
	if( playlist_next ) then
		playlist_num = playlist_num > 25 and 1 or playlist_num + 1
	else playlist_num = playlist_num < 2 and 26 or playlist_num - 1 end
	pen.setting_set( "mrshll_core.PLAYLIST_NUM", playlist_num )
	reset()
end