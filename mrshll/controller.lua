dofile_once( "mods/penman/_penman.lua" )

function play_sound( event )
	pen.play_sound({ "mods/mrshll_core/mrshll.bank", event })
end

function new_tooltip( text, data )
	data = data or {}
	data.frames = data.frames or 15
	data.text_prefunc = function( text, data )
		local extra_dim = 0
		text = pen.get_hybrid_table( text )
		if( pen.vld( text[2])) then
			extra_dim = 2
			text[1] = "{>underscore>{{-}|HRMS|GOLD_3|FORCED|{-}"..text[1].."}<underscore<}"
			text[1] = text[1].."\n{>indent>{{>color>{{-}|HRMS|GREY_2|{-}"..string.lower( text[2]).."}<color<}}<indent<}" end
		return text[1], extra_dim, 0
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

local entity_id = GetUpdatedEntityID()
local hooman = EntityGetRootEntity( entity_id )
local x, y = EntityGetTransform( hooman )

local storage_delay = pen.magic_storage( entity_id, "is_playing" )
local is_playing = ComponentGetValue2( storage_delay, "value_float" )

local storage_volume = pen.magic_storage( entity_id, "sound_volume" )
local volume = ComponentGetValue2( storage_volume, "value_float" )
local storage_sound = pen.magic_storage( entity_id, "current_volume" )
local current_volume = ComponentGetValue2( storage_sound, "value_float" )

local storage_order = pen.magic_storage( entity_id, "random_order" )
local random_order = ComponentGetValue2( storage_order, "value_bool" )

local storage_num = pen.magic_storage( entity_id, "playlist_num" )
local playlist_num = ComponentGetValue2( storage_num, "value_int" )

local storage_ignored = pen.magic_storage( entity_id, "ignored_songs_"..playlist_num )
local storage_ordered = pen.magic_storage( entity_id, "ordered_songs_"..playlist_num )

local num, delay = 0, 10
is_listing = is_listing or false
gonna_play = gonna_play or ( is_playing == 0 and last_played == nil and pen.setting_get( "mrshll_core.AUTOPLAY" ))
num_override, last_played = num_override or 0, last_played or 0
switch_delay = switch_delay or ( gonna_play and delay or 0 )

local gui = pen.gui_builder()
local is_going = pen.get_active_item( hooman ) == entity_id
local pic_x, pic_y, pic_z, clicked, r_clicked = 183, 22, pen.LAYERS.MAIN, false, false

local storage_open = pen.magic_storage( entity_id, "is_open" )
if( pen.vld( storage_open, true ) and not( pen.is_inv_active( hooman ))) then
	is_going = ComponentGetValue2( storage_open, "value_bool" )

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
if( is_going and not( pen.is_inv_active( hooman ))) then --add repositioning via dragging
	clicked = new_button( pic_x, pic_y, pic_z,
		"mods/mrshll_core/mrshll/play_"..( gonna_play and "B" or "A" )..".png", {
		auid = "mrshll_play", tip = gonna_play and "Stop" or "Start" })
	if( clicked ) then
		play_sound( "ass/generic_button" )
		gonna_play = not( gonna_play )
		switch_delay = gonna_play and 0 or delay
		force_the_same, num_override = true, last_played
	end

	clicked = new_button( pic_x, pic_y + 11, pic_z,
		"mods/mrshll_core/mrshll/next.png", {
		auid = "mrshll_next", tip = "Next Song" })
	if( clicked ) then
		play_sound( "ass/generic_button" )
		ComponentSetValue2( storage_delay, "value_float", 0 )
		switch_delay, gonna_play = delay, true
	end
	
	clicked, r_clicked = new_button( pic_x, pic_y + 22, pic_z,
		"mods/mrshll_core/mrshll/volume.png", {
		auid = "mrshll_volume", tip = { "Volume: "..math.floor( volume*100 + 0.5 ), "LMB/RMB to rise/lower." }})
	if( clicked or r_clicked ) then
		play_sound( "ass/generic_button" )
		local v = math.min( math.max( volume + 0.1*( clicked and 1 or -1 ), 0.3 ), 5 )
		ComponentSetValue2( storage_volume, "value_float", v )
		ComponentSetValue2( storage_sound, "value_float", current_volume + ( v - volume ))
		pen.setting_set( "mrshll_core.VOLUME", v )
	end
	for i = 1,math.floor( 4*math.max( 1.3 - volume, 0 ) + 0.5 ) do
		pen.new_pixel( pic_x + 6, pic_y + 21 + i*2, pic_z - 0.01, nil, 2, 2 )
	end
	
	clicked = new_button( pic_x + 11, pic_y + 22, pic_z,
		"mods/mrshll_core/mrshll/"..( is_listing and "close" or "playlist" )..".png", {
		auid = "mrshll_list", tip = is_listing and "Close" or "Playlist Editor" })
	if( clicked ) then
		play_sound( "ass/special_button" )
		is_listing = not( is_listing )
		if( is_listing ) then pen.atimer( "main_window", nil, true ) end
	end
	if( is_listing ) then
		local anim = -10*( 1 - pen.animate( 1, "main_window", { ease_out = { "exp", "wav1" }, frames = 15, stillborn = true }))

		clicked = new_button( pic_x, pic_y + 134 + anim, pic_z,
			"mods/mrshll_core/mrshll/playlist_num_"..playlist_num..".png", {
			auid = "mrshll_playlist", tip = "Switch Playlist" })
		if( clicked ) then
			play_sound( "ass/special_button" )
			playlist_num = playlist_num > 2 and 1 or playlist_num + 1
			pen.setting_set( "mrshll_core.PLAYLIST", playlist_num )
			ComponentSetValue2( storage_num, "value_int", playlist_num )
			ComponentSetValue2( storage_delay, "value_float", 0 )

			song_id_table, last_played = {}, 0
			switch_delay, gonna_play = delay, false
			pen.magic_storage( entity_id, "played_songs", "value_string", "" )
			storage_ignored = pen.magic_storage( entity_id, "ignored_songs_"..playlist_num )
			storage_ordered = pen.magic_storage( entity_id, "ordered_songs_"..playlist_num )
		end
		
		_,r_clicked = new_button( pic_x + 97, pic_y + 11, pic_z,
			"mods/mrshll_core/mrshll/playlist_reset.png", {
			auid = "mrshll_reset", tip = { "Return to Default", "RMB to reset the playlist" }})
		if( r_clicked ) then
			play_sound( "ass/special_button" )
			ComponentSetValue2( storage_ignored, "value_string", pen.DIV_1 )
			ComponentSetValue2( storage_ordered, "value_string", pen.DIV_1 )
			pen.setting_set( "mrshll_core.IGNORE_LIST_"..playlist_num, pen.DIV_1 )
			pen.setting_set( "mrshll_core.ORDER_LIST_"..playlist_num, pen.DIV_1 )

			song_id_table, last_played = {}, 0
			switch_delay, gonna_play = delay, false
			ComponentSetValue2( storage_delay, "value_float", 0 )
			pen.magic_storage( entity_id, "played_songs", "value_string", "" )
		end
		
		clicked = new_button( pic_x + 86, pic_y + 11, pic_z,
			"mods/mrshll_core/mrshll/playlist_order_"..( random_order and "B" or "A" )..".png", {
			auid = "mrshll_order", tip = { "Shuffle Toggle", ( random_order and "Randomised Selection" or "Ordered Playback" )}})
		if( clicked ) then
			play_sound( "ass/generic_button" )
			random_order = not( random_order )
			ComponentSetValue2( storage_order, "value_bool", random_order )
			pen.setting_set( "mrshll_core.IS_SHUFFLED", random_order )
		end
		
		local he_asked, extra_care = false, false
		local who_asked = pen.t.pack( ComponentGetValue2( storage_ignored, "value_string" ))
		pen.new_scroller( "playlist_"..playlist_num, pic_x + 12, pic_y + 32, pic_z + 0.01, 95, 111 + anim, function( scroll_pos )
			local height = 0
			for i,song_id in ipairs( song_id_table ) do
				local sid = song_id[1].."_"..song_id[2]
				local song = mrshll[ song_id[1]].stuff[ song_id[2]]
				
				_,r_clicked = new_button( 86, 1 + scroll_pos + 11*( i - 1 ), pic_z - 0.03,
					"mods/mrshll_core/mrshll/playlist_toggle_A.png", {
					auid = "mrshll_exclude_"..sid, tip = { "Exclude", "RMB to remove" }})
				if( r_clicked ) then --put excluded into a different tab
					play_sound( "ass/special_button" )
					table.insert( who_asked, mrshll[ song_id[1]].name.."_"..( song.id or song.artist_name.."_"..song.track_name ))
					he_asked = true
				end
				
				pen.new_text( 3, 1 + scroll_pos + 11*( i - 1 ), pic_z - 0.02, song.track_name, {
					aggressive = true, dims = {88,0}, color = pen.PALETTE.HRMS[ last_played == i and "GOLD_3" or "RED_3" ]})
				
				clicked, r_clicked = new_button( 1, 1 + scroll_pos + 11*( i - 1 ), pic_z - 0.01,
					"mods/mrshll_core/mrshll/playlist_line.png", {
					auid = "mrshll_song_"..sid, tip = { song.artist_name.." - "..song.track_name, "LMB to force play, RMB to move down" }})
				if( clicked ) then
					play_sound( "ass/generic_button" )
					switch_delay, gonna_play = delay, true
					force_the_same, num_override = true, i
					ComponentSetValue2( storage_delay, "value_float", 0 )
				elseif( r_clicked ) then
					play_sound( "ass/tab_hover" )
					if( i ~= #song_id_table ) then
						local memo = song_id_table[ i + 1 ]
						song_id_table[ i + 1 ], song_id_table[ i ] = song_id_table[ i ], memo
					end
					he_asked, extra_care = true, true
				end

				height = height + 11
			end

			return height + 15
		end, { color = {
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_2, pen.PALETTE.HRMS.RED_2,
			pen.PALETTE.HRMS.GOLD_3, pen.PALETTE.HRMS.RED_3
		}})

		if( he_asked ) then
			who_asked = pen.t.pack( who_asked )
			ComponentSetValue2( storage_ignored, "value_string", who_asked )
			pen.setting_set( "mrshll_core.IGNORE_LIST_"..playlist_num, who_asked )
			if( extra_care ) then
				local order = {}
				for i,song in ipairs( song_id_table ) do
					table.insert( order, song[1].."_"..song[2])
				end
				order = pen.t.pack( order )
				ComponentSetValue2( storage_ordered, "value_string", order )
				pen.setting_set( "mrshll_core.ORDER_LIST_"..playlist_num, order )
			end
			
			song_id_table, last_played = {}, 0
			switch_delay, gonna_play = delay, false
			ComponentSetValue2( storage_delay, "value_float", 0 )
			pen.magic_storage( entity_id, "played_songs", "value_string", "" )
		end
		
		pen.new_image( pic_x + 11, pic_y + 22, pic_z + 0.01, "mods/mrshll_core/mrshll/window_playlist.png", { can_click = true })
		pen.new_image( pic_x + 11, pic_y + 122 + anim, pic_z + 0.011, "mods/mrshll_core/mrshll/window_playlist_bottom.png" )
	end
	
	local text, genre, duration = "John Cage - 4'33\"", "Classical", 0
	if( last_played > 0 ) then
		local song_id = song_id_table[ last_played ]
		genre = mrshll[ song_id[1]].name
		local song = mrshll[ song_id[1]].stuff[ song_id[2]]
		text, duration = song.artist_name.." - "..song.track_name, song.duration
	end
	local dist = math.max( pen.get_text_dims( text, true ) + 2, is_listing and 94 or 1 )
	pen.new_image( pic_x + 11, pic_y, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
	pen.new_image( pic_x + 12, pic_y, pic_z, "mods/mrshll_core/mrshll/window_B.png", { s_x = dist, s_y = 1 })
	pen.new_image( pic_x + 12 + dist, pic_y, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
	new_button( pic_x + 11, pic_y, pic_z, pen.FILE_PIC_NIL, {
		s_x = dist/2 + 1, s_y = 5, no_anim = true, tip = { "Genre", genre }})
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
		tip = { "Time", true_tm > 0 and string.format( "%.1f", 100*math.min( true_tm/duration, 1 )).."%" or "" }})
	pen.new_text( pic_x + 13, pic_y + 11, pic_z - 0.01, tm, { color = pen.PALETTE.HRMS.RED_3 })
end

pen.gui_builder( true )

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

song_id_table = song_id_table or {}
if( not( pen.vld( song_id_table ))) then
	mrshll = dofile( "mods/mrshll_core/mrshll_list.lua" )
	
	local ignored = pen.t.pack( ComponentGetValue2( storage_ignored, "value_string" ))
	local function check( id )
		if( not( pen.vld( ignored ))) then return true end
		return pen.t.loop( ignored, function( i, v )
			if( v ~= id ) then return end
			table.remove( ignored, k )
			return false
		end) == nil
	end
	
	local order = pen.t.unarray( pen.t.pack( ComponentGetValue2( storage_ordered, "value_string" )))
	for i,cat in ipairs( mrshll ) do
		for e,song in ipairs( cat.stuff ) do
			if( check( cat.name.."_"..( song.id or song.artist_name.."_"..song.track_name ))) then
				table.insert( song_id_table, { i, e, order[ i.."_"..e ] or -1 })
			end
		end
	end
	table.sort( song_id_table, function( a, b )
		return ( a[3] > 0 and ( b[3] < 0 or a[3] < b[3]))
	end)
end

if( gonna_play ) then
	pen.t.loop({"left","right"}, function( i, v )
		local speaker = pen.get_child( entity_id, v )
		if( pen.vld( speaker, true )) then return end
		speaker = EntityLoad( "mods/mrshll_core/mrshll/speaker.xml", x, y )
		EntitySetName( speaker, v )
		EntityAddChild( entity_id, speaker )
	end)

	if( is_playing ~= 0 ) then return end

	local storage_purge = pen.magic_storage( entity_id, "gonna_purge" )
	if( ComponentGetValue2( storage_purge, "value_bool" )) then
		ComponentSetValue2( storage_purge, "value_bool", false )
		switch_delay = 10
	end

	if( switch_delay == 0 and pen.vld( song_id_table )) then
		if( num_override > 0 ) then num = num_override; num_override = 0 end
		num = ( num == 0 and ( random_order and pen.generic_random( 1, #song_id_table ) or ( last_played + 1 )) or num )

		local storage_played = pen.magic_storage( entity_id, "played_songs" )
		local played_list = pen.t.pack( ComponentGetValue2( storage_played, "value_string" ))
		if( num > #song_id_table ) then num, played_list = 1, {} end

		if( not( force_the_same ) and random_order and played_list[ num ] ~= nil ) then
			local nope = true
			for i = 1,#song_id_table do
				if( played_list[ i ] == nil ) then
					nope, num = false, i
					break
				end
			end
			if( nope ) then
				played_list = {}
				if( last_played == num ) then
					num = last_played - 1
					num = num < 1 and #song_id_table or num
				end
			end
		end
		force_the_same, last_played, played_list[ num ] = false, num, true
		ComponentSetValue2( storage_played, "value_string", pen.t.pack( played_list ))
		
		local song_id = song_id_table[ num ]
		local song = mrshll[ song_id[1]].stuff[ song_id[2]]
		pen.magic_storage( entity_id, "current_volume", "value_float", volume + ( song.custom_volume or 0 ))
		pen.magic_storage( entity_id, "sound_bank", "value_string", song.fmod_bank )
		pen.magic_storage( entity_id, "sound_event", "value_string", song.fmod_event )
		ComponentSetValue2( storage_delay, "value_float", song.duration + 90 )

		EntityAddTag( entity_id, "index_pic_update" )
		pen.magic_storage( entity_id, "index_pic_anim", "value_string", "|mods/mrshll_core/mrshll/anim/|5|5|" )
	else
		switch_delay = switch_delay - 1
		if( switch_delay ~= 5 ) then return end
		pen.t.loop({"left","right"}, function( i, v )
			pen.magic_comp( pen.get_child( entity_id, v ), "AudioLoopComponent", function( comp_id, v, is_enabled )
				ComponentSetValue2( comp_id, "file", "" )
				ComponentSetValue2( comp_id, "event_name", "" )
				ComponentSetValue2( comp_id, "m_volume", 0 )
				ComponentSetValue2( comp_id, "volume_autofade_speed", 1 )
			end)
		end)
	end
elseif( is_playing ~= 0 ) then
	ComponentSetValue2( storage_delay, "value_float", 0 )

	EntityAddTag( entity_id, "index_pic_update" )
	pen.magic_storage( entity_id, "index_pic_anim", "value_string", "|mods/mrshll_core/mrshll/anim/|5|1|" )
end