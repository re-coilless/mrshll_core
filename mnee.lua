_BINDINGS[ "mrshll_core" ] = {
	["play"] = {
		order_id = "a",
		
		name = "Play/Stop",
		desc = "Toggle current song playback.",
		
		keys = {["keypad_enter"]=1},
	},
    ["next"] = {
		order_id = "b",
		
		name = "Next Track",
		desc = "Skip to the next track.",
		
		keys = {["keypad_."]=1},
	},
    ["volume_up"] = {
		order_id = "c",
		
		name = "Volume Up",
		desc = "Increase playback amplitude.",
		
		keys = {["keypad_+"]=1},
	},
    ["volume_down"] = {
		order_id = "d",
		
		name = "Volume Down",
		desc = "Decrease playback amplitude.",
		
		keys = {["keypad_-"]=1},
	},
    ["shuffle"] = {
		order_id = "e",
		
		name = "Shuffle/Ordered",
		desc = "Toggle playback queue mode.",
		
		keys = {["keypad_*"]=1},
	},
    ["playlist_next"] = {
		order_id = "f",
		
		name = "Next Playlist",
		desc = "Cycles playlists to the following one.",
		
		keys = {["keypad_2"]=1},
	},
    ["playlist_last"] = {
		order_id = "g",
		
		name = "Previous Playlist",
		desc = "Cycles playlists to the last one.",
		
		keys = {["keypad_1"]=1},
	},
}