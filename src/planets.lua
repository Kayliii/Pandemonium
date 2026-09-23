local config = SMODS.current_mod.config

local set_moon_badge = function (self, card, badges)
  badges[#badges + 1] = create_badge(
    localize('pdem_moon'),
    get_type_colour(card.config.center or card.config, card),
    SMODS.ConsumableTypes.Planet.text_colour,
    1.2
  )
end

SMODS.Consumable {
  key = 'void',
  set = 'Planet',
  no_collection = true,
  atlas = 'tarots',
  pos = { x = 3, y = 2 },
  cost = 3,
  config = { hand_type = 'pdem_none', softlock = true },
  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.hands[card.ability.hand_type].level,
        localize(card.ability.hand_type, 'poker_hands'),
        G.GAME.hands[card.ability.hand_type].l_mult,
        G.GAME.hands[card.ability.hand_type].l_chips,
        colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
      }
    }
  end,
  set_card_type_badge = function(self, card, badges)
    badges[#badges + 1] = create_badge(
      localize('pdem_not_a_planet'),
      get_type_colour(card.config.center or card.config, card),
      SMODS.ConsumableTypes.Planet.text_colour,
      1.2
    )
  end
}



SMODS.Consumable {
  key = 'phobos',
  set = 'Planet',
  atlas = 'tarots',
  pos = { x = 4, y = 2 },
  cost = 3,
  config = { hand_type = 'pdem_six_of_a_kind', softlock = true },
  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.hands[card.ability.hand_type].level,
        localize(card.ability.hand_type, 'poker_hands'),
        G.GAME.hands[card.ability.hand_type].l_mult,
        G.GAME.hands[card.ability.hand_type].l_chips,
        colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
      }
    }
  end,
  set_card_type_badge = set_moon_badge
}

SMODS.Consumable {
  key = 'deimos',
  set = 'Planet',
  atlas = 'tarots',
  pos = { x = 5, y = 2 },
  cost = 3,
  config = { hand_type = 'pdem_frick_of_a_kind', softlock = true },
  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.hands[card.ability.hand_type].level,
        localize(config.filter_profanity and card.ability.hand_type or 'pdem_fuck_of_a_kind', 'poker_hands'),
        G.GAME.hands[card.ability.hand_type].l_mult,
        G.GAME.hands[card.ability.hand_type].l_chips,
        colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
      }
    }
  end,
  set_card_type_badge = set_moon_badge
}

SMODS.Consumable {
  key = 'io',
  set = 'Planet',
  atlas = 'tarots',
  pos = { x = 7, y = 2 },
  cost = 3,
  config = { hand_type = 'pdem_flush_six', softlock = true },
  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.hands[card.ability.hand_type].level,
        localize(card.ability.hand_type, 'poker_hands'),
        G.GAME.hands[card.ability.hand_type].l_mult,
        G.GAME.hands[card.ability.hand_type].l_chips,
        colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
      }
    }
  end,
  set_card_type_badge = set_moon_badge
}

SMODS.Consumable {
  key = 'europa',
  set = 'Planet',
  atlas = 'tarots',
  pos = { x = 9, y = 2 },
  cost = 3,
  config = { hand_type = 'pdem_flush_frick', softlock = true },
  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.hands[card.ability.hand_type].level,
        localize(config.filter_profanity and card.ability.hand_type or 'pdem_flush_fuck', 'poker_hands'),
        G.GAME.hands[card.ability.hand_type].l_mult,
        G.GAME.hands[card.ability.hand_type].l_chips,
        colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
      }
    }
  end,
  set_card_type_badge = set_moon_badge
}

SMODS.Consumable {
  key = 'titan',
  set = 'Planet',
  atlas = 'tarots',
  pos = { x = 6, y = 2 },
  cost = 3,
  config = { hand_type = 'pdem_full_straight', softlock = true },
  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.hands[card.ability.hand_type].level,
        localize(card.ability.hand_type, 'poker_hands'),
        G.GAME.hands[card.ability.hand_type].l_mult,
        G.GAME.hands[card.ability.hand_type].l_chips,
        colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
      }
    }
  end,
  set_card_type_badge = set_moon_badge
}

SMODS.Consumable {
  key = 'triton',
  set = 'Planet',
  atlas = 'tarots',
  pos = { x = 8, y = 2 },
  cost = 3,
  config = { hand_type = 'pdem_full_straight_flush', softlock = true },
  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.hands[card.ability.hand_type].level,
        localize(card.ability.hand_type, 'poker_hands'),
        G.GAME.hands[card.ability.hand_type].l_mult,
        G.GAME.hands[card.ability.hand_type].l_chips,
        colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
      }
    }
  end,
  set_card_type_badge = set_moon_badge
}

SMODS.Consumable {
  key = 'teapot',
  set = 'Planet',
  no_collection = true,
  atlas = 'tarots',
  pos = { x = 0, y = 3 },
  cost = 3,
  config = { hand_type = 'pdem_oops_all_jokers', softlock = true },
  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.hands[card.ability.hand_type].level,
        localize(card.ability.hand_type, 'poker_hands'),
        G.GAME.hands[card.ability.hand_type].l_mult,
        G.GAME.hands[card.ability.hand_type].l_chips,
        colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
      }
    }
  end,
  set_card_type_badge = function (self, card, badges)
    badges[#badges + 1] = create_badge(
      localize('pdem_space_debris'),
      get_type_colour(card.config.center or card.config, card),
      SMODS.ConsumableTypes.Planet.text_colour,
      1.2
    )
  end
}