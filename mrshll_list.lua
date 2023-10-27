local bank_file = "mods/mrshll_core/mrshll.bank"

local MRSHLL_TABLE = {
	{
		name = "Classical",
		stuff = {
			{
				artist_name = "Julius Fucik",
				track_name = "Entry of the Gladiators",
				fmod_bank = bank_file,
				fmod_event = "default",
				duration = 10410,
			},
		},
	},
}

function mrshll_get_category_id( name, tbl )
	tbl = tbl or MRSHLL_TABLE or {}
	
	for i,cat in ipairs( tbl ) do
		if( cat.name == name ) then
			return i
		end
	end
	
	return 0
end
function mrshll_get_song_id( bank, event, tbl )
	tbl = tbl or MRSHLL_TABLE or {}
	
	for i,cat in ipairs( tbl ) do
		for e,sng in ipairs( cat.stuff ) do
			if( sng.fmod_bank == bank and sng.fmod_event == event ) then
				return e
			end
		end
	end
	
	return 0
end

--<{> MAGICAL APPEND MARKER <}>--

return MRSHLL_TABLE