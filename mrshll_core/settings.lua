dofile( "data/scripts/lib/mod_settings.lua" )

function mod_setting_custom_enum( mod_id, gui, in_main_menu, im_id, setting )
	local value = ModSettingGetNextValue( mod_setting_get_id( mod_id, setting ))
	local text = setting.ui_name .. ": " .. setting.values[ value ]
	
	local clicked,right_clicked = GuiButton( gui, im_id, mod_setting_group_x_offset, 0, text )
	if clicked then
		value = value + 1
		if( value > #setting.values ) then
			value = 1
		end
		ModSettingSetNextValue( mod_setting_get_id( mod_id,setting ), value, false )
	end
	if right_clicked and setting.value_default then
		ModSettingSetNextValue( mod_setting_get_id( mod_id, setting ), setting.value_default, false )
	end
	
	local tips = {
		"An item will be handed to you on game start.",
		"An item will be placed near you on game start.",
		"An implant will be injected directly into your skull on game start.\nAccess it via the button at the top left corner.",
		"Manual control rights will be revoked.",
	}
	setting.ui_description = setting.ui_desc_default.."\n"..tips[value]
	mod_setting_tooltip( mod_id, gui, in_main_menu, setting )
end

local mod_id = "mrshll_core"
mod_settings_version = 1
mod_settings = 
{
	{
		id = "AUTOPLAY",
		ui_name = "Play on Start",
		ui_description = "Automatically presses the play button on game boot.",
		hidden = false,
		value_default = false,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id = "ITEM_INIT",
		ui_name = "Hardware Injection Method",
		ui_desc_default = "Changes the way the ui is accessed.",
		hidden = false,
		value_default = 1,
		values = { "Insert in Inventory", "Free Spawn", "Surgical Implantation", "NONE" },
		scope = MOD_SETTING_SCOPE_RUNTIME,
		ui_fn = mod_setting_custom_enum,
	},
	{
		id = "NO_DRAGGER",
		ui_name = "Hide the Dragged",
		ui_description = "Removes the button that allows one to reposition the UI.",
		hidden = false,
		value_default = true,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id = "VOLUME",
		ui_name = "Volume",
		ui_description = "",
		hidden = true,
		value_default = 0.8,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id = "IS_SHUFFLED",
		ui_name = "Is Shuffled",
		ui_description = "",
		hidden = true,
		value_default = true,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id = "PLAYLIST_NUM",
		ui_name = "Playlist Num",
		ui_description = "",
		hidden = true,
		value_default = 1,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id = "UI_POS",
		ui_name = "Position",
		ui_description = "",
		hidden = true,
		value_default = "|5|42|",
		text_max_length = 100000,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id = "IGNORE_LIST",
		ui_name = "Songs",
		ui_description = "",
		hidden = true,
		value_default = "",
		text_max_length = 100000,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id = "ORDER_LIST",
		ui_name = "Songs",
		ui_description = "",
		hidden = true,
		value_default = "",
		text_max_length = 100000,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
}

function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id )
	mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end