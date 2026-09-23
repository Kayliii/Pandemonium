SMODS.current_mod.optional_features = {
	retrigger_joker = true,
	post_trigger = true,
	quantum_enhancements = false,
	cardareas = {
		deck = true,
		discard = true,
	},
}

-- Assets
assert(SMODS.load_file('src/sounds.lua'))()
assert(SMODS.load_file('src/atlases.lua'))()

-- Patches
assert(SMODS.load_file('src/misc_functions.lua'))()
assert(SMODS.load_file('src/helpers.lua'))()
assert(SMODS.load_file('src/overrides.lua'))()

-- Consumables
assert(SMODS.load_file('src/planets.lua'))()
assert(SMODS.load_file('src/spectrals.lua'))()
assert(SMODS.load_file('src/teuila.lua'))()

-- Modifiers
assert(SMODS.load_file('src/stickers.lua'))()
assert(SMODS.load_file('src/seals.lua'))()

-- Vouchers
assert(SMODS.load_file('src/vouchers.lua'))()

-- Jokers
assert(SMODS.load_file('src/jokers.lua'))()

-- Decks
assert(SMODS.load_file('src/backs.lua'))()
assert(SMODS.load_file('src/challenges.lua'))()

-- Blinds
assert(SMODS.load_file('src/blinds.lua'))()

-- Hands
assert(SMODS.load_file('src/pokerhands.lua'))()

-- Misc
assert(SMODS.load_file('src/achievements.lua'))()
assert(SMODS.load_file('src/tags.lua'))()
assert(SMODS.load_file('src/suits.lua'))()

-- UI
assert(SMODS.load_file('src/ui.lua'))()
assert(SMODS.load_file('src/drawstep.lua'))()