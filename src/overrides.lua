local config = SMODS.current_mod.config

-- I don't think I can Lovely-patch an SMODS override unfortunately.
function G.FUNCS.get_poker_hand_info(_cards)
  local poker_hands = evaluate_poker_hand(_cards)
  local scoring_hand = {}
  local text, disp_text, loc_disp_text = 'NULL', 'NULL', 'NULL'
  for _, v in ipairs(G.handlist) do
    if next(poker_hands[v]) then
      text = v
      scoring_hand = poker_hands[v][1]
      break
    end
  end
  disp_text = text
  local _hand = SMODS.PokerHands[text]
  if _hand and _hand.modify_display_text and type(_hand.modify_display_text) == 'function' then
    disp_text = _hand:modify_display_text(_cards, scoring_hand) or disp_text
  end
  local flags = SMODS.calculate_context({ evaluate_poker_hand = true, full_hand = _cards, scoring_hand = scoring_hand, scoring_name =
  text, poker_hands = poker_hands, display_name = disp_text })
  text = flags.replace_scoring_name or text
  disp_text = flags.replace_display_name or flags.replace_scoring_name or disp_text
  poker_hands = flags.replace_poker_hands or poker_hands
  loc_disp_text = localize(disp_text, 'poker_hands')
  loc_disp_text = loc_disp_text == 'ERROR' and disp_text or loc_disp_text
  return text, loc_disp_text, poker_hands, scoring_hand, disp_text
end

-- Implement the Showdown Only custom rule
local is_showdown_ante = SMODS.is_showdown_ante
function SMODS.is_showdown_ante()
  return G.GAME.modifiers.pdem_showdown_only or is_showdown_ante()
end


-- Allow limiting joker activations by Ebony Rose
local calculate_joker_old = Card.calculate_joker
function Card.calculate_joker(self, context)
  local serializableId = pdem_get_unique_card_id(self)
  if G.GAME.blind.name == 'bl_pdem_rose' and not G.GAME.blind.disabled then
    if not G.GAME.blind.effect.pdem_tracked_jokers then
      G.GAME.blind.effect.pdem_tracked_jokers = {}
      G.GAME.blind.effect.pdem_tracked_jokers_trusted = {}
    end
    if G.GAME.blind.effect.pdem_tracked_jokers[serializableId] and not G.GAME.blind.effect.pdem_tracked_jokers_trusted[serializableId] then
      -- Prevent activation; don't trust jokers not to have side effects.
      return nil
    end
    context.pdem_ebony_rose_blocking_activation = not not G.GAME.blind.effect.pdem_tracked_jokers[serializableId]
    local result = calculate_joker_old(self, context)
    if result and result.pdem_ebony_rose_activated then
      if result.effect ~= false then
        G.GAME.blind.effect.pdem_tracked_jokers[serializableId] = true
        G.E_MANAGER:add_event(Event({
          trigger = 'immediate',
          func = function()
            G.GAME.blind:juice_up()
            return true
          end
        }))
      end
    end
    if result and result.ignore_ebony_rose then
      G.GAME.blind.effect.pdem_tracked_jokers_trusted[serializableId] = true
    end
    if result and not result.ignore_ebony_rose then
      if
        result.mult_mod ~= nil or result.chip_mod ~= nil or
        result.x_mult_mod ~= nil or result.x_chip_mod ~= nil or
        result.mult ~= nil or result.chips ~= nil or
        result.xmult ~= nil or result.xchips ~= nil or
        result.blindsize ~= nil or result.xblindsize ~= nil or
        result.dollars ~= nil or
        result.swap or result.balance or
        result.level_up or result.level_up_hand or
        result.saved or
        result.card or
        result.effect
      then
        if result.repetitions ~= nil then
          result.repetitions = 1
        end
        --[[
          You *can* return `{ effect = false }` to ignore Ebony Rose.
          But you must do it on all activations. Once you return an effect
          once, all further activations are blocked indiscriminately.
        ]]
        if result.effect ~= false then
          G.GAME.blind.effect.pdem_tracked_jokers[serializableId] = true
          G.E_MANAGER:add_event(Event({
          trigger = 'immediate',
          func = function()
            G.GAME.blind:juice_up()
            return true
          end
        }))
        end
      end
    end
    return result
  end
  return calculate_joker_old(self, context)
end


local function get_modded_probability (base_numerator, base_denominator, numerator, denominator, numerator_prng, denominator_prng)
  local numerator_multiplier =
    base_numerator ~= 0 and numerator / base_numerator or
    numerator ~= 0 and 1e7 or 0

  local denominator_multiplier = denominator / base_denominator
  local epsilon = 1e-5

  local modded_numerator_prng = 2 * numerator_prng / (numerator_prng + 1)
  local modded_denominator_prng = 1 - 1.05 * denominator_prng / (denominator_prng + 0.05)

  local denominator_mod = 1 / pdem_clamp(epsilon, modded_denominator_prng, 1 - epsilon) - 1
  local numerator_mod = base_numerator >= 0
    and modded_numerator_prng ^ -math.log(base_numerator / base_denominator, 2)
    or -modded_numerator_prng ^ -math.log(-base_numerator / base_denominator, 2)
  
  local new_denominator = pdem_clamp(1, math.floor(base_denominator * denominator_mod), 1e7)
  local new_numerator = math.floor(numerator_mod * (new_denominator))

  return
    pdem_clamp(-1e7, math.floor(new_numerator * numerator_multiplier + 0.5), 1e7),
    pdem_clamp(-1e7, math.floor(new_denominator * denominator_multiplier + 0.5), 1e7)
end

local get_probability_vars_old = SMODS.get_probability_vars
function SMODS.get_probability_vars (trigger_obj, base_numerator, base_denominator, identifier, from_roll, no_mod)
  if no_mod or not G.jokers then
    if trigger_obj and trigger_obj.label == 'j_pdem_oops_random' then
      -- Ensure it works in the collection
      return get_modded_probability(
        base_numerator, base_denominator,
        base_numerator, base_denominator,
        pseudorandom('pdem_collection'), pseudorandom('pdem_collection')
      )
    else
      return base_numerator, base_denominator  
    end
  end

  -- Implement Oops! All 3s
  local oops_3 = SMODS.find_card('j_pdem_oops_3s')
  if next(oops_3) then
    base_numerator = 1
    base_denominator = 3
    trigger_obj = oops_3[#oops_3]
    identifier = 'j_pdem_oops_3s'
  end

  local numerator, denominator = get_probability_vars_old(trigger_obj, base_numerator, base_denominator, identifier, from_roll, no_mod)

  if from_roll and numerator > denominator then
    check_for_unlock{ type = 'pdem_odds_over_1' }
  end

  -- Implement Oops! All Random
  local key_num = 'pdem_oops_random_odds_num_' .. identifier
  local key_denom = 'pdem_oops_random_odds_denom_' .. identifier
  if trigger_obj then
    if trigger_obj.ability then
      if trigger_obj.ability[key_num] then
        return get_modded_probability(
          base_numerator, base_denominator,
          numerator, denominator,
          trigger_obj.ability[key_num], trigger_obj.ability[key_denom]
        )
      elseif trigger_obj.label == 'j_pdem_oops_random' then
        -- Ensure it always randomizes its own description
        return get_modded_probability(
          base_numerator, base_denominator,
          numerator, denominator,
          pseudorandom('pdem_collection'), pseudorandom('pdem_collection')
        )
      end
    elseif trigger_obj.effect and trigger_obj.effect[key_num] then
      -- Not sure if/when this happens, but...
      return get_modded_probability(
        base_numerator, base_denominator,
        numerator, denominator,
        trigger_obj.effect[key_num], trigger_obj.effect[key_denom]
      )
    elseif next(SMODS.find_card('j_pdem_oops_random')) then
      -- For things like blinds.
      pdem_ensure_oops_random_table()
      if not G.GAME.pdem_oops_random_num[identifier] then
        local prng_key = 'pdem_oops_random_' .. identifier
        G.GAME.pdem_oops_random_num[identifier] = pseudorandom(prng_key)
        G.GAME.pdem_oops_random_denom[identifier] = pseudorandom(prng_key)
      end
      if G.GAME.pdem_oops_random_num[identifier] then
        return get_modded_probability(
          base_numerator, base_denominator,
          numerator, denominator,
          G.GAME.pdem_oops_random_num[identifier],
          G.GAME.pdem_oops_random_denom[identifier]
        )
      end
    end
  elseif next(SMODS.find_card('j_pdem_oops_random')) then
    -- Ensure it works in tooltips
    return get_modded_probability(
        base_numerator, base_denominator,
        numerator, denominator,
        pseudorandom('pdem_tooltips'), pseudorandom('pdem_tooltips')
      )
  end
  return numerator, denominator
end


SMODS.PokerHand:take_ownership('High Card', {
  evaluate = function (parts, hand) return pdem_n_of_a_kind(1, hand) end
}, true)

SMODS.PokerHand:take_ownership('Pair', {
  evaluate = function (parts, hand) return pdem_n_of_a_kind(2, hand) end
}, true)

SMODS.PokerHand:take_ownership('Three of a Kind', {
  evaluate = function (parts, hand) return pdem_n_of_a_kind(3, hand) end
}, true)

SMODS.PokerHand:take_ownership('Four of a Kind', {
  evaluate = function (parts, hand) return pdem_n_of_a_kind(4, hand) end
}, true)

SMODS.PokerHand:take_ownership('Five of a Kind', {
  evaluate = function (parts, hand) return pdem_n_of_a_kind(5, hand) end
})

SMODS.PokerHand:take_ownership('Full House', {
  evaluate = function (parts, hand) return pdem_get_full_house(hand) end
})

SMODS.PokerHand:take_ownership('Flush House', {
  evaluate = function (parts, hand)
    local flushes = pdem_get_flushes(hand)
    for _, flush in ipairs(flushes) do
      local full_house = pdem_get_full_house(flush)
      if next(full_house) then return full_house end
    end
    return {}
  end,
  modify_display_text = function (self, cards, scoring_hand)
    return localize{ key = 'pdem_flush_house_plus', type = 'variable', vars = {
      string.rep(localize('pdem_flush_house_plus_char', 'dictionary'), #scoring_hand - SMODS.four_fingers('straight')),
    }}
  end
})

SMODS.PokerHand:take_ownership('Flush Five', {
  evaluate = function (parts, hand)
    local flushes = pdem_get_flushes(hand)
    for _, flush in ipairs(flushes) do
      local five = pdem_n_of_a_kind(5, flush)
      if next(five) then return five end
    end
    return {}
  end
})

SMODS.PokerHand:take_ownership('Straight Flush', {
  evaluate = function (parts, hand)
    local flushes = pdem_get_flushes(hand)
    for _, flush in ipairs(flushes) do
      local straight = get_straight(flush, SMODS.four_fingers('straight'), SMODS.shortcut(), SMODS.wrap_around_straight())
      if next(straight) then return straight end
    end
    return {}
  end,
  modify_display_text = function (self, cards, scoring_hand)
    local royals = 0
    for j = 1, #scoring_hand do
      local rank = SMODS.Ranks[scoring_hand[j].base.value]
      if rank.key == 'Ace' or rank.key == '10' or rank.face then royals = royals + 1 end
    end
    if royals >= SMODS.four_fingers('straight') then
      return localize{ key = 'pdem_royal_flush_plus', type = 'variable', vars = {
        string.rep(localize('pdem_straight_flush_plus_char_3', 'dictionary'), #scoring_hand - SMODS.four_fingers('flush'))
      }}
    else
      return localize{ key = 'pdem_straight_flush_plus', type = 'variable', vars = {
        string.rep(localize('pdem_straight_flush_plus_char_1', 'dictionary'), #scoring_hand - SMODS.four_fingers('straight')),
        string.rep(localize('pdem_straight_flush_plus_char_2', 'dictionary'), #scoring_hand - SMODS.four_fingers('flush'))
      }}
    end
  end
})

SMODS.PokerHand:take_ownership('Straight', {
  modify_display_text = function (self, cards, scoring_hand)
    return localize{ key = 'pdem_straight_plus', type = 'variable', vars = {
      string.rep(localize('pdem_straight_plus_char', 'dictionary'), #scoring_hand - SMODS.four_fingers('straight'))
    }}
  end
})

SMODS.PokerHand:take_ownership('Flush', {
  modify_display_text = function (self, cards, scoring_hand)
    return localize{ key = 'pdem_flush_plus', type = 'variable', vars = {
      string.rep(localize('pdem_flush_plus_char', 'dictionary'), #scoring_hand - SMODS.four_fingers('flush'))
    }}
  end
})


-- Monkey patch the score card function for lucky card tracking
local score_card_old = SMODS.score_card
function SMODS.score_card (card, ...)
  local res = score_card_old(card, ...)
  if card.pdem_lucky_money and card.pdem_lucky_mult then
    check_for_unlock({ type = 'pdem_lucky_both' })
  end
  card.pdem_lucky_money = nil
  card.pdem_lucky_mult = nil
  return res
end

-- Allow Gold Star stickers to show up in Red Stake.
local red_stake = SMODS.Stakes['stake_red']
local red_stake_modifiers_old = red_stake.modifiers
local red_stake_loc_vars_old = red_stake.loc_vars or function () end
SMODS.Stake:take_ownership('stake_red', {
  modifiers = function ()
    red_stake_modifiers_old()
    G.GAME.modifiers.enable_pdem_gold_star = true
  end,
  loc_vars = function(self, info_queue, card)
    red_stake_loc_vars_old(self, info_queue, card)
    info_queue[#info_queue + 1] = { set = 'Other', key = 'pdem_gold_star' }
  end
})

--------------------------------------------
-- Ban new stuff from existing challenges --
--------------------------------------------

local function ban_tags (challenge, tags)
  local c = SMODS.Challenges['c_' .. challenge]
  for _, tag in ipairs(tags) do
    c.restrictions.banned_tags[#c.restrictions.banned_tags + 1] = tag
  end
end

local function ban_cards (challenge, cards)
  local c = SMODS.Challenges['c_' .. challenge]
  for _, card in ipairs(cards) do
    c.restrictions.banned_cards[#c.restrictions.banned_cards + 1] = card
  end
end

local function ban_other (challenge, others)
  local c = SMODS.Challenges['c_' .. challenge]
  for _, other in ipairs(others) do
    c.restrictions.banned_other[#c.restrictions.banned_other + 1] = other
  end
end

for _, key in ipairs({'non_perishable_1','mad_world_1', 'monolith_1', 'fragile_1', 'medusa_1', 'blast_off_1', 'knife_1', 'bram_poker_1', 'city_1', 'typecast_1'}) do
  ban_tags(key, {{ id = 'tag_pdem_peel' }})
  ban_cards(key, {{ id = 'c_pdem_te_gate' }})
end

ban_cards('knife_1', {
  { id = 'c_pdem_te_laurel' },
})

ban_cards('xray_1', {
  { id = 'j_pdem_oops_0s' },
  { id = 'j_pdem_oops_1s' },
  { id = 'j_pdem_oops_random' },
})

ban_cards('fragile_1', {
  { id = 'j_pdem_oops_0s' },
  { id = 'j_pdem_oops_1s' },
  { id = 'j_pdem_oops_3s' },
  { id = 'j_pdem_oops_random' },
})

ban_other('blast_off_1', {
  { id = 'bl_pdem_owl', type = 'blind' },
  { id = 'bl_pdem_wick', type = 'blind' },
})

ban_other('golden_needle_1', {
  { id = 'bl_pdem_owl', type = 'blind' },
  { id = 'bl_pdem_wick', type = 'blind' },
})

ban_other('jokerless_1', {
  { id = 'bl_pdem_rose', type = 'blind' },
})

----------------------
--- Card Overrides ---
----------------------

---@see SMODS.has_no_rank as well
Card.pdem_is_rank = function (self, rank, bypass_debuff)
  if self.debuff and not bypass_debuff then return end
  return self.base.value == rank or self.config.center.config['pdem_is_rank_'..rank]
end

local card_is_face = Card.is_face
Card.is_face = function (self, from_boss)
  return card_is_face(self, from_boss) or self.config.center.config.pdem_is_face_card
end

local card_is_suit = Card.is_suit
Card.is_suit = function (self, suit, bypass_debuff, flush_calc)
  if self.config.center.config['pdem_is_'..suit] then
    if self.debuff and not bypass_debuff then return end
    if SMODS.has_no_suit(self) then return false end
    return true
  end
  return card_is_suit(self, suit, bypass_debuff, flush_calc)
end

local face_jokers = {'j_joker', 'j_greedy_joker', 'j_lusty_joker', 'j_wrathful_joker', 'j_gluttenous_joker', 'j_jolly', 'j_zany', 'j_mad', 'j_crazy', 'j_droll', 'j_sly', 'j_wily', 'j_clever', 'j_devious', 'j_crafty', 'j_half', 'j_mime', 'j_misprint', 'j_chaos', 'j_scary_face', 'j_pareidolia', 'j_even_steven', 'j_odd_todd', 'j_scholar', 'j_space', 'j_egg', 'j_burglar', 'j_blackboard', 'j_runner', 'j_blue_joker', 'j_sixth_sense', 'j_constellation', 'j_hiker', 'j_green_joker', 'j_card_sharp', 'j_madness', 'j_square', 'j_riff_raff', 'j_vampire', 'j_hologram', 'j_vagabond', 'j_baron', 'j_midas_mask', 'j_luchador', 'j_photograph', 'j_hallucination', 'j_fortune_teller', 'j_juggler', 'j_drunkard', 'j_stone', 'j_golden', 'j_lucky_cat', 'j_baseball', 'j_bull', 'j_trading', 'j_flash','j_smiley', 'j_mr_bones', 'j_sock_and_buskin', 'j_swashbuckler', 'j_troubadour', 'j_smeared', 'j_throwback', 'j_glass', 'j_ring_master', 'j_blueprint', 'j_wee', 'j_merry_andy', 'j_idol', 'j_matador', 'j_stuntman', 'j_brainstorm', 'j_shoot_the_moon', 'j_drivers_license', 'j_cartomancer', 'j_astronomer', 'j_burnt', 'j_caino', 'j_triboulet', 'j_yorick', 'j_chicot', 'j_perkeo', 'j_hack'}
local diamond_jokers = {'j_greedy_joker', 'j_smeared', 'j_rough_gem', 'j_flower_pot'}
local heart_jokers = {'j_lusty_joker', 'j_smeared', 'j_bloodstone', 'j_flower_pot'}
local spade_jokers = {'j_wrathful_joker', 'j_blackboard', 'j_smeared', 'j_arrowhead', 'j_flower_pot'}
local club_jokers = {'j_gluttenous_joker', 'j_blackboard', 'j_smeared', 'j_onyx_agate', 'j_flower_pot', 'j_seeing_double'}

local rank_A_jokers = {'j_scholar', 'j_superposition'}
local rank_2_jokers = {'j_duo', 'j_sly', 'j_jolly'}
local rank_3_jokers = {'j_trio', 'j_wily', 'j_zany'}
local rank_4_jokers = {'j_four_fingers', 'j_family', 'j_clever', 'j_mad'}
local rank_5_jokers = {'j_order', 'j_tribe', 'j_crafty', 'j_devious', 'j_droll', 'j_crazy'}
local rank_6_jokers = {'j_oops'}
local rank_7_jokers = {}
local rank_8_jokers = {'j_8_ball'}
local rank_9_jokers = {'j_cloud_9'}
local rank_T_jokers = {}
local rank_J_jokers = {'j_flash'}
local rank_Q_jokers = {'j_shoot_the_moon'}
local rank_K_jokers = {'j_baron'}


for _, j in ipairs(face_jokers) do
  SMODS.Joker:get_obj(j).config.pdem_is_face_card = true
end

for _, j in ipairs(diamond_jokers) do
  SMODS.Joker:get_obj(j).config.pdem_is_Diamonds = true
end

for _, j in ipairs(heart_jokers) do
  SMODS.Joker:get_obj(j).config.pdem_is_Hearts = true
end

for _, j in ipairs(spade_jokers) do
  SMODS.Joker:get_obj(j).config.pdem_is_Spades = true
end

for _, j in ipairs(club_jokers) do
  SMODS.Joker:get_obj(j).config.pdem_is_Clubs = true
end

local joker_ranks = {
  Ace = rank_A_jokers,
  [2] = rank_2_jokers,
  [3] = rank_3_jokers,
  [4] = rank_4_jokers,
  [5] = rank_5_jokers,
  [6] = rank_6_jokers,
  [7] = rank_7_jokers,
  [8] = rank_8_jokers,
  [9] = rank_9_jokers,
  [10] = rank_T_jokers,
  Jack = rank_J_jokers,
  Queen = rank_Q_jokers,
  King = rank_K_jokers,
}

for key, list in pairs(joker_ranks) do
  for _, j in ipairs(list) do
    SMODS.Joker:get_obj(j).config['pdem_is_rank_'..key] = true
  end
end

local get_card_areas = SMODS.get_card_areas
SMODS.get_card_areas = function (_type, _context)
  local card_areas = get_card_areas(_type, _context)
  if _type == 'jokers' then
    table.insert(card_areas, G.play)
    table.insert(card_areas, G.hand)
  end
  return card_areas
end

-----------------------
--- Main Menu Stuff ---
-----------------------

G.C.PDEM_MENU_COL = HEX('f889e9')
--f349dc
local main_menu_old = Game.main_menu
Game.main_menu = function (change_context)
  local result = main_menu_old(change_context)

  if not config['custom_menu'] then return result end

  local devil_card = Card(
    G.title_top.T.x,
    G.title_top.T.y,
    G.CARD_W,
    G.CARD_H,
    G.P_CARDS.empty,
    G.P_CENTERS.c_devil,
    { bypass_discovery_center = true }
  )

  G.title_top.T.w = G.title_top.T.w * 1.7675
  G.title_top.T.x = G.title_top.T.x - 0.8
  G.title_top:emplace(devil_card)

  -- Devil on the left
  local a = G.title_top.cards[1]
  G.title_top.cards[1] = G.title_top.cards[2]
  G.title_top.cards[2] = a

  devil_card.T.w = devil_card.T.w * 1.1 * 1.2
  devil_card.T.h = devil_card.T.h * 1.1 * 1.2
  devil_card.no_ui = true
  devil_card.states.visible = false

  -- make the title screen use different background colors
  G.SPLASH_BACK:define_draw_steps({
    {
      shader = "splash",
      send = {
        { name = "time", ref_table = G.TIMERS, ref_value = "REAL_SHADER" },
        { name = "vort_speed", val = 0.4 },
        { name = "colour_1", ref_table = G.C, ref_value = "RED" },
        { name = "colour_2", ref_table = G.C, ref_value = "PDEM_MENU_COL" },
      },
    },
  })

  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0,
    blockable = false,
    blocking = false,
    func = function()
      if change_context == 'splash' then
        devil_card.states.visible = true
        devil_card:start_materialize({ G.C.WHITE, G.C.WHITE }, true, 2.5)
      else
        devil_card.states.visible = true
        devil_card:start_materialize({ G.C.WHITE, G.C.WHITE }, nil, 1.2)
      end
      return true
    end,
  }))
  return result
end




--------------------
--- Deck Preview ---
--------------------

local view_deck_unplayed_only = nil
local function tally_cards ()
  remove_nils(G.playing_cards)
  G.VIEWING_DECK = true
  table.sort(G.playing_cards, function(a, b) return a:get_nominal('suit') > b:get_nominal('suit') end)
  local SUITS = {}
  local suit_map = {}
  for i = #SMODS.Suit.obj_buffer, 1, -1 do
    SUITS[SMODS.Suit.obj_buffer[i]] = {}
    suit_map[#suit_map + 1] = SMODS.Suit.obj_buffer[i]
  end
  for k, v in ipairs(G.playing_cards) do
    if v.base.suit then table.insert(SUITS[v.base.suit], v) end
  end
  local num_suits = 0
  for j = 1, #suit_map do
    if SUITS[suit_map[j]][1] then num_suits = num_suits + 1 end
  end

  local visible_suit = {}
  for j = 1, #suit_map do
    if SUITS[suit_map[j]][1] then
      table.insert(visible_suit, suit_map[j])
    end
  end

  local flip_col = G.C.WHITE

  local suit_tallies = {}
  local mod_suit_tallies = {}
  for _, v in ipairs(suit_map) do
    suit_tallies[v] = 0
    mod_suit_tallies[v] = 0
  end
  local rank_tallies = {}
  local mod_rank_tallies = {}
  local rank_name_mapping = SMODS.Rank.obj_buffer
  for _, v in ipairs(rank_name_mapping) do
    rank_tallies[v] = 0
    mod_rank_tallies[v] = 0
  end
  local face_tally = 0
  local mod_face_tally = 0
  local num_tally = 0
  local mod_num_tally = 0
  local ace_tally = 0
  local mod_ace_tally = 0
  local wheel_flipped = 0

  for k, v in ipairs(G.playing_cards) do
    if v.ability.name ~= 'Stone Card' and v.base.value == 'pdem_joker_rank' and (not view_deck_unplayed_only or ((v.area and v.area == G.deck) or v.ability.wheel_flipped)) then
      if v.ability.wheel_flipped and not (v.area and v.area == G.deck) and view_deck_unplayed_only then wheel_flipped = wheel_flipped + 1 end
      local v_nr, v_ns = SMODS.has_no_rank(v), SMODS.has_no_suit(v)

      -- Handle the suits
      if v.base.suit and not v_ns then suit_tallies[v.base.suit] = (suit_tallies[v.base.suit] or 0) + 1 end
      for kk, vv in pairs(mod_suit_tallies) do
        mod_suit_tallies[kk] = (vv or 0) + (v:is_suit(kk) and 1 or 0)
      end

      -- Handle faces
      if v.base.value and not v_nr then face_tally = face_tally + ((SMODS.Ranks[v.base.value].face) and 1 or 0) end
      mod_face_tally = mod_face_tally + (v:is_face() and 1 or 0)

      --ranks
      if v.base.value and not v_nr then rank_tallies[v.base.value] = rank_tallies[v.base.value] + 1 end
      if v.base.value and not v_nr and not v.debuff then mod_rank_tallies[v.base.value] = mod_rank_tallies[v.base.value] + 1 end

      -- Handle aces
      if v.config.center.config.pdem_is_rank_Ace then
        if not v.debuff then mod_ace_tally = mod_ace_tally + 1 end

        if not v.debuff then mod_rank_tallies.Ace = mod_rank_tallies.Ace + 1 end
      end

      -- Handle numbers
      for rank = 2, 10 do
        if v.config.center.config['pdem_is_rank_'..rank] then
          if not v.debuff then mod_num_tally = mod_num_tally + 1 end

          local rank_key = tostring(rank)
          if not v.debuff then mod_rank_tallies[rank_key] = mod_rank_tallies[rank_key] + 1 end
        end
      end

      -- Handle_faces
      for _, rank in ipairs({'Jack', 'Queen', 'King'}) do
        if v.config.center.config['pdem_is_rank_'..rank] then
          if not v.debuff then mod_num_tally = mod_num_tally + 1 end

          if not v.debuff then mod_rank_tallies[rank] = mod_rank_tallies[rank] + 1 end
        end
      end
    elseif v.ability.name ~= 'Stone Card' and (not view_deck_unplayed_only or ((v.area and v.area == G.deck) or v.ability.wheel_flipped)) then
      if v.ability.wheel_flipped and not (v.area and v.area == G.deck) and view_deck_unplayed_only then wheel_flipped = wheel_flipped + 1 end
      local v_nr, v_ns = SMODS.has_no_rank(v), SMODS.has_no_suit(v)
      --For the suits
      if v.base.suit and not v_ns then suit_tallies[v.base.suit] = (suit_tallies[v.base.suit] or 0) + 1 end
      for kk, vv in pairs(mod_suit_tallies) do
        mod_suit_tallies[kk] = (vv or 0) + (v:is_suit(kk) and 1 or 0)
      end

      --for face cards/numbered cards/aces
      local card_id = v:get_id()
      if v.base.value and not v_nr then face_tally = face_tally + ((SMODS.Ranks[v.base.value].face) and 1 or 0) end
      mod_face_tally = mod_face_tally + (v:is_face() and 1 or 0)
      if v.base.value and not v_nr and not SMODS.Ranks[v.base.value].face and card_id ~= 14 then
        num_tally = num_tally + 1
        if not v.debuff then mod_num_tally = mod_num_tally + 1 end
      end
      if card_id == 14 then
        ace_tally = ace_tally + 1
        if not v.debuff then mod_ace_tally = mod_ace_tally + 1 end
      end

      --ranks
      if v.base.value and not v_nr then rank_tallies[v.base.value] = rank_tallies[v.base.value] + 1 end
      if v.base.value and not v_nr and not v.debuff then mod_rank_tallies[v.base.value] = mod_rank_tallies[v.base.value] + 1 end
    end
  end

  local modded = face_tally ~= mod_face_tally
  for kk, vv in pairs(mod_suit_tallies) do
    modded = modded or (vv ~= suit_tallies[kk])
    if modded then break end
  end

  if wheel_flipped > 0 then flip_col = mix_colours(G.C.FILTER, G.C.WHITE, 0.7) end

  local ret = {
    suit_tallies = suit_tallies,
    mod_suit_tallies = mod_suit_tallies,
    rank_tallies = rank_tallies,
    mod_rank_tallies = mod_rank_tallies,
    face_tally = face_tally,
    mod_face_tally = mod_face_tally,
    num_tally = num_tally,
    mod_num_tally = mod_num_tally,
    ace_tally = ace_tally,
    mod_ace_tally = mod_ace_tally,
    wheel_flipped = wheel_flipped,
    flip_col = flip_col,
    modded = modded,
    visible_suit = visible_suit,
    suit_map = suit_map,
  }

  return ret
end


local function insertRetally (retally, object)
  local object_definition = object.definition
  local tally_ui_elem = object_definition.nodes[2].nodes[1].nodes[1].nodes[2].nodes

  -- Aces
  tally_ui_elem[2].nodes[1] = tally_sprite(
    { x = 1, y = 0 },
    { { string = '' .. retally.ace_tally, colour = retally.flip_col }, { string = '' .. retally.mod_ace_tally, colour = G.C.BLUE } },
    { localize('k_aces') }
  )

  -- Faces
  tally_ui_elem[2].nodes[2] = tally_sprite(
    { x = 2, y = 0 },
    { { string = '' .. retally.face_tally, colour = retally.flip_col }, { string = '' .. retally.mod_face_tally, colour = G.C.BLUE } },
    { localize('k_face_cards') }
  )

  -- Numbered cards
  tally_ui_elem[2].nodes[3] = tally_sprite(
    { x = 3, y = 0 },
    { { string = '' .. retally.num_tally, colour = retally.flip_col }, { string = '' .. retally.mod_num_tally, colour = G.C.BLUE } },
    { localize('k_numbered_cards') }
  )

  local hidden_suits = {}
  for _, suit in ipairs(retally.suit_map) do
    if retally.suit_tallies[suit] == 0 and SMODS.Suits[suit].in_pool and not SMODS.add_to_pool(SMODS.Suits[suit], {rank=''}) then
      hidden_suits[suit] = true
    end
  end
  local i = 1
  local num_suits_shown = 0
  for i = 1, #retally.suit_map do
    if not hidden_suits[retally.suit_map[i]] then
      num_suits_shown = num_suits_shown+1
    end
  end
  local suits_per_row = 2
  local n_nodes = {}
  local visible_suits = {}
  local temp_list = {}
  while i <= math.min(4, #retally.visible_suit) do
    if not hidden_suits[retally.visible_suit[i]] then
      table.insert(n_nodes, tally_sprite(
        SMODS.Suits[retally.visible_suit[i]].ui_pos,
        {
          { string = '' .. retally.suit_tallies[retally.visible_suit[i]], colour = retally.flip_col },
          { string = '' .. retally.mod_suit_tallies[retally.visible_suit[i]], colour = G.C.BLUE }
        },
        { localize(retally.visible_suit[i], 'suits_plural') },
        retally.visible_suit[i]
      ))
      table.insert(visible_suits, i)
    end
    if #n_nodes == suits_per_row then
      table.insert(temp_list, n_nodes)
      n_nodes = {}
    end
    i = i + 1
  end
  if #n_nodes > 0 then
    table.insert(temp_list, n_nodes)
  end

  local index = 0
  local second_temp_list = {}
  for i, v in ipairs(temp_list) do
    local n = {n = G.UIT.R, config = {align = "cm", minh = 0.05, padding = 0.05}, nodes = v}
    tally_ui_elem[2 + i] = n
  end
end


local view_deck_old = G.UIDEF.view_deck
function G.UIDEF.view_deck (unplayed_only)
  view_deck_unplayed_only = unplayed_only
  local result = view_deck_old(unplayed_only)
  local retally = tally_cards()
  local object = result.nodes[1].config.object
  insertRetally(retally, object)
  object:set_parent_child(object.definition, nil)
  return result
end

local your_suits_page_old = G.FUNCS.your_suits_page
G.FUNCS.your_suits_page = function (args)
  your_suits_page_old(args)
  local suit_list = G.OVERLAY_MENU:get_UIE_by_ID('suit_list')
  if suit_list and suit_list.config.object then
    local retally = tally_cards()
    local object = suit_list.config.object
    insertRetally(retally, object)
    suit_list.config.object = UIBox {
			definition = object.definition, config = {offset = { x = 0, y = 0 }, align = 'cm', parent = suit_list }
		}
  end
  return
end


-----------------------
--- Joker overrides ---
-----------------------

SMODS.Joker:take_ownership('oops', {
  loc_vars = function(self, info_queue, card)
    local n, d = SMODS.get_probability_vars(card, 1, 6, 'j_pdem_oops_6s_from')
    local n2, d2 = SMODS.get_probability_vars(card, 2, 6, 'j_pdem_oops_6s_to')
    return { vars = {n, d, n2, d2} }
  end,
}, true)

-----------------
--- Hand calc ---
-----------------

local get_straight_old = get_straight
function get_straight (hand, min_length, skip, wrap)
  min_length = min_length or 5
  if min_length < 2 then min_length = 2 end
  if #hand < min_length then return {} end
  local ranks = {}
  for k,_ in pairs(SMODS.Ranks) do ranks[k] = {} end
  for _,card in ipairs(hand) do
    local id = card:get_id()
    if id > 0 then
      for k,v in pairs(SMODS.Ranks) do
        if v.id == id or card.base.value == k or card.config.center.config['pdem_is_rank_'..k] then table.insert(ranks[k], card); break end
      end
    end
  end
  local function next_ranks(key, start)
    local rank = SMODS.Ranks[key]
    local ret = {}
    if not start and not wrap and rank.straight_edge then return ret end
    for _,v in ipairs(rank.next) do
      ret[#ret+1] = v
      if skip and (wrap or not SMODS.Ranks[v].straight_edge) then
        for _,w in ipairs(SMODS.Ranks[v].next) do
          ret[#ret+1] = w
        end
      end
    end
    return ret
  end
  local tuples = {}
  local ret = {}
  for _,k in ipairs(SMODS.Rank.obj_buffer) do
    if next(ranks[k]) then
      tuples[#tuples+1] = {k}
    end
  end
  for i = 2, #hand+1 do
    local new_tuples = {}
    for _, tuple in ipairs(tuples) do
      local any_tuple
      if i ~= #hand+1 then
        for _,l in ipairs(next_ranks(tuple[i-1], i == 2)) do
          if next(ranks[l]) then
            local new_tuple = {}
            for _,v in ipairs(tuple) do new_tuple[#new_tuple+1] = v end
            new_tuple[#new_tuple+1] = l
            new_tuples[#new_tuples+1] = new_tuple
            any_tuple = true
          end
        end
      end
      if i > min_length and not any_tuple then
        local straight = {}
        for _,v in ipairs(tuple) do
          for _,card in ipairs(ranks[v]) do
            straight[#straight+1] = card
          end
        end
        ret[#ret+1] = straight
      end
    end
    tuples = new_tuples
  end
  table.sort(ret, function(a,b) return #a > #b end)
  return ret
end

-----------------------
--- Enhancement fix ---
-----------------------

local get_enhancements_old = SMODS.get_enhancements
function SMODS.get_enhancements(card, extra_only)
  local result = get_enhancements_old(card, extra_only)

  if card.ability.pdem_enhancement then
    result[card.ability.pdem_enhancement] = true
  end

  return result
end

---------------------------
--- More Card Overrides ---
---------------------------

local get_chip_bonus_old = Card.get_chip_bonus
function Card:get_chip_bonus ()
  local ret = get_chip_bonus_old(self)
  if self.ability.pdem_enhancement then
    return ret + Card.get_chip_bonus(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_chip_mult_old = Card.get_chip_mult
function Card:get_chip_mult ()
  local ret = get_chip_mult_old(self)
  if self.ability.pdem_enhancement then
    return ret + Card.get_chip_mult(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_chip_x_mult_old = Card.get_chip_x_mult
function Card:get_chip_x_mult ()
  local ret = get_chip_x_mult_old(self)
  if self.ability.pdem_enhancement then
    return ret * Card.get_chip_x_mult(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_chip_h_mult_old = Card.get_chip_h_mult
function Card:get_chip_h_mult ()
  local ret = get_chip_h_mult_old(self)
  if self.ability.pdem_enhancement then
    return ret + Card.get_chip_h_mult(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_chip_h_x_mult_old = Card.get_chip_h_x_mult
function Card:get_chip_h_x_mult ()
  local ret = get_chip_h_x_mult_old(self)
  if self.ability.pdem_enhancement then
    return ret * Card.get_chip_h_x_mult(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_chip_x_bonus_old = Card.get_chip_x_bonus
function Card:get_chip_x_bonus ()
  if self.debuff then return 0 end
  local ret = get_chip_x_bonus_old(self)
  if self.ability.pdem_enhancement then
    return ret * Card.get_chip_x_bonus(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_chip_h_bonus_old = Card.get_chip_h_bonus
function Card:get_chip_h_bonus ()
  if self.debuff then return 0 end
  local ret = get_chip_h_bonus_old(self)
  if self.ability.pdem_enhancement then
    return ret + Card.get_chip_h_bonus(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_chip_h_x_bonus_old = Card.get_chip_h_x_bonus
function Card:get_chip_h_x_bonus ()
  if self.debuff then return 0 end
  local ret = get_chip_h_x_bonus_old(self)
  if self.ability.pdem_enhancement then
    return ret * Card.get_chip_h_x_bonus(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_chip_h_dollars_old = Card.get_chip_h_dollars
function Card:get_chip_h_dollars ()
  if self.debuff then return 0 end
  local ret = get_chip_h_dollars_old(self)
  if self.ability.pdem_enhancement then
    return ret + Card.get_chip_h_dollars(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_bonus_score_old = Card.get_bonus_score
function Card:get_bonus_score ()
  if self.debuff then return 0 end
  local ret = get_bonus_score_old(self)
  if self.ability.pdem_enhancement then
    return ret + Card.get_bonus_score(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_bonus_x_score_old = Card.get_bonus_x_score
function Card:get_bonus_x_score ()
  if self.debuff then return 0 end
  local ret = get_bonus_x_score_old(self)
  if self.ability.pdem_enhancement then
    return ret * Card.get_bonus_x_score(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_bonus_h_score_old = Card.get_bonus_h_score
function Card:get_bonus_h_score ()
  if self.debuff then return 0 end
  local ret = get_bonus_h_score_old(self)
  if self.ability.pdem_enhancement then
    return ret + Card.get_bonus_h_score(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_bonus_h_x_score_old = Card.get_bonus_h_x_score
function Card:get_bonus_h_x_score ()
  if self.debuff then return 0 end
  local ret = get_bonus_h_x_score_old(self)
  if self.ability.pdem_enhancement then
    return ret * Card.get_bonus_h_x_score(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_bonus_blind_size_old = Card.get_bonus_blind_size
function Card:get_bonus_blind_size ()
  if self.debuff then return 0 end
  local ret = get_bonus_blind_size_old(self)
  if self.ability.pdem_enhancement then
    return ret + Card.get_bonus_blind_size(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_bonus_x_blind_size_old = Card.get_bonus_x_blind_size
function Card:get_bonus_x_blind_size ()
  if self.debuff then return 0 end
  local ret = get_bonus_x_blind_size_old(self)
  if self.ability.pdem_enhancement then
    return ret * Card.get_bonus_x_blind_size(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_bonus_h_blind_size_old = Card.get_bonus_h_blind_size
function Card:get_bonus_h_blind_size ()
  if self.debuff then return 0 end
  local ret = get_bonus_h_blind_size_old(self)
  if self.ability.pdem_enhancement then
    return ret + Card.get_bonus_h_blind_size(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_bonus_h_x_blind_size_old = Card.get_bonus_h_x_blind_size
function Card:get_bonus_h_x_blind_size ()
  if self.debuff then return 0 end
  local ret = get_bonus_h_x_blind_size_old(self)
  if self.ability.pdem_enhancement then
    return ret * Card.get_bonus_h_x_blind_size(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local get_p_dollars_old = Card.get_p_dollars
function Card:get_p_dollars ()
  if self.debuff then return 0 end
  local ret = get_p_dollars_old(self)
  if self.ability.pdem_enhancement then
    return ret + Card.get_p_dollars(self.ability.pdem_enhancement_fake)
  end
  return ret
end

local is_face_old = Card.is_face
function Card:is_face(from_boss)
    if self.debuff and not from_boss then return end
    local id = self:get_id()
    local rank = SMODS.Ranks[self.base.value]
    if not id then return end
    if (id > 0 and rank and rank.face) or next(SMODS.find_card("j_pareidolia")) then
        return true
    end
    return is_face_old(self, from_boss)
end

-----------------------
--- Repetitions Fix ---
-----------------------

SMODS.calculate_repetitions = function(card, context, reps)
    -- From the card
    context.repetition_only = true
    local eval = eval_card(card, context)
    for _, value in pairs(eval) do
        SMODS.insert_repetitions(reps, value, card)
    end
    -- Quantum enhancement support :cat_owl:
    local quantum_eval = {}
    SMODS.calculate_quantum_enhancements(card, quantum_eval, context)
    for _, eval in ipairs(quantum_eval) do
        for _, value in pairs(eval) do
            SMODS.insert_repetitions(reps, value, card)
        end
    end
    context.repetition_only = nil
    --From jokers
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        for _, _card in ipairs(area.cards) do
            --calculate the joker effects
            context.pdem_joker_only = true
            local eval, post = eval_card(_card, context)
            context.pdem_joker_only = nil
            local first = true
            for key, value in pairs(eval) do
                if key ~= 'retriggers' then
                    local curr_size = #reps
                    SMODS.insert_repetitions(reps, value, _card)
                    -- After each inserted repetition we insert the post effects
                    local new_size = #reps
                    for i = curr_size + 1, new_size do
                        if not first then
                            post = {}
                            if SMODS.optional_features.post_trigger and SMODS.can_context_post_trigger(context) then
                                SMODS.calculate_context({blueprint_card = context.blueprint_card, post_trigger = true, other_card = _card, other_context = context, other_ret = eval}, post)
                            end
                        end
                        first = nil
                        if next(post) then
                            reps[#reps - new_size + i].retriggers.retrigger_flag = true
                        else break end
                        -- index from behind since that doesn't change
                        for idx, eff in ipairs(post) do
                            if next(eff) then
                                select(2, next(eff)).retrigger_flag = true
                                table.insert(reps, #reps + 1 - new_size + i, eff)
                            end
                        end
                        select(2, next(reps[#reps - new_size + i])).retrigger_flag = false
                    end
                end
            end
            if eval.retriggers then
                context.retrigger_joker = true
                for rt = 1, #eval.retriggers do
                    context.retrigger_joker = eval.retriggers[rt].retrigger_card
                    context.pdem_joker_only = true
                    local rt_eval, rt_post = eval_card(_card, context)
                    context.pdem_joker_only = nil
                    if next(rt_eval) then
                        SMODS.insert_repetitions(reps, eval.retriggers[rt], eval.retriggers[rt].message_card or _card)
                        if next(rt_post) then SMODS.trigger_effects({rt_post}, card) end
                        for key, value in pairs(rt_eval) do
                            if key ~= 'retriggers' then
                                SMODS.insert_repetitions(reps, value, _card)
                            end
                        end
                    end
                end
                context.retrigger_joker = nil
            end
        end
    end
    for _, area in ipairs(SMODS.get_card_areas('individual')) do
        local eval, post = SMODS.eval_individual(area, context)
        if next(post) then SMODS.trigger_effects({post}, card) end
        for key, value in pairs(eval) do
            if key ~= 'retriggers' then
                SMODS.insert_repetitions(reps, value, area.scored_card)
            end
        end
        if eval.retriggers then
            context.retrigger_joker = true
            for rt = 1, #eval.retriggers do
                context.retrigger_joker = eval.retriggers[rt].retrigger_card
                local rt_eval, rt_post = SMODS.eval_individual(area, context)
                if next(rt_eval) then
                    if next(rt_post) then SMODS.trigger_effects({rt_post}, card) end
                    for key, value in pairs(rt_eval) do
                        if key ~= 'retriggers' then
                            SMODS.insert_repetitions(reps, value, area.scored_card)
                        end
                    end
                end
            end
            context.retrigger_joker = nil
        end
    end
    return reps
end