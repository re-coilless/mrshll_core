if( ModSettingGetNextValue( "mrshll_core.ITEM_INIT" ) == 3 ) then
	table.insert( APPLETS.l, {
		name = "HermeS Marshall", desc = "Toggle record player GUI.",
		pic = "mods/mrshll_core/mrshll/item.png", off_x = 0, off_y = 0,
		toggle = function( state )
			if( not( state )) then return end
			local storage_open = pen.magic_storage( index_mrshll_id, "is_open" )
			ComponentSetValue2( storage_open, "value_bool", not( ComponentGetValue2( storage_open, "value_bool" )))
		end,
	})
end

GUI_STRUCT.custom.mrshll_core = function( screen_w, screen_h, xys )
	index_mrshll_id = EntityGetWithName( "mrshll_ctrl" )
	dofile( "mods/mrshll_core/mrshll/controller.lua" )
	return pen.t.pack( pen.setting_get( "mrshll_core.UI_POS" ))
end