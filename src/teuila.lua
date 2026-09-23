------------------------
--- Helper Functions ---
------------------------

local function pdem_use_tarot (card)
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.4,
    func = function()
      play_sound('tarot1')
      card:juice_up(0.3, 0.5)
      return true
    end
  }))
end

local function pdem_juice_up_and_flip_cards (cards)
  for i, card in ipairs(cards) do
    local percent = 1.15 - (i - 0.999) / (#cards - 0.998) * 0.3
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.15,
      func = function()
        card:flip()
        play_sound('card1', percent)
        card:juice_up(0.3, 0.3)
        return true
      end
    }))
  end
end

local function pdem_make_eternal (cards)
  for _, card in ipairs(cards) do
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.1,
      func = function()
        card.ability.eternal = true
        return true
      end
    }))
  end
end

local function pdem_make_identical (cards, template)
  for _, card in ipairs(cards) do
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.1,
      func = function()
        if card ~= template then
          SMODS.copy_card(template, {
            new_card = card,
            no_add = true,
            playing_card = false
          })
        end
        return true
      end
    }))
  end
end

local function pdem_juice_up_and_unflip_cards (cards)
  for i, card in ipairs(cards) do
    local percent = 0.85 + (i - 0.999) / (#cards - 0.998) * 0.3
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.15,
      func = function()
        card:flip()
        play_sound('tarot2', percent, 0.6)
        card:juice_up(0.3, 0.3)
        return true
      end
    }))
  end
end

local function pdem_unhighlight_all (area)
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.2,
    func = function()
      area:unhighlight_all()
      return true
    end
  }))
end

------------------------------------
--- Teuila Card Type Definitions ---
------------------------------------

local teuila_text_color = HEX('ffffff')
local teuila_primary_color = HEX('424e54')
local teuila_secondary_color = HEX('3b8c3b')

G.ARGS.LOC_COLOURS.pdem_teuila = teuila_secondary_color

SMODS.ConsumableType {
  key = 'pdem_teuila',
  default = 'pdem_te_undiscovered',
  collection_rows = {4, 5},
  shop_rate = 0,
  primary_colour = teuila_primary_color,
  secondary_colour = teuila_secondary_color,
  text_colour = teuila_text_color,
}

SMODS.UndiscoveredSprite {
  key = 'pdem_teuila',
  atlas = 'tarots',
  pos = { x = 1, y = 0 },
}


--------------------
--- Teuila Cards ---
--------------------

SMODS.Consumable {
  key = 'te_eye',
  set = 'pdem_teuila',
  atlas = 'tarots',
  pos = { x = 5, y = 0 },
  cost = 3,
  config = { max_highlighted = 1 },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.max_highlighted } }
  end,
  use = function(self, card, area, copier)
    local receiving_joker = G.jokers.highlighted[1]
    local edition_jokers = SMODS.Edition:get_edition_cards(G.jokers)
    local donating_joker = pseudorandom_element(edition_jokers, pseudoseed('pdem_te_eye'))

    local donated_edition = donating_joker.edition.key
    pdem_use_tarot(card)
    donating_joker:set_edition(nil, true)
    receiving_joker:set_edition(donated_edition, true)
    pdem_unhighlight_all(G.jokers)
    delay(0.5)
  end,
  can_use = function(self, card)
    if not G.jokers or #G.jokers.highlighted == 0 or #G.jokers.highlighted > card.ability.max_highlighted then
      return false
    end

    -- Can only use when there are jokers with editions
    local edition_jokers = SMODS.Edition:get_edition_cards(G.jokers)
    if not next(edition_jokers) then return false end

    -- Can't use when a joker has been selected that already has an edition
    for _, c in ipairs(G.jokers.highlighted) do
      if c.edition then return false end
    end

    return true
  end,
}

SMODS.Consumable {
  key = 'te_laurel',
  set = 'pdem_teuila',
  atlas = 'tarots',
  pos = { x = 0, y = 0 },
  cost = 3,
  config = { max_highlighted = 1 },
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = {key = 'eternal', set = 'Other'}
    return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Other', key = 'eternal' } } }
  end,
  use = function(self, card, area, copier)
    pdem_use_tarot(card)
    pdem_juice_up_and_flip_cards(G.jokers.highlighted)
    pdem_make_eternal(G.jokers.highlighted)
    delay(0.2)
    pdem_juice_up_and_unflip_cards(G.jokers.highlighted)
    pdem_unhighlight_all(G.jokers)
    delay(0.5)
  end,
  can_use = function(self, card)
    if not G.jokers or #G.jokers.highlighted == 0 or #G.jokers.highlighted > card.ability.max_highlighted then
      return false
    end
    for _, c in ipairs(G.jokers.highlighted) do
      if not c.config.center.eternal_compat or c.ability.perishable or c.ability.eternal then
        return false
      end
    end
    return true
  end,
}

SMODS.Consumable {
  key = 'te_gate',
  set = 'pdem_teuila',
  atlas = 'tarots',
  pos = { x = 4, y = 0 },
  cost = 3,
  config = { max_highlighted = 1 },
  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.max_highlighted} }
  end,
  use = function(self, card, area, copier)
    pdem_use_tarot(card)
    local highlighted = {unpack(G.jokers.highlighted)}
    for i, c in ipairs(highlighted) do
      G.jokers:remove_from_highlighted(c)
      pdem_remove_joker_from_joker_area(c)
      pdem_add_joker_to_deck(c)
      check_for_unlock{ type = 'pdem_teuila_gate' }
    end
  end,
  can_use = function(self, card)
    return G.jokers and #G.jokers.highlighted > 0 and #G.jokers.highlighted <= card.ability.max_highlighted
  end,
}

SMODS.Consumable {
  key = 'te_wheel',
  set = 'pdem_teuila',
  atlas = 'tarots',
  pos = { x = 3, y = 0 },
  cost = 3,
  config = { min_highlighted = 1, max_highlighted = 1 },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.max_highlighted } }
  end,
  use = function(self, card, area, copier)
    local leftmost = G.jokers.cards[1]
    for i = 1, #G.jokers.cards do
      if G.jokers.cards[i].T.x < leftmost.T.x then
        leftmost = G.jokers.cards[i]
      end
    end

    pdem_use_tarot(card)
    pdem_juice_up_and_flip_cards({leftmost})
    pdem_juice_up_and_flip_cards(G.jokers.highlighted)
    pdem_make_identical(G.jokers.highlighted, leftmost)
    delay(0.2)
    pdem_juice_up_and_unflip_cards({leftmost})
    pdem_juice_up_and_unflip_cards(G.jokers.highlighted)
    pdem_unhighlight_all(G.jokers)
    delay(0.5)
  end,
  can_use = function(self, card)
    if not G.jokers or #G.jokers.highlighted < card.ability.min_highlighted or #G.jokers.highlighted > card.ability.max_highlighted then
      return false
    end

    local leftmost = G.jokers.cards[1]
    for i = 1, #G.jokers.cards do
      if G.jokers.cards[i].T.x < leftmost.T.x then
        leftmost = G.jokers.cards[i]
      end
    end

    if leftmost.ability.pdem_gold_star then
      -- Can't copy a Star Joker
      return false
    end

    for _, c in ipairs(G.jokers.highlighted) do
      if c == leftmost or c.ability.eternal then
        -- Can't overwrite Eternal, can't copy a joker onto itself.
        return false
      end
    end
    return true
  end,
}

SMODS.Consumable {
  key = 'te_blank',
  set = 'pdem_teuila',
  atlas = 'tarots',
  pos = { x = 2, y = 0 },
  cost = 3,
  config = { max_highlighted = 1 },
  loc_vars = function(self, info_queue, card)
    local last_card_used = G.GAME.pdem_last_spectral_teuila
    local last_card_used_center = G.GAME.pdem_last_spectral_teuila and G.P_CENTERS[G.GAME.pdem_last_spectral_teuila] or nil
    local last_card_used_text = last_card_used_center
      and localize { type = 'name_text', key = last_card_used_center.key, set = last_card_used_center.set }
      or localize('k_none')

    local is_invalid = not last_card_used_center or last_card_used == 'c_pdem_te_blank'
    local colour = is_invalid and G.C.RED or G.C.GREEN

    if not is_invalid then
      info_queue[#info_queue + 1] = last_card_used_center
    end

    local main_end = {
      {
        n = G.UIT.C,
        config = { align = "bm", padding = 0.02 },
        nodes = {
          {
            n = G.UIT.C,
            config = { align = "m", colour = colour, r = 0.05, padding = 0.05 },
            nodes = {
              { n = G.UIT.T, config = { text = ' ' .. last_card_used_text .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true } },
            }
          }
        }
      }
    }

    return { vars = { last_card_used_text }, main_end = main_end }
  end,
  use = function(self, card, area, copier)
    local target = G.GAME.pdem_last_spectral_teuila
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        if G.consumeables.config.card_limit > #G.consumeables.cards then
          play_sound('timpani')
          SMODS.add_card({ key = target })
          card:juice_up(0.3, 0.5)
        end
        return true
      end
    }))
    delay(0.6)
  end,
  can_use = function(self, card)
    return (
      (#G.consumeables.cards < G.consumeables.config.card_limit or card.area == G.consumeables) and
      G.GAME.pdem_last_spectral_teuila and
      G.GAME.pdem_last_spectral_teuila ~= 'c_pdem_te_blank'
    )
  end,
}
