local bank_file = "mods/mrshll_core/mrshll.bank"

local MRSHLL_TABLE = {
	["Classical"] = {
		{
			name = "Entry of the Gladiators",
			artist = "Julius Fucik",
			fmod_bank = bank_file,
			fmod_event = "default",
			duration = 10410,
		},
	},
}

--<{> MAGICAL APPEND MARKER <}>--

for c,cat in pairs( MRSHLL_TABLE ) do
	for i,song in ipairs( cat ) do
		MRSHLL_TABLE[ c ][ i ].id = pen.key_me( song.artist.." - "..song.name )
	end
end

return MRSHLL_TABLE