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

local function pdem_combinations (list, subset_size, index)
  local list_size = #list

  local function binomial (n, r)
    if r < 0 or r > n then return 0 end
    r = math.min(r, n - r)

    local result = 1
    for i = 1, r do
      result = result * (n - r + i) / i
    end
    return result
  end

  local total = binomial(list_size, subset_size)
  if index > total then return nil end

  local result = {}
  local start = 1

  for position = 1, subset_size do
    for i = start, list_size - subset_size + position do
      local count = binomial(list_size - i, subset_size - position)

      if index <= count then
        result[position] = list[i]
        start = i + 1
        break
      end

      index = index - count
    end
  end

  return result
end

--------------------
-- Managing hands --
--------------------

function pdem_get_full_house (hand)
  local pairs = pdem_get_X_same_filtered(2, hand)
  local triplets = pdem_get_X_same_filtered(3, hand)
  if #pairs < 2 or #triplets < 1 then return {} end

  for _, triplet in ipairs(triplets) do
    for _, pair in ipairs(pairs) do
      local i = 1
      local real_pair = pdem_combinations(pair, 2, i)
      while real_pair do
        local j = 1
        local real_triplet = pdem_combinations(triplet, 3, j)
        while real_triplet do

          local no_duplicates = true
          for _, pair_card in ipairs(real_pair) do
            for _, triplet_card in ipairs(real_triplet) do
              if pair_card == triplet_card then no_duplicates = false; break end
            end
            if not no_duplicates then break end
          end
          if no_duplicates then
            return {SMODS.merge_lists({real_pair}, {real_triplet})}
          end

          j = j + 1
          real_triplet = pdem_combinations(pair, 3, j)
        end

        i = i + 1
        real_pair = pdem_combinations(pair, 2, i)
      end
    end
  end
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
  local cards = pdem_get_X_same_filtered(amount, hand)
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
  local sets = pdem_get_X_same_filtered(set_size, hand)
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

function pdem_get_X_same_filtered (num, hand)
  local vals = {}
  local joker_vals = {}
  local ambiguous_items = {}
  local rank_map = {}

  for rank_key, rank in pairs(SMODS.Ranks) do
    rank_map[rank.id] = rank_key
  end

  for i=#hand, 1, -1 do
    local card = hand[i]
    if card.base.value ~= 'pdem_joker_rank' then
      local id = card:get_id()
      if not vals[id] then vals[id] = {} end
      table.insert(vals[id], card)
    else
      local key = card.config.center.key
      if not joker_vals[key] then joker_vals[key] = {} end

      local is_ambiguous = false
      for rank_key, rank in pairs(SMODS.Ranks) do
        if card.config.center.config['pdem_is_rank_'..rank_key] then
          is_ambiguous = true
          if not vals[rank.id] then vals[rank.id] = {} end
          --break
        end
      end

      table.insert(is_ambiguous and ambiguous_items or joker_vals[key], card)
    end
  end

  local group_sizes = {}

  if #ambiguous_items == 0 then
    -- We can return early
    local result = {}
    for _, set in pairs(vals) do
      if #set >= num then table.insert(result, set) end
    end
    for _, set in pairs(joker_vals) do
      if #set >= num then table.insert(result, set) end
    end
    return result
  end

  local incomplete_groups = {}
  local complete_joker_groups = {}
  local complete_nonjoker_groups = {}

  for id, items in pairs(vals) do
    if #items < num then
      incomplete_groups[id] = true
      group_sizes[id] = #items
    else
      complete_nonjoker_groups[id] = true
    end
  end

  local incomplete_joker_groups = {}
  for key, items in pairs(joker_vals) do
    if #items < num then
      incomplete_joker_groups[key] = true
      group_sizes[key] = #items
    else
      complete_joker_groups[key] = true
    end
  end
  
  local best_solution = nil
  local best_score = 0
  local solution = {}

  -- Oops! All O(n!)
  local disambiguate
  disambiguate = function (index)
    local card = ambiguous_items[index]
    if card then
      -- Recurse
      local has_recursed = false

      for id, _ in pairs(incomplete_groups) do
        if group_sizes[id] < num then
          if card.config.center.config['pdem_is_rank_'..rank_map[id]] then
            group_sizes[id] = group_sizes[id] + 1
            solution[index] = id
            disambiguate(index + 1)
            has_recursed = true
            solution[index] = nil
            group_sizes[id] = group_sizes[id] - 1
          end
        end
      end

      for key, _ in pairs(incomplete_joker_groups) do
        if group_sizes[key] < num then
          if card.config.center.key == key then
            group_sizes[key] = group_sizes[key] + 1
            solution[index] = key
            disambiguate(index + 1)
            has_recursed = true
            solution[index] = nil
            group_sizes[key] = group_sizes[key] - 1
          end
        end
      end

      if not has_recursed then
        -- It can't affect any group so the outcome doesn't matter
        solution[index] = false
        disambiguate(index + 1)
      end
    else
      -- Record solution
      local new_score = 0
      for _, size in pairs(group_sizes) do
        if size >= num then new_score = new_score + 1 end
      end
      if new_score > best_score then
        best_score = new_score
        best_solution = copy_table(solution)
      end
    end
  end

  disambiguate(1)

  local doesnt_matter_items = {}
  if best_solution then
    for index, group in ipairs(best_solution) do
      if vals[group] then
        table.insert(vals[group], ambiguous_items[index])
        if #vals[group] >= num then complete_nonjoker_groups[group] = true end
      elseif joker_vals[group] then
        table.insert(joker_vals[group], ambiguous_items[index])
        if #joker_vals[group] >= num then complete_joker_groups[group] = true end
      else
        table.insert(doesnt_matter_items, ambiguous_items[index])
      end
    end
  else
    for _, item in ipairs(ambiguous_items) do
      table.insert(doesnt_matter_items, item)
    end
  end

  for _, card in ipairs(doesnt_matter_items) do
    if complete_joker_groups[card.config.center.key] then
      table.insert(joker_vals[card.config.center.key], card)
    else
      local is_inserted = false
      for rank_key, rank in pairs(SMODS.Ranks) do
        if card.config.center.config['pdem_is_rank_'..rank_key] and complete_nonjoker_groups[rank.id] then
          table.insert(vals[rank.id], card)
          is_inserted = true
          break
        end
      end
      if not is_inserted then
        table.insert(joker_vals[card.config.center.key], card)
      end
    end
  end

  local result = {}
  for _, set in pairs(vals) do
    if #set >= num then table.insert(result, set) end
  end
  for _, set in pairs(joker_vals) do
    if #set >= num then table.insert(result, set) end
  end
  return result
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
