dofile_once( "mods/mnee/_penman.lua" )

function play_sound( event )
	pen.play_sound({ "mods/mrshll_core/mrshll.bank", event })
end

function new_tooltip( text, data )
	data = data or {}
	data.frames = data.frames or 15
	data.text_prefunc = function( text, data )
		text = pen.get_hybrid_table( text )
		if( pen.vld( text[2])) then
			text[1] = "{>underscore>{{-}|HRMS|GOLD_3|FORCED|{-}"..text[1].."}<underscore<}"
			text[1] = text[1].."\n{>indent>{{>color>{{-}|HRMS|GREY_2|{-}"..string.lower( text[2]).."}<color<}}<indent<}" end
		return text[1], 2, 0
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
		if( pen.vld( d.tip )) then new_tooltip( d.tip, { is_active = true }) end
		if( pen.vld( d.highlight )) then pen.new_pixel(
			pic_x - 1, pic_y - 1, pic_z + 0.001, d.highlight, d.dims[1] + 2, d.dims[2] + 2 ) end
		return pic_x, pic_y, pic_z, pic, d
	end
	data.pic_func = data.pic_func or function( pic_x, pic_y, pic_z, pic, d ) --different anim
		local a = ( d.no_anim or false ) and 1 or math.min(
			pen.animate( 1, d.auid.."l", { type = "sine", frames = d.frames, stillborn = true }),
			pen.animate( 1, d.auid.."r", { ease_out = "sin3", frames = d.frames, stillborn = true }))
		local s_anim = {( 1 - a )/d.dims[1], ( 1 - a )/d.dims[2] }

		if( not( d.is_centered )) then
			pic_x, pic_y = pic_x + d.dims[1]/2, pic_y + d.dims[2]/2 end
		return pen.new_image( pic_x, pic_y, pic_z, pic, { is_centered = true,
			s_x = ( d.s_x or 1 )*( 1 - s_anim[1]), s_y = ( d.s_y or 1 )*( 1 - s_anim[2]), angle = d.angle })
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
gonna_play = gonna_play or ( is_playing == 0 and last_played == nil and pen.setting_get( "mrshll_core.AUTOPLAY" ))
playlist_page, num_override, last_played = playlist_page or 0, num_override or 0, last_played or 0
switch_delay = switch_delay or ( gonna_play and delay or 0 )

local is_going = pen.get_active_item( hooman ) == entity_id
local pic_x, pic_y, pic_z, clicked, r_clicked = 181, 22, pen.LAYERS.MAIN, false, false

local storage_open = pen.magic_storage( entity_id, "is_open" )
if( pen.vld( storage_open, true )) then
	is_going = ComponentGetValue2( storage_open, "value_bool" )
	
	if( not( pen.is_inv_active( hooman ))) then
		clicked = new_button( 6, 6, pen.LAYERS.FOREGROUND,
			"mods/mrshll_core/mrshll/item.png", {
			is_centered = true,
			auid = "start_gui", no_anim = true,
			highlight = pen.PALETTE.HRMS.RED_1,
			hov_event = function( pic_x, pic_y, pic_z, pic, d )
				d.angle = math.rad( 15 )
				new_tooltip({ GameTextGetTranslatedOrNot( "Open Marshall" ), "just checking bruh" }, { is_active = true })
				return pic_x, pic_y, pic_z, pic, d
			end,
		})
		if( clicked ) then
			play_sound( "ass/special_button" )
			ComponentSetValue2( storage_open, "value_bool", not( is_going ))
		end
	else pen.gui_builder( false ) end
end
-- if( is_going and not( pen.is_inv_active( hooman ))) then
-- 	local gui = pen.gui_builder()

-- 	pen.new_button( pic_x, pic_y, pic_z, "mods/mrshll_core/mrshll/play_"..( gonna_play and "B" or "A" )..".png", {
-- 		lmb_event = function( pic_x, pic_y, pic_z, pic, d )
-- 			play_sound( "ass/generic_button" )
-- 			force_the_same = true
-- 			gonna_play = not( gonna_play )
-- 			num_override = last_played
-- 			switch_delay = gonna_play and 0 or delay
-- 			return pic_x, pic_y, pic_z, pic, d
-- 		end,
-- 		hov_event = function( pic_x, pic_y, pic_z, pic, d )
-- 			if( pen.vld( data.tip )) then mnee.new_tooltip( gonna_play and "Stop" or "Play", { is_active = true }) end
-- 			if( data.highlight ) then pen.new_pixel( pic_x - 1, pic_y - 1,
-- 				pic_z + 0.001, data.highlight, d.dims[1] + 2, d.dims[2] + 2 ) end
-- 			return pic_x, pic_y, pic_z, pic, d
-- 		end,
-- 	})

-- 	uid, clicked, r_clicked = new_button( gui, uid, pic_x + 181, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/next.png" )
-- 	uid = new_tooltip( gui, uid, "Next Song" )
-- 	if( clicked or r_clicked ) then
-- 		play_sound( "ass/"..( clicked and "generic" or "special" ).."_button" )
-- 		ComponentSetValue2( storage_delay, "value_float", 0 )
-- 		switch_delay = delay
-- 		gonna_play = true
-- 	end
	
-- 	uid, clicked, r_clicked = new_button( gui, uid, pic_x + 181, pic_y + 44, pic_z, "mods/mrshll_core/mrshll/volume.png" )
-- 	uid = new_tooltip( gui, uid, { "Volume: "..math.floor( volume*100 + 0.5 ), "LMB/RMB to rise/lower.", })
-- 	if( clicked or r_clicked ) then
-- 		play_sound( "ass/generic_button" )
-- 		local v = math.min( math.max( volume + 0.1*( clicked and 1 or -1 ), 0.3 ), 5 )
-- 		ComponentSetValue2( storage_volume, "value_float", v )
-- 		ComponentSetValue2( storage_sound, "value_float", current_volume + ( v - volume ))
-- 		ModSettingSetNextValue( "mrshll_core.VOLUME", v, false )
-- 	end
-- 	for i = 1,math.floor( 4*math.max( 1.3 - volume, 0 ) + 0.5 ) do
-- 		uid = new_image( gui, uid, pic_x + 187, pic_y + 43 + i*2, pic_z - 0.01, "mods/mrshll_core/mrshll/white.png", 2, 2 )
-- 	end
	
-- 	local is_listing = playlist_page > 0
-- 	uid, clicked, r_clicked = new_button( gui, uid, pic_x + 192, pic_y + 44, pic_z, "mods/mrshll_core/mrshll/playlist_"..( is_listing and "B" or "A" )..".png" )
-- 	uid = new_tooltip( gui, uid, "Playlist Editor" )
-- 	if( clicked ) then
-- 		play_sound( "ass/special_button" )
-- 		is_listing = not( is_listing )
-- 		playlist_page = is_listing and 1 or 0
-- 	end
-- 	if( is_listing ) then
-- 		uid, clicked, r_clicked = new_button( gui, uid, pic_x + 181, pic_y + 145, pic_z, "mods/mrshll_core/mrshll/up.png" )
-- 		if( clicked ) then
-- 			play_sound( "ass/generic_button" )
-- 			playlist_page = playlist_page - 1
-- 		elseif( r_clicked ) then
-- 			play_sound( "ass/special_button" )
-- 			playlist_page = 1
-- 		end
-- 		uid, clicked, r_clicked = new_button( gui, uid, pic_x + 181, pic_y + 156, pic_z, "mods/mrshll_core/mrshll/down.png" )
-- 		if( clicked ) then
-- 			play_sound( "ass/generic_button" )
-- 			playlist_page = playlist_page + 1
-- 		elseif( r_clicked ) then
-- 			play_sound( "ass/special_button" )
-- 			playlist_page = math.ceil( #song_id_table/10 )
-- 		end
-- 		local limit = math.ceil( #song_id_table/10 )
-- 		playlist_page = ( playlist_page > limit and 1 or ( playlist_page < 1 and limit or playlist_page ))
		
-- 		uid, clicked, r_clicked = new_button( gui, uid, pic_x + 192, pic_y + 167, pic_z, "mods/mrshll_core/mrshll/playlist_num_"..playlist_num..".png" )
-- 		uid = new_tooltip( gui, uid, "Playlist Num" )
-- 		if( clicked ) then
-- 			play_sound( "ass/special_button" )
-- 			playlist_num = playlist_num + 1
-- 			playlist_num = ( playlist_num > 3 and 1 or ( playlist_num < 1 and 3 or playlist_num ))
-- 			ModSettingSetNextValue( "mrshll_core.PLAYLIST", playlist_num, false )
-- 			ComponentSetValue2( storage_num, "value_int", playlist_num )
-- 			storage_ignored = get_storage( entity_id, "ignored_songs_"..playlist_num )
-- 			storage_ordered = get_storage( entity_id, "ordered_songs_"..playlist_num )
-- 			song_id_table = {}
-- 			last_played = 0
-- 			ComponentSetValue2( storage_delay, "value_float", 0 )
-- 			switch_delay = delay
-- 			gonna_play = false

-- 			ComponentSetValue2( get_storage( entity_id, "played_songs" ), "value_string", "" )
-- 		end
		
-- 		uid, clicked, r_clicked = new_button( gui, uid, pic_x + 278, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/playlist_reset.png" )
-- 		uid = new_tooltip( gui, uid, { "List Reset", "RMB to reset the playlist.", })
-- 		if( r_clicked ) then
-- 			play_sound( "ass/special_button" )
-- 			ComponentSetValue2( storage_ignored, "value_string", "@" )
-- 			ModSettingSetNextValue( "mrshll_core.IGNORE_LIST_"..playlist_num, "@", false )
-- 			ComponentSetValue2( storage_ordered, "value_string", "@" )
-- 			ModSettingSetNextValue( "mrshll_core.ORDER_LIST_"..playlist_num, "@", false )
-- 			song_id_table = {}
-- 			last_played = 0
-- 			ComponentSetValue2( storage_delay, "value_float", 0 )
-- 			switch_delay = delay
-- 			gonna_play = false

-- 			ComponentSetValue2( get_storage( entity_id, "played_songs" ), "value_string", "" )
-- 		end
		
-- 		uid, clicked, r_clicked = new_button( gui, uid, pic_x + 267, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/playlist_order_"..( random_order and "B" or "A" )..".png" )
-- 		uid = new_tooltip( gui, uid, { "Shuffle Toggle", ( random_order and "Randomised" or "Ordered" ).." Autoplay", })
-- 		if( clicked ) then
-- 			play_sound( "ass/generic_button" )
-- 			random_order = not( random_order )
-- 			ComponentSetValue2( storage_order, "value_bool", random_order )
-- 			ModSettingSetNextValue( "mrshll_core.IS_SHUFFLED", random_order, false )
-- 		end
		
-- 		local he_asked, extra_care = false, false
-- 		local who_asked = pen.t.pack( ComponentGetValue2( storage_ignored, "value_string" ))
-- 		for i = 1,10 do
-- 			local id = ( playlist_page - 1 )*10 + i
-- 			if( id <= #song_id_table ) then
-- 				local song_id = song_id_table[id]
-- 				local song = mrshll[ song_id[1]].stuff[ song_id[2]]
				
-- 				uid, clicked, r_clicked = new_button( gui, uid, pic_x + 279, pic_y + 44 + i*11, pic_z - 0.02, "mods/mrshll_core/mrshll/playlist_toggle_A.png" )
-- 				uid = new_tooltip( gui, uid, { "Remove", "RMB to exclude.", })
-- 				if( r_clicked ) then
-- 					play_sound( "ass/special_button" )
-- 					table.insert( who_asked, mrshll[ song_id[1]].name.."_"..( song.id or song.artist_name.."_"..song.track_name ))
-- 					he_asked = true
-- 				end
				
-- 				new_text( gui, pic_x + 196, pic_y + 44 + i*11, pic_z - 0.01, liner( song.track_name, 88 ), last_played == id and 4 or 1 )
				
-- 				uid, clicked, r_clicked = new_button( gui, uid, pic_x + 194, pic_y + 44 + i*11, pic_z, "mods/mrshll_core/mrshll/playlist_line.png" )
-- 				uid = new_tooltip( gui, uid, { song.artist_name.." - "..song.track_name, "LMB to force play.@RMB to move down.", })
-- 				if( clicked ) then
-- 					play_sound( "ass/generic_button" )
-- 					force_the_same = true
-- 					num_override = id
-- 					ComponentSetValue2( storage_delay, "value_float", 0 )
-- 					switch_delay = delay
-- 					gonna_play = true
-- 				elseif( r_clicked ) then
-- 					play_sound( "ass/tab_hover" )
-- 					if( id < #song_id_table ) then
-- 						song_id_table[ id ], song_id_table[ id + 1 ] = song_id_table[ id + 1 ], song_id_table[ id ]
-- 					end
-- 					he_asked = true
-- 					extra_care = true
-- 				end
-- 			end
-- 		end
-- 		if( he_asked ) then
-- 			who_asked = pen.t.pack( who_asked )
-- 			ComponentSetValue2( storage_ignored, "value_string", who_asked )
-- 			pen.setting_set( "mrshll_core.IGNORE_LIST_"..playlist_num, who_asked, false )
-- 			if( extra_care ) then
-- 				local order = {}
-- 				for i,song in ipairs( song_id_table ) do
-- 					table.insert( order, song[1].."_"..song[2] )
-- 				end
-- 				order = pen.t.pack( order )
-- 				ComponentSetValue2( storage_ordered, "value_string", order )
-- 				pen.setting_set( "mrshll_core.ORDER_LIST_"..playlist_num, order, false )
-- 			end
			
-- 			song_id_table, last_played = {}, 0
-- 			ComponentSetValue2( storage_delay, "value_float", 0 )
-- 			switch_delay, gonna_play = delay, false

-- 			pen.magic_storage( entity_id, "played_songs", "value_string", "" )
-- 		end
		
-- 		uid = new_button( gui, uid, pic_x + 192, pic_y + 44, pic_z + 0.01, "mods/mrshll_core/mrshll/window_playlist.png" )
-- 	end
	
-- 	local text = "John Cage - 4'33\""
-- 	local genre = "Classical"
-- 	if( last_played > 0 ) then
-- 		local song_id = song_id_table[ last_played ]
-- 		genre = mrshll[ song_id[1]].name
-- 		local song = mrshll[ song_id[1]].stuff[ song_id[2]]
-- 		text = song.artist_name.." - "..song.track_name
-- 	end
-- 	local dist = math.max( GuiGetTextDimensions( gui, text, 1, 2 ) + 2, is_listing and 94 or 1 )
-- 	uid = new_image( gui, uid, pic_x + 192, pic_y + 22, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
-- 	uid = new_image( gui, uid, pic_x + 193, pic_y + 22, pic_z, "mods/mrshll_core/mrshll/window_B.png", dist, 1 )
-- 	uid = new_image( gui, uid, pic_x + 193 + dist, pic_y + 22, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
-- 	new_text( gui, pic_x + 194, pic_y + 22, pic_z - 0.01, text )
-- 	uid = new_tooltip( gui, uid, { "Genre", genre, })
	
-- 	local tm = "00:00"
-- 	local true_tm = 0
-- 	if( last_played > 0 ) then
-- 		true_tm = ComponentGetValue2( get_storage( entity_id, "time_sync" ), "value_float" )
-- 		local mins = math.floor( true_tm/60/60 )
-- 		local secs = math.floor( true_tm/60 - mins*60 + 0.5 )
-- 		tm = string.sub( tostring( 100 + math.min( mins, 99 )), -2 )..":"..string.sub( tostring( 100 + secs ), -2 )
-- 		true_tm = math.floor( true_tm )
-- 	end
-- 	uid = new_image( gui, uid, pic_x + 192, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
-- 	uid = new_image( gui, uid, pic_x + 193, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/window_B.png", 27, 1 )
-- 	uid = new_image( gui, uid, pic_x + 220, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
-- 	new_text( gui, pic_x + 194, pic_y + 33, pic_z - 0.01, tm )
-- 	uid = new_tooltip( gui, uid, { "Time Left", true_tm > 0 and true_tm or "", })
-- else pen.gui_builder( false ) end

-- for i = 1,2 do
-- 	local name = i == 1 and "left" or "right"
-- 	local speaker = get_hooman_child( entity_id, name ) or 0
-- 	if( speaker > 0 ) then
-- 		local pos = { -30, 30 }
-- 		EntitySetTransform( speaker, x + pos[i], y - 10 )
		
-- 		local a_comp = EntityGetFirstComponentIncludingDisabled( speaker, "AudioLoopComponent" )
-- 		if( a_comp ~= nil and not( ComponentGetIsEnabled( a_comp ))) then
-- 			EntitySetComponentIsEnabled( speaker, a_comp, true )
-- 		end
-- 	end
-- end

-- song_id_table = song_id_table or {}
-- if( #song_id_table == 0 ) then
-- 	mrshll = dofile( "mods/mrshll_core/mrshll_list.lua" )
	
-- 	local ignored = pen.t.pack( ComponentGetValue2( storage_ignored, "value_string" ))
-- 	local function check( id )
-- 		if( #ignored > 0 ) then
-- 			for k,dud in ipairs( ignored ) do
-- 				if( dud == id ) then
-- 					table.remove( ignored, k )
-- 					return false
-- 				end
-- 			end
-- 		end
		
-- 		return true
-- 	end
	
-- 	local fuck_this = true
-- 	local function get_order()
-- 		local data_raw = ComponentGetValue2( storage_ordered, "value_string" )
-- 		if( data_raw == "@" ) then
-- 			return {}
-- 		end
		
-- 		local counter = 1
-- 		local data = {}
-- 		for style in string.gmatch( data_raw, "([^@]+)" ) do
-- 			data[style] = counter
-- 			counter = counter + 1
-- 		end
-- 		fuck_this = false
-- 		return data
-- 	end
	
-- 	local order = get_order()
-- 	for i,cat in ipairs( mrshll ) do
-- 		for e,song in ipairs( cat.stuff ) do
-- 			if( check( cat.name.."_"..( song.id or song.artist_name.."_"..song.track_name ))) then
-- 				table.insert( song_id_table, { i, e, order[ i.."_"..e ] or -1, })
-- 			end
-- 		end
-- 	end
	
-- 	if( not( fuck_this )) then
-- 		table.sort( song_id_table, function( a, b )
-- 			return ( a[3] > 0 and ( b[3] < 0 or a[3] < b[3]))
-- 		end)
-- 	end
-- end

-- if( gonna_play ) then
-- 	for i = 1,2 do	
-- 		local name = i == 1 and "left" or "right"
-- 		local speaker = get_hooman_child( entity_id, name ) or 0
-- 		if( speaker == 0 ) then
-- 			speaker = EntityLoad( "mods/mrshll_core/mrshll/speaker.xml", x, y )
-- 			EntitySetName( speaker, name )
-- 			EntityAddChild( entity_id, speaker )
-- 		end
-- 	end

-- 	if( is_playing == 0 ) then
-- 		local storage_purge = get_storage( entity_id, "gonna_purge" )
-- 		if( ComponentGetValue2( storage_purge, "value_bool" )) then
-- 			ComponentSetValue2( storage_purge, "value_bool", false )
-- 			switch_delay = 10
-- 		end

-- 		if( switch_delay == 0 and #song_id_table > 0 ) then
-- 			if( num_override > 0 ) then
-- 				num = num_override
-- 				num_override = 0
-- 			end

-- 			num = ( num == 0 and ( random_order and generic_random( 1, #song_id_table ) or ( last_played + 1 )) or num )

-- 			local storage_played = get_storage( entity_id, "played_songs" )
-- 			local played_list = pen.t.pack( ComponentGetValue2( storage_played, "value_string" ))
-- 			if( num > #song_id_table ) then
-- 				num = 1
-- 				played_list = {}
-- 			end
-- 			if( not( force_the_same or false ) and random_order and played_list[ num ] ~= nil ) then
-- 				local nope = true
-- 				for i = 1,#song_id_table do
-- 					if( played_list[ i ] == nil ) then
-- 						nope = false
-- 						num = i
-- 						break
-- 					end
-- 				end
-- 				if( nope ) then
-- 					played_list = {}
-- 					if( last_played == num ) then
-- 						num = last_played - 1
-- 						num = num < 1 and #song_id_table or num
-- 					end
-- 				end
-- 			end
-- 			force_the_same = false
-- 			last_played = num
-- 			played_list[ num ] = true
-- 			ComponentSetValue2( storage_played, "value_string", pen.t.pack( played_list ))
			
-- 			local song_id = song_id_table[ num ]
-- 			local song = mrshll[ song_id[1]].stuff[ song_id[2]]
-- 			ComponentSetValue2( get_storage( entity_id, "current_volume" ), "value_float", volume + ( song.custom_volume or 0 ))
-- 			ComponentSetValue2( get_storage( entity_id, "sound_bank" ), "value_string", song.fmod_bank )
-- 			ComponentSetValue2( get_storage( entity_id, "sound_event" ), "value_string", song.fmod_event )
-- 			ComponentSetValue2( storage_delay, "value_float", song.duration + 90 )

-- 			EntityAddTag( entity_id, "index_pic_update" )
-- 			ComponentSetValue2( get_storage( entity_id, "index_pic_anim" ), "value_string", "|mods/mrshll_core/mrshll/anim/|5|5|" )
-- 		else
-- 			switch_delay = switch_delay - 1
-- 			if( switch_delay == 5 ) then
-- 				for i = 1,2 do
-- 					local dud = get_hooman_child( entity_id, i == 1 and "left" or "right" )
-- 					edit_component_ultimate( dud, "AudioLoopComponent", function(comp,vars)
-- 						ComponentSetValue2( comp, "file", "" )
-- 						ComponentSetValue2( comp, "event_name", "" )
-- 						ComponentSetValue2( comp, "m_volume", 0 )
-- 						ComponentSetValue2( comp, "volume_autofade_speed", 1 )
-- 					end)
-- 				end
-- 			end
-- 		end
-- 	end
-- elseif( is_playing ~= 0 ) then
-- 	ComponentSetValue2( storage_delay, "value_float", 0 )

-- 	EntityAddTag( entity_id, "index_pic_update" )
-- 	ComponentSetValue2( get_storage( entity_id, "index_pic_anim" ), "value_string", "|mods/mrshll_core/mrshll/anim/|5|1|" )
-- end