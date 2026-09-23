SMODS.Challenge {
  key = "luigi",
  jokers = {
    { id = 'j_pdem_luigi', eternal = true },
  },
  restrictions = {
    banned_cards = {
      { id = 'c_pdem_te_gate' },
    },
    banned_tags = {
      { id = 'tag_pdem_peel' },
    },
  }
}

SMODS.Challenge {
  key = "recycled",
  jokers = {
    { id = 'j_pdem_recycled_joker', eternal = true },
  },
  rules = {
    modifiers = {
      { id = 'discards', value = 8 },
      { id = 'hands', value = 3 },
    },
  },
  restrictions = {
    banned_cards = {
      { id = 'c_immolate' },
      { id = 'j_burglar' },
      { id = 'j_sixth_sense' },
      { id = 'j_trading' },

      { id = 'c_pdem_te_gate' },
      { id = 'c_justice' },
      { id = 'c_hanged_man' },
      { id = 'v_grabber' },
      { id = 'v_nacho_tong' },
    },
    banned_tags = {
      { id = 'tag_pdem_peel' },
    },
    banned_other = {
      { id = 'bl_water', type = 'blind' },
      { id = 'bl_pdem_owl', type = 'blind' },
      { id = 'bl_pdem_wick', type = 'blind' },
    },
  }
}

SMODS.Challenge {
  key = 'one_man',
  restrictions = {
    banned_other = {
      { id = 'bl_psychic', type = 'blind' },
      { id = 'bl_pillar', type = 'blind' },
      { id = 'bl_pdem_wand', type = 'blind' },
    },
  },
  deck = {
    type = 'Challenge Deck',
    cards = {{ s = 'S', r = 'A', e = 'm_bonus', g = 'Red', d = 'holo' }},
  },
}

SMODS.Challenge {
  key = 'showdown',
  rules = {
    custom = {
      { id = 'pdem_showdown_only' },
      { id = 'pdem_showdown_smaller_reward' },
    },
  }
}