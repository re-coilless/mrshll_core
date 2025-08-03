_MNEEDATA[ "mrshll_core" ] = {
	order_id = 1.2,
	name = "HermeS Marshall",
	desc = "Hotkeys for your mp3 player.",
}

_BINDINGS[ "mrshll_core" ] = {
	["play"] = {
		order_id = "a",
		is_weak = true,
		name = "$mrshll_mnee_play",
		desc = "$mrshll_mnee_play_",
		keys = {["keypad_enter"] = 1 },
	},
    ["next"] = {
		order_id = "b",
		is_weak = true,
		name = "$mrshll_mnee_next",
		desc = "$mrshll_mnee_next_",
		keys = {["keypad_."] = 1 },
	},
    ["volume_up"] = {
		order_id = "c",
		is_weak = true,
		name = "$mrshll_mnee_volume_a",
		desc = "$mrshll_mnee_volume_a_",
		keys = {["keypad_+"] = 1 },
	},
    ["volume_down"] = {
		order_id = "d",
		is_weak = true,
		name = "$mrshll_mnee_volume_b",
		desc = "$mrshll_mnee_volume_b_",
		keys = {["keypad_-"] = 1 },
	},
    ["shuffle"] = {
		order_id = "e",
		is_weak = true,
		name = "$mrshll_mnee_shuffle",
		desc = "$mrshll_mnee_shuffle_",
		keys = {["keypad_*"] = 1 },
	},
}