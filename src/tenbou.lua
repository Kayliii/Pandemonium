------------------------------------
--- Tenbou Card Type Definitions ---
------------------------------------

local tenbou_text_color = HEX('ffffff')
local tenbou_primary_color = HEX('424e54')
local tenbou_secondary_color = HEX('bdbc9d') --HEX('fcfbdf')

G.ARGS.LOC_COLOURS.pdem_tenbou = tenbou_secondary_color

SMODS.ConsumableType {
  key = 'pdem_tenbou',
  default = 'pdem_tb_undiscovered',
  collection_rows = {6},
  shop_rate = 0,
  primary_colour = tenbou_primary_color,
  secondary_colour = tenbou_secondary_color,
  text_colour = tenbou_text_color,
}

SMODS.UndiscoveredSprite {
  key = 'pdem_tenbou',
  atlas = 'tarots',
  pos = { x = 5, y = 5 },
}

-----------------------
--- Tenbou Boosters ---
-----------------------

local function create_tenbou (self, card, i)
  return SMODS.create_card({
    set = "pdem_tenbou",
    area = G.pack_cards,
    skip_materialize = true,
    no_edition = true,
    allow_duplicates = true,
    soulable = true,
  })
end

local function select_tenbou (self, card, pack) return 'consumeables', true end

SMODS.Booster {
  key = 'tenbou_normal_1',
  atlas = 'boosters',
  kind = 'pdem_tenbou',
  pos = { x = 0, y = 0 },
  cost = 4,
  config = { extra = 2, choose = 1 },
  group_key = 'k_pdem_tenbou_pack',
  draw_hand = false,
  select_card = select_tenbou,
  create_card = create_tenbou
}

SMODS.Booster {
  key = 'tenbou_normal_2',
  atlas = 'boosters',
  kind = 'pdem_tenbou',
  pos = { x = 1, y = 0 },
  cost = 4,
  config = { extra = 2, choose = 1 },
  group_key = 'k_pdem_tenbou_pack',
  draw_hand = false,
  select_card = select_tenbou,
  create_card = create_tenbou
}

--------------------
--- Tenbou Cards ---
--------------------

SMODS.Consumable {
  key = 'tb_spare',
  set = 'pdem_tenbou',
  atlas = 'tarots',
  pos = { x = 4, y = 5 },
  cost = 3,
  soul_set = 'pdem_tenbou',
  soul_rate = 0.02,
  can_repeat_soul = true,
  hidden = true,
  loc_vars = function(self, info_queue, card)
    local last_card_used = G.GAME.pdem_last_tenbou
    local last_card_used_center = G.GAME.pdem_last_tenbou and G.P_CENTERS[G.GAME.pdem_last_tenbou] or nil
    local last_card_used_text = last_card_used_center
      and localize { type = 'name_text', key = last_card_used_center.key, set = last_card_used_center.set }
      or localize('k_none')

    local is_invalid = not last_card_used_center or last_card_used == 'c_pdem_tb_spare'
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
    local target = G.GAME.pdem_last_tenbou
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
      G.GAME.pdem_last_tenbou and
      G.GAME.pdem_last_tenbou ~= 'c_pdem_tb_spare'
    )
  end,
}

SMODS.Consumable {
  key = 'tb_100',
  set = 'pdem_tenbou',
  atlas = 'tarots',
  pos = { x = 9, y = 5 },
  cost = 3,
  config = { extra = { pdem_chips = 500 } },
  loc_vars = function (self, info_queue, card)
    return { vars = { card.ability.extra.pdem_chips } }
  end,
  use = function (self, card, area, copier)
    G.GAME.pdem_next_hand_chips = (G.GAME.pdem_next_hand_chips or 0) + card.ability.extra.pdem_chips
  end,
  can_use = function (self, card) return true end,
}

SMODS.Consumable {
  key = 'tb_1000',
  set = 'pdem_tenbou',
  atlas = 'tarots',
  pos = { x = 8, y = 5 },
  cost = 3,
  config = {},
  loc_vars = function (self, info_queue, card)
    return { vars = { 25 } }
  end,
  use = function (self, card, area, copier)
    local discards = G.GAME.current_round.discards_left
    ease_discard(-discards)
    G.GAME.pdem_riichi_discards_deducted = (G.GAME.pdem_riichi_discards_deducted or 0) + discards
    G.GAME.pdem_riichi_count = (G.GAME.pdem_riichi_count or 0) + 1
  end,
  can_use = function (self, card)
    return not G.GAME.pdem_riichi_blocked
  end,
}

SMODS.Consumable {
  key = 'tb_5000',
  set = 'pdem_tenbou',
  atlas = 'tarots',
  pos = { x = 7, y = 5 },
  cost = 3,
  config = { extra = { pdem_emult = 1.5 } },
  loc_vars = function (self, info_queue, card)
    return { vars = { card.ability.extra.pdem_emult } }
  end,
  use = function (self, card, area, copier)
    if not G.GAME.pdem_next_hand_emult then G.GAME.pdem_next_hand_emult = {} end
    table.insert(G.GAME.pdem_next_hand_emult, card.ability.extra.pdem_emult)
  end,
  can_use = function (self, card) return true end,
}

SMODS.Consumable {
  key = 'tb_10000',
  set = 'pdem_tenbou',
  atlas = 'tarots',
  pos = { x = 6, y = 5 },
  cost = 3,
  config = { extra = { pdem_level = 2 } },
  loc_vars = function (self, info_queue, card)
    return { vars = { card.ability.extra.pdem_level } }
  end,
  use = function (self, card, area, copier)
    G.GAME.pdem_next_hand_level_up = (G.GAME.pdem_next_hand_level_up or 0) + card.ability.extra.pdem_level
  end,
  can_use = function (self, card) return true end,
}

SMODS.Consumable {
  key = 'tb_sakura',
  set = 'pdem_tenbou',
  atlas = 'tarots',
  pos = { x = 3, y = 5 },
  cost = 3,
  soul_set = 'pdem_tenbou',
  soul_rate = 0.005,
  can_repeat_soul = false,
  hidden = true,
  loc_vars = function(self, info_queue, card)
    local not_on_cooldown = (G.GAME.pdem_sakura_used or 0) <= 0
    local in_blind = G.GAME.blind and G.GAME.blind.in_blind
    local text = localize(not_on_cooldown and (in_blind and 'pdem_active' or 'pdem_no_blind') or 'pdem_inactive')
    local main_end = {{
      n = G.UIT.C,
      config = { align = "bm", padding = 0.02 },
      nodes = {{
        n = G.UIT.C,
        config = { align = "m", colour = (not_on_cooldown and in_blind) and G.C.GREEN or G.C.RED, r = 0.05, padding = 0.05 },
        nodes = {
          { n = G.UIT.T, config = { text = ' ' .. text .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true } },
        }
      }}
    }}

    return { vars = {}, main_end = main_end }
  end,
  config = { extra = { pdem_level = 2 } },
  use = function (self, card, area, copier)
    G.GAME.pdem_sakura_used = 2

    if G.GAME.blind.chips - G.GAME.blind.chips ~= 0 then
      -- Dealing with nan/inf shenanigans, so just set it to zero outright.
      G.GAME.blind.chips = 0
    else
      ease_value(G.GAME.blind, 'chips', -G.GAME.blind.chips)
    end

    if G.GAME.chips - G.GAME.chips ~= 0 then
      -- Dealing with nan/inf shenanigans, so just set it to zero outright.
      G.GAME.chips = 0
    else
      ease_value(G.GAME, 'chips', -G.GAME.chips)
    end

    G.E_MANAGER:add_event(Event({
      blocking = false,
      func = function()
        if G.STATE == G.STATES.SELECTING_HAND then
          G.STATE = G.STATES.HAND_PLAYED
          G.STATE_COMPLETE = true
          end_round()
          return true
        end
      end
    }))
  end,
  can_use = function (self, card)
    return G.GAME.blind and G.GAME.blind.in_blind and (G.GAME.pdem_sakura_used or 0) <= 0
  end,
}