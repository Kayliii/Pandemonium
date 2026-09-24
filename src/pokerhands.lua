--------------------------------
--- Example helper functions ---
--------------------------------

local straight_order = {J = 11, T = 10, Q = 12, K = 13, A = 1}
local get_straight_example = function (n, suit_override)
  local ranks = {'J', 'T', '9', '8', '7', '6', '5', 'Q', '4', '3', 'K', 'A', '2'}
  local suits = {'D', 'C', 'C', 'S', 'H', 'S', 'S', 'D', 'H', 'H', 'H', 'C', 'S'}
  local data = {}
  for i = 1, n do
    table.insert(data, {suit_override or suits[i], ranks[i]})
  end

  table.sort(data, function (a, b)
    local orderA = tonumber(a[2])
    if not orderA then orderA = straight_order[a[2]] end
    local orderB = tonumber(b[2])
    if not orderB then orderB = straight_order[b[2]] end
    return orderA > orderB
  end)

  local ret = {}
  for i = 1, n do
    table.insert(ret, {tostring(data[i][1]) .. '_' .. tostring(data[i][2]), true})
  end
  return ret
end

local get_X_of_Y_kinds_example = function (x, y, suit_override)
  local ranks = {'T', '6', '2', 'Q', '4', '9', 'K', '3', '8', 'J', '7', '5', 'A'}
  local suits = {'C', 'S', 'D', 'C', 'S', 'H', 'S', 'D', 'H', 'H', 'H', 'C', 'S'}
  local ret = {}
  local suit_idx = 0
  for i = 1, y do
    for _ = 1, x do
      table.insert(ret, {tostring(suit_override or suits[suit_idx % #suits + 1]) .. '_' .. tostring(ranks[i]), true})
      suit_idx = suit_idx + 1
    end
  end
  return ret
end

------------------------
--- Hand definitions ---
------------------------

local config = SMODS.current_mod.config

local function PdemPokerHand (args)
  SMODS.PokerHand {
    key = args.key,
    mult = args.score.mult,
    chips = args.score.chips,
    l_mult = args.score.l_mult,
    l_chips = args.score.l_chips,
    example = args.example,
    evaluate = args.evaluate,
    no_collection = args.no_collection,
    visible = args.visible,
    modify_display_text = args.modify_display_text,
    modify_key = args.modify_key
  }
end

PdemPokerHand {
  key = 'too_many_pairs',
  score = { mult =  8, chips = 40, l_mult =  4, l_chips =  40 },
  example = get_X_of_Y_kinds_example(2, 3),
  evaluate = function (parts, hand) return pdem_get_X_of_Y_kinds(hand, 2, 3, true) end,
  visible = false,
  modify_display_text = function (self, cards, scoring_hand)
    local pair_count = #scoring_hand / 2
    return localize{ key = 'pdem_too_many_pairs', type = 'variable', vars = {get_number_text(pair_count)}}
  end
}

PdemPokerHand {
  key = 'six_of_a_kind',
  score = { mult =  18, chips =  240, l_mult =  4, l_chips =  40 },
  example = get_X_of_Y_kinds_example(6, 1),
  evaluate = function (parts, hand) return pdem_n_of_a_kind(6, hand) end,
  visible = false
}

PdemPokerHand {
  key = 'flush_six',
  score = { mult =  24, chips =  320, l_mult =  4, l_chips =  60 },
  example = get_X_of_Y_kinds_example(6, 1, 'S'),
  evaluate = function (parts, hand)
    local flushes = pdem_get_flushes(hand)
    for _, flush in ipairs(flushes) do
      local six = pdem_n_of_a_kind(6, flush)
      if next(six) then return six end
    end
    return {}
  end,
  visible = false
}

PdemPokerHand {
  key = 'frick_of_a_kind',
  modify_key = function (self)
    return config.filter_profanity and 'pdem_frick_of_a_kind' or 'pdem_fuck_of_a_kind'
  end,
  score = { mult =  25, chips =  480, l_mult =  4, l_chips =  45 },
  example = get_X_of_Y_kinds_example(7, 1),
  evaluate = function (parts, hand) return pdem_get_X_same_filtered(7, hand) end,
  visible = false,
  modify_display_text = function (self, _, scoring_hand)
    if config.filter_profanity then
      localize('pdem_frick_of_a_kind', 'dictionary')
    else
      localize('pdem_fuck_of_a_kind', 'dictionary')
    end
  end
}

PdemPokerHand {
  key = 'flush_frick',
  modify_key = function (self)
    return config.filter_profanity and 'pdem_flush_frick' or 'pdem_flush_fuck'
  end,
  score = { mult =  30, chips =  640, l_mult =  4, l_chips =  70 },
  example = get_X_of_Y_kinds_example(7, 1, 'S'),
  evaluate = function (parts, hand)
    local flushes = pdem_get_flushes(hand)
    for _, flush in ipairs(flushes) do
      local seven = pdem_get_X_same_filtered(7, flush)
      if next(seven) then return seven end
    end
    return {}
  end,
  visible = false,
  modify_display_text = function (self, _, scoring_hand)
    if config.filter_profanity then
      localize('pdem_flush_frick', 'dictionary')
    else
      localize('pdem_flush_fuck', 'dictionary')
    end
  end
}

PdemPokerHand {
  key = 'full_straight',
  visible = false,
  score = { mult = 40, chips = 300, l_mult = 5, l_chips = 300 },
  example = get_straight_example(13),
  evaluate = function (parts, hand)
    return pdem_get_full_straight(hand)
  end
}

PdemPokerHand {
  key = 'full_straight_flush',
  visible = false,
  score = { mult = 80, chips = 1000, l_mult = 10, l_chips = 300 },
  example = get_straight_example(13, 'S'),
  evaluate = function (parts, hand)
    local flushes = pdem_get_flushes(hand)
    for _, flush in ipairs(flushes) do
      local straight = pdem_get_full_straight(flush)
      if next(straight) then return straight end
    end
    return {}
  end
}


SMODS.PokerHand {
  key = 'none',
  no_collection = true,
  visible = false,
  mult = 0,
  chips = 0,
  l_mult = 1,
  l_chips = 5,
  example = {{'S_A', false},{'D_Q', false},{'D_9', false},{'C_4', false},{'D_3', false}},
  evaluate = function (parts, hand) return {{}} end
}

PdemPokerHand {
  key = 'oops_all_jokers',
  no_collection = true,
  visible = false,
  score = { mult = 2, chips = 30, l_mult = 1, l_chips = 20 },
  example = {{'pdem_JOKER_2', true},{'pdem_JOKER_3', true},{'pdem_JOKER_4', true},{'pdem_JOKER_5', true},{'pdem_JOKER_6', true}},
  evaluate = function (parts, hand)
    local jokers = {}
    for _, card in ipairs(hand) do
      if card.base.value == 'pdem_joker_rank' then
        table.insert(jokers, card)
      end
    end

    if #jokers >= 5 then
      return {jokers}
    end
  end
}