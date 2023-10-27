dofile_once( "mods/mrshll_core/lib.lua" )

function t2w( str )
	local t = {}
	
	for word in string.gmatch( str, "([^%s]+)" ) do
		table.insert( t, word )
	end
	
	return t
end

function generic_random( a, b, macro_drift, bidirectional )
	bidirectional = bidirectional or false
	
	if( macro_drift == nil ) then
		macro_drift = GetUpdatedEntityID() or 0
		if( macro_drift > 0 ) then
			local drft_a, drft_b = EntityGetTransform( macro_drift )
			macro_drift = macro_drift + tonumber( macro_drift ) + ( drft_a*1000 + drft_b )
		else
			macro_drift = 1
		end
	elseif( type( macro_drift ) == "table" ) then
		macro_drift = macro_drift[1]*1000 + macro_drift[2]
	end
	macro_drift = math.floor( macro_drift + 0.5 )
	
	local tm = { GameGetDateAndTimeUTC() }
	SetRandomSeed( math.random( GameGetFrameNum(), macro_drift ), (((( tm[2]*30 + tm[3] )*24 + tm[4] )*60 + tm[5] )*60 + tm[6] )%macro_drift )
	Random( 1, 5 ); Random( 1, 5 ); Random( 1, 5 )
	return bidirectional and ( Random( a, b*2 ) - b ) or Random( a, b )
end

function liner( text, length, height, length_k, clean_mode, forced_reverse )
	local formated = {}
	if( text ~= nil and text ~= "" ) then
		local length_counter = 0
		if( height ~= nil ) then
			length_k = length_k or 6
			length = math.floor( length/length_k + 0.5 )
			height = math.floor( height/9 )
			local height_counter = 1
			
			local full_text = "@"..text.."@"
			for line in string.gmatch( full_text, "([^@]+)" ) do
				local rest = ""
				local buffer = ""
				local dont_touch = false
				
				length_counter = 0
				text = ""
				
				local words = t2w( line )
				for i,word in ipairs( words ) do
					buffer = word
					local w_length = string.len( buffer ) + 1
					length_counter = length_counter + w_length
					dont_touch = false
					
					if( length_counter > length ) then
						if( w_length >= length ) then
							rest = string.sub( buffer, length - ( length_counter - w_length - 1 ), w_length )
							text = text..buffer.." "
						else
							length_counter = w_length
						end
						table.insert( formated, tostring( string.gsub( string.sub( text, 1, length ), "@ ", "" )))
						height_counter = height_counter + 1
						text = ""
						while( rest ~= "" ) do
							w_length = string.len( rest ) + 1
							length_counter = w_length
							buffer = rest
							if( length_counter > length ) then
								rest = string.sub( rest, length + 1, w_length )
								table.insert( formated, tostring( string.sub( buffer, 1, length )))
								dont_touch = true
								height_counter = height_counter + 1
							else
								rest = ""
								length_counter = w_length
							end
							
							if( height_counter > height ) then
								break
							end
						end
					end
					
					if( height_counter > height ) then
						break
					end
					
					text = text..buffer.." "
				end
				
				if( not( dont_touch )) then
					table.insert( formated, tostring( string.sub( text, 1, length )))
				end
			end
		else
			local gui = GuiCreate()
			GuiStartFrame( gui )
			
			local starter = math.floor( math.abs( length )/7 + 0.5 )
			local total_length = string.len( text )
			if( starter < total_length ) then
				if(( length > 0 ) and forced_reverse == nil ) then
					length = math.abs( length )
					formated = string.sub( text, 1, starter )
					for i = starter + 1,total_length do
						formated = formated..string.sub( text, i, i )
						length_counter = GuiGetTextDimensions( gui, formated, 1, 2 )
						if( length_counter > length ) then
							formated = string.sub( formated, 1, string.len( formated ) - 1 )
							break
						end
					end
				else
					length = math.abs( length )
					starter = total_length - starter
					formated = string.sub( text, starter, total_length )
					while starter > 0 do
						starter = starter - 1
						formated = string.sub( text, starter, starter )..formated
						length_counter = GuiGetTextDimensions( gui, formated, 1, 2 )
						if( length_counter > length ) then
							formated = string.sub( formated, 2, string.len( formated ))
							break
						end
					end
				end
			else
				formated = text
			end
			
			GuiDestroy( gui )
		end
	else
		if( clean_mode == nil ) then
			table.insert( formated, "[NIL]" )
		else
			formated = ""
		end
	end
	
	return formated
end

function access_list( storage, tbl )
	if( tbl == nil ) then
		local data_raw = ComponentGetValue2( storage, "value_string" )
		if( data_raw == "@" ) then
			return {}
		end
		
		local data = {}
		
		for style in string.gmatch( data_raw, "([^@]+)" ) do
			table.insert( data, style )
		end
		
		return data
	else
		local storage_styles = storage
		local value = "@"
		if( #tbl > 0 ) then
			for i,style in ipairs( tbl ) do
				value = value..style.."@"
			end
		end
		ComponentSetValue2( storage_styles, "value_string", value )
		
		return value
	end
end

function get_active_wand( hooman )
	local inv_comp = EntityGetFirstComponentIncludingDisabled( hooman, "Inventory2Component" )
	if( inv_comp ~= nil ) then
		return tonumber( ComponentGetValue2( inv_comp, "mActiveItem" ) or 0 )
	end
	
	return 0
end

function play_sound( event )
	local c_x, c_y = GameGetCameraPos()
	GamePlaySound( "mods/mrshll_core/mrshll.bank", event, c_x, c_y )
end

function colourer( gui, c_type, alpha )
	local color = { r = 0, g = 0, b = 0 }
	if( type( c_type ) == "table" ) then
		color.r = c_type[1] or 255
		color.g = c_type[2] or 255
		color.b = c_type[3] or 255
	else
		if( c_type == nil or c_type == 1 ) then
			color.r = 232
			color.g = 59
			color.b = 59
		elseif( c_type == 2 ) then
			color.r = 98
			color.g = 85
			color.b = 101
		elseif( c_type == 3 ) then
			color.r = 199
			color.g = 220
			color.b = 208
		elseif( c_type == 4 ) then
			color.r = 251
			color.g = 185
			color.b = 84
		elseif( c_type == 5 ) then
			color.r = 30
			color.g = 188
			color.b = 115
		end
	end
	
	GuiColorSetForNextWidget( gui, color.r/255, color.g/255, color.b/255, alpha or 1 )
end

function gui_killer( gui )
	if( gui ~= nil ) then
		GuiDestroy( gui )
	end
end

function new_text( gui, pic_x, pic_y, pic_z, text, colours, alpha )
	local out_str = {}
	if( text ~= nil ) then
		if( type( text ) == "table" ) then
			out_str = text
		else
			table.insert( out_str, text )
		end
	else
		table.insert( out_str, "[NIL]" )
	end
	
	for i,line in ipairs( out_str ) do
		colourer( gui, colours or 1, alpha )
		GuiZSetForNextWidget( gui, pic_z )
		GuiText( gui, pic_x, pic_y, line )
		pic_y = pic_y + 9
	end
end

function new_image( gui, uid, pic_x, pic_y, pic_z, pic, s_x, s_y, alpha, interactive )
	if( not( interactive or false )) then
		GuiOptionsAddForNextWidget( gui, 2 ) --NonInteractive
	end
	GuiZSetForNextWidget( gui, pic_z )
	uid = uid + 1
	GuiIdPush( gui, uid )
	GuiImage( gui, uid, pic_x, pic_y, pic, alpha or 1, s_x or 1, s_y or 1 )
	return uid
end

function new_button( gui, uid, pic_x, pic_y, pic_z, pic )
	GuiZSetForNextWidget( gui, pic_z )
	uid = uid + 1
	GuiIdPush( gui, uid )
	GuiOptionsAddForNextWidget( gui, 6 ) --NoPositionTween
	GuiOptionsAddForNextWidget( gui, 4 ) --ClickCancelsDoubleClick
	GuiOptionsAddForNextWidget( gui, 21 ) --DrawNoHoverAnimation
	GuiOptionsAddForNextWidget( gui, 47 ) --NoSound
	local clicked, r_clicked = GuiImageButton( gui, uid, pic_x, pic_y, "", pic )
	return uid, clicked, r_clicked
end

function world2gui( x, y, not_pos )
	not_pos = not_pos or false
	
	local gui = GuiCreate()
	GuiStartFrame( gui )
	local w, h = GuiGetScreenDimensions( gui )
	GuiDestroy( gui )
	
	local shit_from_ass = w/( MagicNumbersGetValue( "VIRTUAL_RESOLUTION_X" ) + MagicNumbersGetValue( "VIRTUAL_RESOLUTION_OFFSET_X" ))
	if( not_pos ) then
		x, y = shit_from_ass*x, shit_from_ass*y
	else
		local cam_x, cam_y = GameGetCameraPos()
		x, y = w/2 + shit_from_ass*( x - cam_x ), h/2 + shit_from_ass*( y - cam_y )
	end
	
	return x, y, shit_from_ass
end

function get_mouse_pos()
	local m_x, m_y = DEBUG_GetMouseWorld()
	return world2gui( m_x, m_y )
end

function new_tooltip( gui, uid, text )
	local _, _, is_hovered = GuiGetPreviousWidgetInfo( gui )
	if( is_hovered ) then
		if( text == "" ) then
			return uid
		end
		
		if( not( tip_going )) then
			tip_going = true
			
			if( type( text ) ~= "table" ) then
				text = { text, "" }
			end
			
			local w, h = GuiGetScreenDimensions( gui )
			local pic_x, pic_y = get_mouse_pos()
			pic_x, pic_y = pic_x + 6, pic_y + 6
			local pic_z = -99999
			
			local x_offset, y_offset = GuiGetTextDimensions( gui, text[1], 1, 2 )
			
			local length = 0
			if( text[2] ~= "" ) then
				text[2] = liner( text[2], w*0.9, h - 2, 5.8 )
				for i,line in ipairs( text[2] ) do
					local current_length = GuiGetTextDimensions( gui, line, 1, 2 )
					if( current_length > length ) then
						length = current_length
					end
				end
			end
			
			local title_height = 7
			local extra = 8
			x_offset, y_offset = math.max( x_offset, length ) + extra, 9*#text[2] + extra + title_height + 2
			if( w < pic_x + x_offset ) then
				pic_x = w - x_offset
			end
			if( h < pic_y + y_offset ) then
				pic_y = h - y_offset
			end
			
			local drift = extra + 2
			x_offset, y_offset = x_offset - drift, y_offset - drift
			
			local trig_val = 1
			local corner_x, corner_y = trig_val*( x_offset + 8 ), trig_val*( y_offset + 8 )
			
			local shadow_drift = 0.35*trig_val
			local shadow_alpha = 0.4*trig_val
			
			local gui_core = "mods/mrshll_core/mrshll/tooltip/"
			
			local frame_sin = 80*( math.sin( GameGetFrameNum()/10 ) + 1 )
			colourer( gui, { 255 - frame_sin, 255, 255, })
			uid = new_image( gui, uid, pic_x + math.floor((( x_offset + 4.5 ) - corner_x )/2 + 0.5 ), pic_y + math.floor((( y_offset + 4.5 ) - corner_y )/2 + 0.5 ), pic_z - 1, gui_core.."module_corner.png" )
			
			uid = new_image( gui, uid, pic_x, pic_y, pic_z, gui_core.."module_A_1.png" )
			uid = new_image( gui, uid, pic_x + 3, pic_y, pic_z, gui_core.."module_A_2.png", x_offset, 1, trig_val )
			uid = new_image( gui, uid, pic_x + 6 + x_offset, pic_y, pic_z, gui_core.."module_A_1.png", -1, 1, trig_val )
			uid = new_image( gui, uid, pic_x + 6 + x_offset, pic_y + 3, pic_z, gui_core.."module_A_2_alt.png", -1, title_height, trig_val )
			uid = new_image( gui, uid, pic_x + 3 + x_offset, pic_y + 3 + title_height, pic_z, gui_core.."module_C_1.png", nil, nil, trig_val )
			uid = new_image( gui, uid, pic_x + 3, pic_y + 6 + title_height, pic_z, gui_core.."module_A_2.png", x_offset, -1, trig_val )
			uid = new_image( gui, uid, pic_x, pic_y + 6 + title_height, pic_z, gui_core.."module_A_1.png", 1, -1, trig_val )
			uid = new_image( gui, uid, pic_x, pic_y + 3, pic_z, gui_core.."module_A_2_alt.png", 1, title_height, trig_val )
			uid = new_image( gui, uid, pic_x + 2, pic_y + 2, pic_z + 0.01, "mods/mrshll_core/mrshll/white.png", x_offset + 2, title_height + 2, trig_val )
			new_text( gui, pic_x + 2, pic_y + 1, pic_z - 0.1, text[1], 1, trig_val )
			uid = new_image( gui, uid, pic_x - 3 + shadow_drift, pic_y - 3 + shadow_drift, pic_z + 0.11, gui_core.."shadow_A.png", 0.5, 0.5, shadow_alpha )
			uid = new_image( gui, uid, pic_x + 2.5 + shadow_drift, pic_y - 3 + shadow_drift, pic_z + 0.11, gui_core.."shadow_B.png", ( x_offset + 1.5 )/2 + 0.25, 0.5, shadow_alpha )
			uid = new_image( gui, uid, pic_x + 4.5 + x_offset + shadow_drift, pic_y - 3 + shadow_drift, pic_z + 0.11, gui_core.."shadow_C_1.png", 0.5, 0.5, shadow_alpha )
			uid = new_image( gui, uid, pic_x - 3 + shadow_drift, pic_y + 5 + title_height + shadow_drift, pic_z + 0.11, gui_core.."shadow_B_alt.png", 0.5, 0.5, shadow_alpha )
			uid = new_image( gui, uid, pic_x - 3 + shadow_drift, pic_y + 2.5 + shadow_drift, pic_z + 0.11, gui_core.."shadow_B_alt.png", 0.5, ( title_height + 2 )/2 + 0.25, shadow_alpha )
			uid = new_image( gui, uid, pic_x - 2 + shadow_drift, pic_y + 6 + title_height + shadow_drift, pic_z + 0.11, gui_core.."shadow_B_alt.png", 0.5, ( y_offset - title_height + 0.5 )/2 + 0.25, shadow_alpha )
			
			pic_x, pic_y, pic_z, x_offset, y_offset = pic_x + 1, pic_y + 1, pic_z + 0.1, x_offset + 1, y_offset + 1
			uid = new_image( gui, uid, pic_x, pic_y, pic_z, gui_core.."module_B_1.png", nil, nil, trig_val )
			uid = new_image( gui, uid, pic_x + 3, pic_y, pic_z, gui_core.."module_B_2.png", x_offset, 1, trig_val )
			uid = new_image( gui, uid, pic_x + 6 + x_offset, pic_y, pic_z, gui_core.."module_B_1.png", -1, 1, trig_val )
			uid = new_image( gui, uid, pic_x + 6 + x_offset, pic_y + 3, pic_z, gui_core.."module_B_2_alt.png", -1, y_offset, trig_val )
			uid = new_image( gui, uid, pic_x + 3 + x_offset, pic_y + 3 + y_offset, pic_z, gui_core.."module_C_2.png", nil, nil, trig_val )
			uid = new_image( gui, uid, pic_x + 3, pic_y + 6 + y_offset, pic_z, gui_core.."module_B_2.png", x_offset, -1, trig_val )
			uid = new_image( gui, uid, pic_x, pic_y + 6 + y_offset, pic_z, gui_core.."module_B_1.png", 1, -1, trig_val )
			uid = new_image( gui, uid, pic_x, pic_y + 3, pic_z, gui_core.."module_B_2_alt.png", 1, y_offset, trig_val )
			uid = new_image( gui, uid, pic_x + 2, pic_y + 2, pic_z + 0.01, "mods/mrshll_core/mrshll/white.png", x_offset + 2, y_offset + 2, trig_val )
			if( text[2] ~= "" ) then
				new_text( gui, pic_x + 3, pic_y + title_height + 5, pic_z - 0.1, text[2], 2, trig_val )
			end
			uid = new_image( gui, uid, pic_x + 8 + x_offset + shadow_drift, pic_y + 0.5 + shadow_drift, pic_z + 0.11, gui_core.."shadow_B_alt.png", -0.5, ( y_offset + 2.25 )/2 + 0.25, shadow_alpha )
			uid = new_image( gui, uid, pic_x + 2.5 + x_offset + shadow_drift, pic_y + 3.25 + y_offset + shadow_drift, pic_z + 0.11, gui_core.."shadow_C_3.png", 0.5, 0.5, shadow_alpha )
			uid = new_image( gui, uid, pic_x + 0.5 + shadow_drift, pic_y + 8.75 + y_offset + shadow_drift, pic_z + 0.11, gui_core.."shadow_B.png", ( x_offset + 1.5 )/2 + 0.25, -0.5, shadow_alpha )
			uid = new_image( gui, uid, pic_x - 3 + shadow_drift, pic_y + 5.25 + y_offset + shadow_drift, pic_z + 0.11, gui_core.."shadow_C_2.png", 0.5, 0.5, shadow_alpha )
			
			colourer( gui, { 255 - ( 160 - frame_sin ), 255, 255, })
			uid = new_image( gui, uid, pic_x + math.floor((( x_offset + 8.5 ) + corner_x )/2 + 0.5 ), pic_y + math.floor((( y_offset + 8.5 ) + corner_y )/2 + 0.5 ), pic_z - 1, gui_core.."module_corner.png", -1, -1 )
		end
	end
	
	return uid
end

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( EntityGetRootEntity( entity_id ))

local delay = 10
tip_going = false
gonna_play = gonna_play or ModSettingGetNextValue( "mrshll_core.AUTOPLAY" )
last_played = last_played or 0
switch_delay = switch_delay or ( gonna_play and delay or 0 )
playlist_page = playlist_page or 0
num_override = num_override or 0

local storage_delay = get_storage( entity_id, "is_playing" )
local is_playing = ComponentGetValue2( storage_delay, "value_float" )

local storage_volume = get_storage( entity_id, "sound_volume" )
local volume = ComponentGetValue2( storage_volume, "value_float" )
local storage_sound = get_storage( entity_id, "current_volume" )
local current_volume = ComponentGetValue2( storage_sound, "value_float" )

local storage_order = get_storage( entity_id, "random_order" )
local random_order = ComponentGetValue2( storage_order, "value_bool" )

local storage_num = get_storage( entity_id, "playlist_num" )
local playlist_num = ComponentGetValue2( storage_num, "value_int" )

local storage_ignored = get_storage( entity_id, "ignored_songs_"..playlist_num )
local storage_ordered = get_storage( entity_id, "ordered_songs_"..playlist_num )

local num = 0

local storage_open = get_storage( entity_id, "is_open" )
local is_going = ( storage_open ~= nil ) or ( get_active_wand( EntityGetRootEntity( entity_id )) == entity_id )
if( storage_open ~= nil ) then
	is_going = ComponentGetValue2( storage_open, "value_bool" )
	
	if( not( GameIsInventoryOpen())) then
		g = g or GuiCreate()
		GuiStartFrame( g )
		
		local uid, clicked = new_button( g, 1, 1, 1, -100, "mods/mrshll_core/mrshll/item.png" )
		if( clicked ) then
			play_sound( "ass/special_button" )
			ComponentSetValue2( storage_open, "value_bool", not( is_going ))
		end
	else
		g = gui_killer( g )
	end
end
if( is_going and not( GameIsInventoryOpen())) then
	if( gui == nil ) then
		gui = GuiCreate()
	end
	GuiStartFrame( gui )
	
	local clicked, r_clicked, pic_z = 0, 0, 50
	local pic_x, pic_y, uid = 0, 0, 0
	
	uid, clicked = new_button( gui, uid, pic_x + 181, pic_y + 22, pic_z, "mods/mrshll_core/mrshll/play_"..( gonna_play and "B" or "A" )..".png" )
	uid = new_tooltip( gui, uid, gonna_play and "Stop" or "Play" )
	if( clicked ) then
		play_sound( "ass/generic_button" )
		force_the_same = true
		gonna_play = not( gonna_play )
		num_override = last_played
		switch_delay = gonna_play and 0 or delay
	end
	
	uid, clicked, r_clicked = new_button( gui, uid, pic_x + 181, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/next.png" )
	uid = new_tooltip( gui, uid, "Next Song" )
	if( clicked or r_clicked ) then
		play_sound( "ass/"..( clicked and "generic" or "special" ).."_button" )
		ComponentSetValue2( storage_delay, "value_float", 0 )
		switch_delay = delay
		gonna_play = true
	end
	
	uid, clicked, r_clicked = new_button( gui, uid, pic_x + 181, pic_y + 44, pic_z, "mods/mrshll_core/mrshll/volume.png" )
	uid = new_tooltip( gui, uid, { "Volume: "..math.floor( volume*100 + 0.5 ), "LMB/RMB to rise/lower.", })
	if( clicked or r_clicked ) then
		play_sound( "ass/generic_button" )
		local v = math.min( math.max( volume + 0.1*( clicked and 1 or -1 ), 0.3 ), 5 )
		ComponentSetValue2( storage_volume, "value_float", v )
		ComponentSetValue2( storage_sound, "value_float", current_volume + ( v - volume ))
		ModSettingSetNextValue( "mrshll_core.VOLUME", v, false )
	end
	for i = 1,math.floor( 4*math.max( 1.3 - volume, 0 ) + 0.5 ) do
		uid = new_image( gui, uid, pic_x + 187, pic_y + 43 + i*2, pic_z - 0.01, "mods/mrshll_core/mrshll/white.png", 2, 2 )
	end
	
	local is_listing = playlist_page > 0
	uid, clicked, r_clicked = new_button( gui, uid, pic_x + 192, pic_y + 44, pic_z, "mods/mrshll_core/mrshll/playlist_"..( is_listing and "B" or "A" )..".png" )
	uid = new_tooltip( gui, uid, "Playlist Editor" )
	if( clicked ) then
		play_sound( "ass/special_button" )
		is_listing = not( is_listing )
		playlist_page = is_listing and 1 or 0
	end
	if( is_listing ) then
		uid, clicked, r_clicked = new_button( gui, uid, pic_x + 181, pic_y + 145, pic_z, "mods/mrshll_core/mrshll/up.png" )
		if( clicked ) then
			play_sound( "ass/generic_button" )
			playlist_page = playlist_page - 1
		elseif( r_clicked ) then
			play_sound( "ass/special_button" )
			playlist_page = 1
		end
		uid, clicked, r_clicked = new_button( gui, uid, pic_x + 181, pic_y + 156, pic_z, "mods/mrshll_core/mrshll/down.png" )
		if( clicked ) then
			play_sound( "ass/generic_button" )
			playlist_page = playlist_page + 1
		elseif( r_clicked ) then
			play_sound( "ass/special_button" )
			playlist_page = math.ceil( #song_id_table/10 )
		end
		local limit = math.ceil( #song_id_table/10 )
		playlist_page = ( playlist_page > limit and 1 or ( playlist_page < 1 and limit or playlist_page ))
		
		uid, clicked, r_clicked = new_button( gui, uid, pic_x + 192, pic_y + 167, pic_z, "mods/mrshll_core/mrshll/playlist_num_"..playlist_num..".png" )
		uid = new_tooltip( gui, uid, "Playlist Num" )
		if( clicked ) then
			play_sound( "ass/special_button" )
			playlist_num = playlist_num + 1
			playlist_num = ( playlist_num > 3 and 1 or ( playlist_num < 1 and 3 or playlist_num ))
			ModSettingSetNextValue( "mrshll_core.PLAYLIST", playlist_num, false )
			ComponentSetValue2( storage_num, "value_int", playlist_num )
			storage_ignored = get_storage( entity_id, "ignored_songs_"..playlist_num )
			storage_ordered = get_storage( entity_id, "ordered_songs_"..playlist_num )
			song_id_table = {}
			last_played = 0
			ComponentSetValue2( storage_delay, "value_float", 0 )
			switch_delay = delay
			gonna_play = false

			ComponentSetValue2( get_storage( entity_id, "played_songs" ), "value_string", "" )
		end
		
		uid, clicked, r_clicked = new_button( gui, uid, pic_x + 278, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/playlist_reset.png" )
		uid = new_tooltip( gui, uid, { "List Reset", "RMB to reset the playlist.", })
		if( r_clicked ) then
			play_sound( "ass/special_button" )
			ComponentSetValue2( storage_ignored, "value_string", "@" )
			ModSettingSetNextValue( "mrshll_core.IGNORE_LIST_"..playlist_num, "@", false )
			ComponentSetValue2( storage_ordered, "value_string", "@" )
			ModSettingSetNextValue( "mrshll_core.ORDER_LIST_"..playlist_num, "@", false )
			song_id_table = {}
			last_played = 0
			ComponentSetValue2( storage_delay, "value_float", 0 )
			switch_delay = delay
			gonna_play = false

			ComponentSetValue2( get_storage( entity_id, "played_songs" ), "value_string", "" )
		end
		
		uid, clicked, r_clicked = new_button( gui, uid, pic_x + 267, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/playlist_order_"..( random_order and "B" or "A" )..".png" )
		uid = new_tooltip( gui, uid, { "Shuffle Toggle", ( random_order and "Randomised" or "Ordered" ).." Autoplay", })
		if( clicked ) then
			play_sound( "ass/generic_button" )
			random_order = not( random_order )
			ComponentSetValue2( storage_order, "value_bool", random_order )
			ModSettingSetNextValue( "mrshll_core.IS_SHUFFLED", random_order, false )
		end
		
		local who_asked = access_list( storage_ignored ) or {}
		local he_asked = false
		local extra_care = false
		for i = 1,10 do
			local id = ( playlist_page - 1 )*10 + i
			if( id <= #song_id_table ) then
				local song_id = song_id_table[id]
				local song = mrshll[ song_id[1]].stuff[ song_id[2]]
				
				uid, clicked, r_clicked = new_button( gui, uid, pic_x + 279, pic_y + 44 + i*11, pic_z - 0.02, "mods/mrshll_core/mrshll/playlist_toggle_A.png" )
				uid = new_tooltip( gui, uid, { "Remove", "RMB to exclude.", })
				if( r_clicked ) then
					play_sound( "ass/special_button" )
					table.insert( who_asked, mrshll[ song_id[1]].name.."_"..( song.id or song.artist_name.."_"..song.track_name ))
					he_asked = true
				end
				
				new_text( gui, pic_x + 196, pic_y + 44 + i*11, pic_z - 0.01, liner( song.track_name, 88 ), last_played == id and 4 or 1 )
				
				uid, clicked, r_clicked = new_button( gui, uid, pic_x + 194, pic_y + 44 + i*11, pic_z, "mods/mrshll_core/mrshll/playlist_line.png" )
				uid = new_tooltip( gui, uid, { song.artist_name.." - "..song.track_name, "LMB to force play.@RMB to move down.", })
				if( clicked ) then
					play_sound( "ass/generic_button" )
					force_the_same = true
					num_override = id
					ComponentSetValue2( storage_delay, "value_float", 0 )
					switch_delay = delay
					gonna_play = true
				elseif( r_clicked ) then
					play_sound( "ass/tab_hover" )
					if( id < #song_id_table ) then
						song_id_table[ id ], song_id_table[ id + 1 ] = song_id_table[ id + 1 ], song_id_table[ id ]
					end
					he_asked = true
					extra_care = true
				end
			end
		end
		if( he_asked ) then
			ModSettingSetNextValue( "mrshll_core.IGNORE_LIST_"..playlist_num, access_list( storage_ignored, who_asked ), false )
			if( extra_care ) then
				local order = {}
				for i,song in ipairs( song_id_table ) do
					table.insert( order, song[1].."_"..song[2] )
				end
				ModSettingSetNextValue( "mrshll_core.ORDER_LIST_"..playlist_num, access_list( storage_ordered, order ), false )
			end
			
			song_id_table = {}
			last_played = 0
			ComponentSetValue2( storage_delay, "value_float", 0 )
			switch_delay = delay
			gonna_play = false

			ComponentSetValue2( get_storage( entity_id, "played_songs" ), "value_string", "" )
		end
		
		uid = new_button( gui, uid, pic_x + 192, pic_y + 44, pic_z + 0.01, "mods/mrshll_core/mrshll/window_playlist.png" )
	end
	
	local text = "John Cage - 4'33\""
	local genre = "Classical"
	if( last_played > 0 ) then
		local song_id = song_id_table[ last_played ]
		genre = mrshll[ song_id[1]].name
		local song = mrshll[ song_id[1]].stuff[ song_id[2]]
		text = song.artist_name.." - "..song.track_name
	end
	local dist = math.max( GuiGetTextDimensions( gui, text, 1, 2 ) + 2, is_listing and 94 or 1 )
	uid = new_image( gui, uid, pic_x + 192, pic_y + 22, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
	uid = new_image( gui, uid, pic_x + 193, pic_y + 22, pic_z, "mods/mrshll_core/mrshll/window_B.png", dist, 1 )
	uid = new_image( gui, uid, pic_x + 193 + dist, pic_y + 22, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
	new_text( gui, pic_x + 194, pic_y + 22, pic_z - 0.01, text )
	uid = new_tooltip( gui, uid, { "Genre", genre, })
	
	local tm = "00:00"
	local true_tm = 0
	if( last_played > 0 ) then
		true_tm = ComponentGetValue2( get_storage( entity_id, "time_sync" ), "value_float" )
		local mins = math.floor( true_tm/60/60 )
		local secs = math.floor( true_tm/60 - mins*60 + 0.5 )
		tm = string.sub( tostring( 100 + math.min( mins, 99 )), -2 )..":"..string.sub( tostring( 100 + secs ), -2 )
		true_tm = math.floor( true_tm )
	end
	uid = new_image( gui, uid, pic_x + 192, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
	uid = new_image( gui, uid, pic_x + 193, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/window_B.png", 27, 1 )
	uid = new_image( gui, uid, pic_x + 220, pic_y + 33, pic_z, "mods/mrshll_core/mrshll/window_A.png" )
	new_text( gui, pic_x + 194, pic_y + 33, pic_z - 0.01, tm )
	uid = new_tooltip( gui, uid, { "Time Left", true_tm > 0 and true_tm or "", })
else
	gui = gui_killer( gui )
end

for i = 1,2 do
	local name = i == 1 and "left" or "right"
	local speaker = get_hooman_child( entity_id, name ) or 0
	if( speaker > 0 ) then
		local pos = { -30, 30 }
		EntitySetTransform( speaker, x + pos[i], y - 10 )
		
		local a_comp = EntityGetFirstComponentIncludingDisabled( speaker, "AudioLoopComponent" )
		if( a_comp ~= nil and not( ComponentGetIsEnabled( a_comp ))) then
			EntitySetComponentIsEnabled( speaker, a_comp, true )
		end
	end
end

song_id_table = song_id_table or {}
if( #song_id_table == 0 ) then
	mrshll = dofile( "mods/mrshll_core/mrshll_list.lua" )
	
	local ignored = access_list( storage_ignored ) or {}
	local function check( id )
		if( #ignored > 0 ) then
			for k,dud in ipairs( ignored ) do
				if( dud == id ) then
					table.remove( ignored, k )
					return false
				end
			end
		end
		
		return true
	end
	
	local fuck_this = true
	local function get_order()
		local data_raw = ComponentGetValue2( storage_ordered, "value_string" )
		if( data_raw == "@" ) then
			return {}
		end
		
		local counter = 1
		local data = {}
		for style in string.gmatch( data_raw, "([^@]+)" ) do
			data[style] = counter
			counter = counter + 1
		end
		fuck_this = false
		return data
	end
	
	local order = get_order()
	for i,cat in ipairs( mrshll ) do
		for e,song in ipairs( cat.stuff ) do
			if( check( cat.name.."_"..( song.id or song.artist_name.."_"..song.track_name ))) then
				table.insert( song_id_table, { i, e, order[ i.."_"..e ] or -1, })
			end
		end
	end
	
	if( not( fuck_this )) then
		table.sort( song_id_table, function( a, b )
			return ( a[3] > 0 and ( b[3] < 0 or a[3] < b[3]))
		end)
	end
end

if( gonna_play ) then
	for i = 1,2 do	
		local name = i == 1 and "left" or "right"
		local speaker = get_hooman_child( entity_id, name ) or 0
		if( speaker == 0 ) then
			speaker = EntityLoad( "mods/mrshll_core/mrshll/speaker.xml", x, y )
			EntitySetName( speaker, name )
			EntityAddChild( entity_id, speaker )
		end
	end

	if( is_playing == 0 ) then
		local storage_purge = get_storage( entity_id, "gonna_purge" )
		if( ComponentGetValue2( storage_purge, "value_bool" )) then
			ComponentSetValue2( storage_purge, "value_bool", false )
			switch_delay = 10
		end

		if( switch_delay == 0 and #song_id_table > 0 ) then
			if( num_override > 0 ) then
				num = num_override
				num_override = 0
			end

			num = ( num == 0 and ( random_order and generic_random( 1, #song_id_table ) or ( last_played + 1 )) or num )

			local storage_played = get_storage( entity_id, "played_songs" )
			local played_list = D_extractor( ComponentGetValue2( storage_played, "value_string" )) or {}
			if( num > #song_id_table ) then
				num = 1
				played_list = {}
			end
			if( not( force_the_same or false ) and random_order and played_list[ num ] ~= nil ) then
				local nope = true
				for i = 1,#song_id_table do
					if( played_list[ i ] == nil ) then
						nope = false
						num = i
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
			force_the_same = false
			last_played = num
			played_list[ num ] = true
			ComponentSetValue2( storage_played, "value_string", D_packer( played_list ) or "" )
			
			local song_id = song_id_table[ num ]
			local song = mrshll[ song_id[1]].stuff[ song_id[2]]
			ComponentSetValue2( get_storage( entity_id, "current_volume" ), "value_float", volume + ( song.custom_volume or 0 ))
			ComponentSetValue2( get_storage( entity_id, "sound_bank" ), "value_string", song.fmod_bank )
			ComponentSetValue2( get_storage( entity_id, "sound_event" ), "value_string", song.fmod_event )
			ComponentSetValue2( storage_delay, "value_float", song.duration + 90 )
		else
			switch_delay = switch_delay - 1
			if( switch_delay == 5 ) then
				for i = 1,2 do
					local dud = get_hooman_child( entity_id, i == 1 and "left" or "right" )
					edit_component_ultimate( dud, "AudioLoopComponent", function(comp,vars)
						ComponentSetValue2( comp, "file", "" )
						ComponentSetValue2( comp, "event_name", "" )
						ComponentSetValue2( comp, "m_volume", 0 )
						ComponentSetValue2( comp, "volume_autofade_speed", 1 )
					end)
				end
			end
		end
	end
elseif( is_playing ~= 0 ) then
	ComponentSetValue2( storage_delay, "value_float", 0 )
end