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
  key = 'te_ring',
  set = 'pdem_teuila',
  atlas = 'tarots',
  pos = { x = 6, y = 0 },
  cost = 3,
  config = { extra = { pdem_te_ring_hand_size = 1} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.pdem_te_ring_hand_size } }
  end,
  use = function(self, card, area, copier)
    pdem_use_tarot(card)
    local targets = {}
    for _, joker in ipairs(G.jokers.cards) do
      if not joker.ability.eternal then
        table.insert(targets, joker)
      end
    end
    local selected = pseudorandom_element(targets, pseudoseed('pdem_te_ring'))
    SMODS.destroy_cards({selected})
    G.hand:change_size(card.ability.extra.pdem_te_ring_hand_size)
  end,
  can_use = function(self, card)
    for _, joker in ipairs(G.jokers.cards) do
      if not joker.ability.eternal then return true end
    end
    return false
  end,
}

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
  key = 'te_devil',
  set = 'pdem_teuila',
  atlas = 'tarots',
  pos = { x = 7, y = 0 },
  cost = 3,
  config = { max_highlighted = 1 },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.max_highlighted } }
  end,
  use = function(self, card, area, copier)
    pdem_use_tarot(card)
    delay(0.2)
    for _, joker in ipairs(G.jokers.highlighted) do
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        func = function()
          local banished_key = joker.config.center.key
          G.GAME.banned_keys[joker.config.center.key] = true
          card_eval_status_text(joker, 'extra', nil, nil, nil, {
            message = localize('k_pdem_banish'),
            colour = G.C.PURPLE,
          })
          SMODS.destroy_cards({joker})

          -- Destroy any other copies of the banished card.
          local cards_to_destroy = {}
          for _, a in ipairs({
            G.deck, G.play, G.discard, G.hand, G.jokers,
            G.consumeables, G.vouchers, G.shop_jokers,
            G.shop_vouchers, G.shop_booster, G.pack_cards,
          }) do
            if a then
              for _, c in ipairs(a.cards) do
                if c.config.center.key == banished_key and not c.ability.eternal then
                  table.insert(cards_to_destroy, c)
                end
              end
            end
          end
          SMODS.destroy_cards(cards_to_destroy)
          return true
        end
      }))
    end
  end,
  can_use = function(self, card)
    if not (
      G.jokers and #G.jokers.highlighted > 0 and
      #G.jokers.highlighted <= card.ability.max_highlighted
    ) then return false end

    for _, joker in ipairs(G.jokers.highlighted) do
      if joker.ability.eternal then return false end
    end

    return true
  end,
}

SMODS.Consumable {
  key = 'te_volcano',
  set = 'pdem_teuila',
  atlas = 'tarots',
  pos = { x = 8, y = 0 },
  cost = 3,
  config = { extra = { pdem_te_volcano_joker_size = 1} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.pdem_te_volcano_joker_size } }
  end,
  use = function(self, card, area, copier)
    pdem_use_tarot(card)
    local targets = {}
    for _, joker in ipairs(G.jokers.cards) do
      if not joker.ability.eternal then
        table.insert(targets, joker)
      end
    end
    SMODS.destroy_cards(targets)
    G.jokers:change_size(card.ability.extra.pdem_te_volcano_joker_size)
  end,
  can_use = function(self, card)
    for _, joker in ipairs(G.jokers.cards) do
      if not joker.ability.eternal then return true end
    end
    return false
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
  key = 'te_horseshoe',
  set = 'pdem_teuila',
  atlas = 'tarots',
  pos = { x = 9, y = 0 },
  cost = 3,
  config = { max_highlighted = 1 },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.max_highlighted } }
  end,
  use = function(self, card, area, copier)
    pdem_use_tarot(card)
    pdem_juice_up_and_flip_cards(G.jokers.highlighted)
    delay(0.4)
    for _, c in ipairs(G.jokers.highlighted) do
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        func = function()
          local rarity = c.config.center.rarity
          local key = SMODS.poll_object({
            type = 'Joker',
            guaranteed = true,
            rarities = {SMODS.Rarity.obj_buffer[rarity]},
            --rarity == 4 and {'Legendary'} or {rarity},
            seed = 'pdem_te_horseshoe'
          })
          c:set_ability(G.P_CENTERS[key])
          return true
        end
      }))
    end
    pdem_juice_up_and_unflip_cards(G.jokers.highlighted)
    pdem_unhighlight_all(G.jokers)
    delay(0.5)
  end,
  can_use = function(self, card)
    if not (
      G.jokers and #G.jokers.highlighted > 0 and
      #G.jokers.highlighted <= card.ability.max_highlighted
    ) then return false end

    for _, joker in ipairs(G.jokers.highlighted) do
      if joker.ability.eternal then return false end
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
