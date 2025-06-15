local bank_file = "mods/mrshll_core/mrshll.bank"

--the tutorial (real)
--1. get all the songs you want on .ogg format (this allows for best quality at least size)
--2. rename all the tracks to a uniform standard (so, for Phantom Pack, I had filenames like "phantom05.ogg")
--3. separate every single track into their left and right channels (filename should be "phantom05_l.ogg" and "phantom05_r.ogg")
--4. download FMOD 2.01.05
--[WIP] 5. download the starting project (it contains templates for both the extension mod and fmod project)
--6. make sure to copy the event so guids get generated
--7. add compression to tracks
--8. make sure to leave plenty of empty space in the loop, as a safety measure
--9. add distance condition
--10. it is highly recommended to balance all the music audio by manually comparing their levels and adjusting the gains accordingly
--11. setup the table (names + events + duration in seconds *60 to convert to frames)
--12. export fmod bank and guids
--13. upload to workshop

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