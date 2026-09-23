---@diagnostic disable: deprecated
function pdem_table_subtract (a, b)
  local setB = {}
  for _, itemB in ipairs(b) do
    setB[itemB] = true
  end

  local result = {}
  for _, itemA in ipairs(a) do
    if not setB[itemA] then
      table.insert(result, itemA)
    end
  end

  return result
end

function pdem_clamp (_min, _v, _max)
  return math.min(math.max(_min, _v), _max)
end

function pdem_ensure_oops_random_table (reset)
  if reset or not G.GAME.pdem_oops_random_num then
    G.GAME.pdem_oops_random_num = {}
    G.GAME.pdem_oops_random_denom = {}
  end
end

function pdem_get_unique_card_id (card)
  if not card.ability.pdem_unique_card_id then
    local id = G.GAME.pdem_unique_card_id_counter or 1
    G.GAME.pdem_unique_card_id_counter = id + 1
    card.ability.pdem_unique_card_id = id
  end
  return card.ability.pdem_unique_card_id
end

--------------------
-- Managing hands --
--------------------

function pdem_get_full_house (hand)
  local pair = get_X_same(2, hand)
  local triplet = get_X_same(3, hand)
  if #pair < 1 or #triplet < 1 then return {} end
  return {SMODS.merge_lists(pair, triplet)}
end

function pdem_get_flushes (hand)
  local result = {}
  local i = 0
  while true do
    i = i + 1
    if i > 10 then break end

    local flush = get_flush(hand)
    if not next(flush) then break end

    table.insert(result, flush[1])
    hand = pdem_table_subtract(hand, flush[1])
  end
  return result
end

function pdem_n_of_a_kind (amount, hand)
  local cards = get_X_same(amount, hand, true)
  if next(cards) then
    local subset = cards[1]
    local result = {}
    for i = 1, amount do
      table.insert(result, subset[i])
    end
    return {result}
  end
  return {}
end

function pdem_get_full_straight (hand)
  local amount = 13
  if next(SMODS.find_card('j_four_fingers')) then amount = amount - 1 end
  return get_straight(hand, amount, SMODS.shortcut(), SMODS.wrap_around_straight())
end

function pdem_get_X_of_Y_kinds (hand, set_size, set_count, or_more)
  local sets = get_X_same(set_size, hand, true)
  if #sets >= set_count then
    local result = {}
    for idx, set in ipairs(sets) do
      if idx > set_count and not or_more then break end
      for i = 1, set_size do
        table.insert(result, set[i])
      end
    end
    return {result}
  end

  return {}
end

-------------
-- Display --
-------------

function get_number_text (n)
  -- Not gonna bother with 53 and up. They can just be made of digits.
  if n > 52 then return tostring(n) end
  if n % 1 ~= 0 or n < 1 then
    sendWarnMessage("'n' must be a positive integer, but was " .. tostring(n), "pdem_warn")
    n = math.floor(math.abs(n))
  end
  return localize('pdem_number_'..tostring(n))
end

-------------------------
--- Riff-raff helpers ---
-------------------------

function pdem_remove_joker_from_joker_area (joker)
  if joker.ability.set == 'Joker' then
    G.jokers:remove_card(joker)
    joker:remove_from_deck()
    if joker.edition and joker.edition.negative then
      G.jokers.config.card_limit = G.jokers.config.card_limit - 1
    end
  end
end

function pdem_add_joker_to_deck (joker)
  if joker.ability.set == 'Joker' then
    local suit = joker.base.suit or 'pdem_joker_suit'
    local rank = joker.base.value or 'pdem_joker_rank'
    SMODS.change_base(joker, suit, rank)
    SMODS.add_to_deck(joker, {
      playing_card = -100,
      area = G.deck
    })
  end
end

function pdem_draw_from_joker_area_to_deck ()
  for i = #G.jokers.cards, 1, -1 do
    local joker = G.jokers.cards[i]
    pdem_remove_joker_from_joker_area(joker)
    pdem_add_joker_to_deck(joker)
  end
end
