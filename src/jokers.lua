
SMODS.Joker {
  key = "peppy",
  unlocked = true,
  atlas = 'main',
  rarity = 1,
  cost = 4,
  pos = { x = 7, y = 1 },
  config = {
    pdem_is_face_card = true,
    extra = { mult = 2, pdem_enabled = false  }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.mult} }
  end,
  calculate = function (self, card, context)
    if context.before then
      card.ability.pdem_enabled = true
    elseif context.after then
      card.ability.pdem_enabled = false -- Don't try to add score when not in a scoring context.
    elseif context.post_trigger and not context.other_context.post_trigger and not context.other_context.blueprint then
      if card.ability.pdem_enabled then
        local other_joker_left = nil
        local other_joker_right = nil
        for i = 1, #G.jokers.cards do
          if G.jokers.cards[i] == card then
            other_joker_left = G.jokers.cards[i - 1]
            other_joker_right = G.jokers.cards[i + 1]
          end
        end

        if context.other_card == other_joker_left or context.other_card == other_joker_right then
          return {
            mult = card.ability.extra.mult,
            effect = true,
          }
        end
      end
    end
  end,
}

SMODS.Joker {
  key = "keen",
  unlocked = true,
  atlas = 'main',
  rarity = 1,
  cost = 4,
  pos = { x = 8, y = 1 },
  config = {
    pdem_is_face_card = true,
    extra = { chips = 10, pdem_enabled = false }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.chips} }
  end,
  calculate = function (self, card, context)
    if context.before then
      card.ability.pdem_enabled = true
    elseif context.after then
      card.ability.pdem_enabled = false -- Don't try to add score when not in a scoring context.
    elseif context.post_trigger and not context.other_context.post_trigger and not context.other_context.blueprint then
      if card.ability.pdem_enabled then
        local other_joker_left = nil
        local other_joker_right = nil
        for i = 1, #G.jokers.cards do
          if G.jokers.cards[i] == card then
            other_joker_left = G.jokers.cards[i - 1]
            other_joker_right = G.jokers.cards[i + 1]
          end
        end

        if context.other_card == other_joker_left or context.other_card == other_joker_right then
          return {
            chips = card.ability.extra.chips,
            effect = true,
          }
        end
      end
    end
  end,
}

-- Balance
SMODS.Joker {
  key = "balancing_act",
  atlas = 'main',
  rarity = 2,
  cost = 6,
  pos = { x = 9, y = 0 },
  config = {
    pdem_is_face_card = true,
    extra = { pdem_mult = 1 }
  },
  calculate = function (self, card, context)
    if card.ability.extra.pdem_sign == nil then
      if pseudorandom('pdem_balance_seed') >= 0.5 then
        card.ability.extra.pdem_sign = 1
      else
        card.ability.extra.pdem_sign = -1
      end
    end

    if context.individual and context.cardarea == G.play then
      local amount = card.ability.extra.pdem_mult * card.ability.extra.pdem_sign
      card.ability.extra.pdem_sign = card.ability.extra.pdem_sign * -1
      context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) + amount

      if amount > 0 then
        return { message = localize('k_upgrade_ex'), colour = G.C.MULT }
      else
        return { message = localize('pdem_downgrade_ex'), colour = G.C.MULT }
      end
    end
  end,

  loc_vars = function (self, info_queue, card)
    local main_end = nil
    if card.area and card.area == G.jokers then
      -- Add upgrade/downgrade text to card
      local is_upgrade = card.ability.extra.pdem_sign > 0
      local txt = is_upgrade and localize('pdem_upgrade_next') or localize('pdem_downgrade_next')
      local col = is_upgrade and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8)
      main_end = {{
        n = G.UIT.C,
        config = { align = "bm", minh = 0.4 },
        nodes = {{
          n = G.UIT.C,
          config = { ref_table = card, align = "m", colour = col, r = 0.05, padding = 0.06 },
          nodes = {{
            n = G.UIT.T,
            config = { text = ' ' .. txt .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 }
          }}
        }}
      }}
    end
    return {
      main_end = main_end,
      vars = {
        card.ability.extra.pdem_mult,
      }
    }
  end
}


-- Recycled Joker
-- Shuffles discards back into your deck
SMODS.Joker {
  key = "recycled_joker",
  unlocked = false,
  atlas = 'main',
  blueprint_compat = false,
  rarity = 2,
  cost = 6,
  pos = { x = 3, y = 0 },
  config = {
    pdem_is_face_card = true,
    extra = { pdem_recycled_unlock_condition = 50, pdem_i = 0, discard_count = 0 }
  },
  check_for_unlock = function (self, args)
    if args.type == 'career_stat' and args.statname == 'pdem_playing_cards_destroyed' then
      return G.PROFILES[G.SETTINGS.profile].career_stats[args.statname] >= self.config.extra.pdem_recycled_unlock_condition
    end
  end,
  locked_loc_vars = function(self, info_queue, card)
    return { vars = {
      self.config.extra.pdem_recycled_unlock_condition,
      G.PROFILES[G.SETTINGS.profile].career_stats['pdem_playing_cards_destroyed'] or 0
    } }
  end,
  calculate = function (self, card, context)
    if (context.pre_discard) then
      card.ability.extra.pdem_i = 1
      card.ability.extra.discard_count = #context.full_hand
    elseif (context.discard) then
      G.E_MANAGER:add_event(Event({
        func = function ()
          draw_card(
            G.discard,
            G.deck,
            card.ability.extra.pdem_i * 100 / card.ability.extra.discard_count,
            'up',
            nil,
            context.other_card,
            0.005,
            card.ability.extra.pdem_i % 2 == 0,
            nil,
            math.max((21 - card.ability.extra.pdem_i) / 20, 0.7)
          )
          card.ability.extra.pdem_i = card.ability.extra.pdem_i + 1
          return true
        end
      }))
    end
  end,
}




-- Flipped Joker
SMODS.Joker {
  key = 'flipped',
  unlocked = false,
  atlas = 'centers',
  prefix_config = { atlas = false },
  blueprint_compat = true,
  rarity = 2,
  cost = 6,
  pos = { x = 0, y = 4 },
  config = { extra = { shadow_hands = {} } },
  calculate = function(self, card, context)
    if context.pdem_shadow_hand then
      -- Skip creating a new shadow hand if Ebony Rose has already blocked it.
      if context.pdem_ebony_rose_blocking_activation then return end

      -- Find cards that will be unscored
      local unscored = {}
      for _, played_card in ipairs(context.full_hand) do
        local is_scored = played_card.ability.pdem_in_shadow_hand ~= nil
        if not is_scored then
          for _, scored_card in ipairs(context.scoring_hand) do
            if played_card == scored_card then
              is_scored = true
              break
            end
          end
        end
        
        if not is_scored then
          table.insert(unscored, played_card)
        end
      end

      -- Score unscored cards as a separate hand
      local text, loc_disp_text, poker_hands, scoring_hand, disp_text = G.FUNCS.get_poker_hand_info(unscored, true)
      table.insert(card.ability.extra.shadow_hands, {
        full_hand = unscored,
        scoring_hand = scoring_hand,
        poker_hands = poker_hands,
        hand_name = text,
        display_name = loc_disp_text
      })

      -- Display cards as flipped + highlighted
      for i, played_card in ipairs(scoring_hand) do
        highlight_card(played_card, (i - 0.999) / 5, 'up')
        G.E_MANAGER:add_event(Event({
          trigger = 'immediate',
          delay = 0.1,
          func = function()
            played_card:flip()
            return true
          end
        }))
        played_card.ability.pdem_in_shadow_hand = true
        played_card.ability.pdem_highlighted = true
      end

      return {
        effect = true,
        ignore_ebony_rose = true,
        pdem_ebony_rose_activated = not context.pdem_ebony_rose_blocking_activation
      }
    elseif context.final_scoring_step then
      -- Un-highlight cards
      for i, played_card in ipairs(context.full_hand) do
        if played_card.ability.pdem_highlighted then
          played_card.ability.pdem_highlighted = false
          highlight_card(played_card, (i - 0.999) / 5, 'down')
        end
      end
    elseif context.after then
      -- Reset shadow hand cards
      card.ability.extra.shadow_hands = {}
      for _, played_card in ipairs(context.full_hand) do
        played_card.ability.pdem_in_shadow_hand = nil
      end
    end
  end,
  set_sprites = function (self, card)
    local default_back = G.P_CENTERS['b_challenge'] -- Treat challenge deck as default (except in collection)
    if G.your_collection then
      if not card.config.center.unlocked then return end -- Don't override the locked sprite
      for _, row in ipairs(G.your_collection) do
        -- The collection isn't filled out iff we're returning a sprite for it.
        if row.cards and #row.cards < 5 then
          default_back = G.P_CENTERS['b_red'] -- Treat red deck as default in the collection
          break
        end
      end
    end

    -- The back is the front, the front is the back
    if card.children.front then card.children.front:remove() end
    local atlas_key = (G.GAME.viewed_back or G.GAME.selected_back) and ((G.GAME.viewed_back or G.GAME.selected_back)[G.SETTINGS.colourblind_option and 'hc_atlas' or 'lc_atlas'] or (G.GAME.viewed_back or G.GAME.selected_back).atlas) or 'centers'
    card.children.front = SMODS.create_sprite(card.T.x, card.T.y, card.T.w, card.T.h, atlas_key, card.params.bypass_back or (card.playing_card and G.GAME[card.back].pos or default_back.pos))
    card.children.front.states.hover = card.states.hover
    card.children.front.states.click = card.states.click
    card.children.front.states.drag = card.states.drag
    card.children.front.states.collide.can = false
    card.children.front:set_role({major = card, role_type = 'Glued', draw_major = card})

    if card.children.back then card.children.back:remove() end
    card.children.back = SMODS.create_sprite(card.T.x, card.T.y, card.T.w, card.T.h, 'pdem_main', { x = 4, y = 0 })
    card.children.back.states.hover = card.states.hover
    card.children.back.states.click = card.states.click
    card.children.back.states.drag = card.states.drag
    card.children.back.states.collide.can = false
    card.children.back:set_role({major = card, role_type = 'Glued', draw_major = card})
  end,
  check_for_unlock = function (self, args)
    -- Check Amber Acorn defeat
    return (
      args.type == 'round_win' and
      G.GAME.round_resets.ante >= 16 and
      SMODS.is_active_blind('Amber Acorn')
    )
  end,
}



-- Oops! All 0s
SMODS.Joker {
  key = "oops_0s",
  unlocked = false,
  atlas = 'main',
  blueprint_compat = false,
  rarity = 2,
  cost = 6,
  pos = { x = 5, y = 0 },
  config = {
    pdem_is_rank_0 = true,
  },
  calculate = function(self, card, context)
    if context.fix_probability and not context.blueprint then
      return {
        numerator = 0,
      }
    end
  end,
  loc_vars = function(self, info_queue, card)
    local n, d = SMODS.get_probability_vars(card, 1, 6, 'j_pdem_oops_0s_from')
    local n2, d2 = SMODS.get_probability_vars(card, 0, 6, 'j_pdem_oops_0s_to')
    return { vars = {n, d, n2, d2} }
  end,
  check_for_unlock = function (self, args)
    return args.type == 'pdem_cavendish'
  end,
}


-- Oops! All 1s
SMODS.Joker {
  key = "oops_1s",
  unlocked = false,
  atlas = 'main',
  blueprint_compat = false,
  rarity = 1,
  cost = 4,
  pos = { x = 6, y = 0 },
  config = {
    pdem_is_rank_1 = true,
  },
  calculate = function(self, card, context)
    if context.mod_probability and not context.blueprint then
      return {
        denominator = 2 * context.denominator,
      }
    end
  end,
  loc_vars = function(self, info_queue, card)
    local n, d = SMODS.get_probability_vars(card, 1, 6, 'j_pdem_oops_1s_from')
    local n2, d2 = SMODS.get_probability_vars(card, 1, 12, 'j_pdem_oops_1s_to')
    return { vars = {n, d, n2, d2} }
  end,
  locked_loc_vars = function(self, info_queue, card)
    return { vars = { number_format(-10000) } }
  end,
  check_for_unlock = function (self, args)
    return args.type == 'chip_score' and args.chips <= -10000
  end,
}


-- Oops! All 3s
SMODS.Joker {
  key = "oops_3s",
  unlocked = false,
  atlas = 'main',
  blueprint_compat = false,
  rarity = 2,
  cost = 6,
  pos = { x = 7, y = 0 },
  config = {
    pdem_is_rank_3 = true,
  },
  loc_vars = function (self, info_queue, card)
    local num, denom = SMODS.get_probability_vars(card, 1, 3, 'j_pdem_oops_3s', false)
    return {vars = {num, denom}}
  end,
  locked_loc_vars = function(self, info_queue, card)
    return { vars = {
      G.PROFILES[G.SETTINGS.profile].career_stats['pdem_dice_sold'] or 0
    } }
  end,
  check_for_unlock = function (self, args)
    if args.type == 'career_stat' and args.statname == 'pdem_dice_sold' then
      return G.PROFILES[G.SETTINGS.profile].career_stats[args.statname] >= 10
    end
  end,
}

local function pdem_oops_random_add_prob_var (object, identifier, tbl)
  local key_num = 'pdem_oops_random_odds_num_' .. identifier
  local key_denom = 'pdem_oops_random_odds_denom_' .. identifier
  if tbl then
    if G.GAME.pdem_resetting_oops_random or not tbl[key_num] then
      local prng_key = 'pdem_oops_random_' .. identifier
      if object.fake_card then prng_key = prng_key .. '_fake' end
      tbl[key_num] = pseudorandom(prng_key)
      tbl[key_denom] = pseudorandom(prng_key)
    end
  end
end

-- Oops! All Random
-- Randomizes all listed probabilities
SMODS.Joker {
  key = "oops_random",
  unlocked = false,
  atlas = 'main',
  blueprint_compat = false,
  rarity = 3,
  cost = 8,
  pos = { x = 8, y = 0 },
  config = {
    pdem_is_rank_3 = true,
    pdem_is_rank_5 = true,
    pdem_is_rank_6 = true,
  },
  loc_vars = function(self, info_queue, card)
    local n = 4
    local d = 6
    n, d = SMODS.get_probability_vars(card, n, d, 'j_pdem_oops_random_from')
    local numerator, denominator = SMODS.get_probability_vars(card, n, d, 'j_pdem_oops_random')
    card.ability.pdem_oops_random_odds_num_j_pdem_oops_random = nil
    card.ability.pdem_oops_random_odds_denom_j_pdem_oops_random = nil
    if not next(SMODS.find_card('j_pdem_oops_random')) then
      card.ability.pdem_oops_random_odds_denom_j_pdem_oops_random_from = nil
      card.ability.pdem_oops_random_odds_num_j_pdem_oops_random_from = nil
    end
    return { vars = {n, d, numerator, denominator} }
  end,
  calculate = function(self, card, context)
    -- Randomize base probability values.
    --[[
      Should only happen so long as the player owns Oops! All Random, which is
      why I put it here (though I could probably find a way to place it in
      the `SMODS.get_probability_vars` monkey patch too).
    ]]

    if context.ante_change and context.ante_end then
      pdem_ensure_oops_random_table(true)
    end

    -- Update probabilities
    if context.fix_probability then
      if context.trigger_obj then
        if context.trigger_obj.ability then
          pdem_oops_random_add_prob_var(context.trigger_obj, context.identifier, context.trigger_obj.ability)
        else
   
        end
      end
    end
  end,
  check_for_unlock = function (self, args)
    return args.type == 'pdem_odds_over_1'
  end
}

-- Oops! All 7s
SMODS.Joker {
  key = "oops_7s",
  unlocked = false,
  atlas = 'main',
  blueprint_compat = false,
  rarity = 3,
  cost = 10,
  pos = { x = 0, y = 0 },
  config = {
    pdem_is_rank_7 = true,
  },
  loc_vars = function(self, info_queue, card)
    local n, d = SMODS.get_probability_vars(card, 1, 6, 'j_pdem_oops_7s_from')
    local n2, d2 = SMODS.get_probability_vars(card, 6, 6, 'j_pdem_oops_7s_to')
    return { vars = {n, d, n2, d2} }
  end,
  calculate = function(self, card, context)
    if context.fix_probability and not context.blueprint then
      if
        not context.trigger_obj or (
          context.trigger_obj.area ~= G.hand and
          context.trigger_obj.area ~= G.play and
          context.trigger_obj.area ~= G.discard and
          context.trigger_obj.area ~= G.deck and
          context.trigger_obj.area ~= 'unscored'
        )
      then
        return {
          numerator = context.denominator,
          denominator = context.denominator,
        }
      end
    end
  end,
  check_for_unlock = function (self, args)
    return args.type == 'pdem_lucky_both'
  end
}

-- Long Joker
SMODS.Joker {
  key = "long_joker",
  unlocked = false,
  display_size = { w = 71, h = 122 },
  atlas = 'long_joker',
  blueprint_compat = false,
  rarity = 3,
  cost = 8,
  pos = { x = 0, y = 0 },
  config = {
    pdem_is_face_card = true,
    extra = { limit = 1 }
  },
  loc_vars = function (self, info_queue, card)
    return { vars = { card.ability.extra.limit } }
  end,
  add_to_deck = function (self, card, from_debuff)
    SMODS.change_play_limit(card.ability.extra.limit)
    SMODS.change_discard_limit(card.ability.extra.limit)
  end,
  remove_from_deck = function (self, card, from_debuff)
    SMODS.change_play_limit(-card.ability.extra.limit)
    SMODS.change_discard_limit(-card.ability.extra.limit)
  end,
  check_for_unlock = function (self, args)
    -- Unlock with 80+ cards in your deck
    if args.type == 'modify_deck' and #G.playing_cards >= 80 then return true end
    return false
  end,
}


local function is_pointer_compatible (other_joker, card)
  if other_joker and other_joker ~= card then
    local pointer_compat = other_joker.config.center.pdem_pointer_compat
    if pointer_compat == nil then pointer_compat = other_joker.config.center.blueprint_compat end
    return pointer_compat
  end
  return false
end

-- Poke Joker
SMODS.Joker {
  key = 'pointer',
  unlocked = false,
  atlas = 'main',
  blueprint_compat = false,
  pdem_pointer_compat = true,
  rarity = 3,
  cost = 8,
  pos = { x = 0, y = 1 },
  config = { extra = { pdem_pointer_charges = 0, pdem_pointer_charges_gain = 1 }, pdem_unlock = 5 },
  locked_loc_vars = function (self, info_queue, card)
    return { vars = {self.config.pdem_unlock} }
  end,
  loc_vars = function (self, info_queue, card)
    if card.area and card.area == G.jokers then
      local other_joker
      for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 1] end
      end
      local compatible = is_pointer_compatible(other_joker, card)

      -- Add compatibility description to card
      main_end = {{
        n = G.UIT.C,
        config = { align = "bm", minh = 0.4 },
        nodes = {{
          n = G.UIT.C,
          config = {
            ref_table = card,
            align = "m",
            colour = compatible and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8),
            r = 0.05,
            padding = 0.06
          },
          nodes = {{
            n = G.UIT.T,
            config = {
              text = ' ' .. localize('k_' .. (compatible and 'compatible' or 'incompatible')) .. ' ',
              colour = G.C.UI.TEXT_LIGHT,
              scale = 0.32 * 0.8
            }
          }}
        }}
      }}

      return {
        main_end = main_end,
        vars = {
          card.ability.extra.pdem_pointer_charges_gain,
          card.ability.extra.pdem_pointer_charges
        }
      }
    end
    return {
      vars = {
        card.ability.extra.pdem_pointer_charges_gain,
        card.ability.extra.pdem_pointer_charges
      }
    }
  end,
  calculate = function (self, card, context)
    if not context.blueprint and not context.retrigger_joker then
      -- Charge gain
      if context.post_trigger then
        local other_joker_left = nil
        for i = 1, #G.jokers.cards do
          if G.jokers.cards[i] == card then
            other_joker_left = G.jokers.cards[i - 1]
          end
        end

        if context.other_card == other_joker_left then
          card.ability.extra.pdem_pointer_charges = card.ability.extra.pdem_pointer_charges + card.ability.extra.pdem_pointer_charges_gain
          return {
            message = localize{ key = 'pdem_charges', type = 'variable', vars = {card.ability.extra.pdem_pointer_charges_gain}},
            message_card = card,
          }
        end
      end

      -- Retriggers
      if context.retrigger_joker_check then
        local other_joker_right = nil
        for i = 1, #G.jokers.cards do
          if G.jokers.cards[i] == card then
            other_joker_right = G.jokers.cards[i + 1]
          end
        end

        if context.other_card == other_joker_right and is_pointer_compatible(other_joker_right, card) then
          if context.pdem_ebony_rose_blocking_activation ~= nil then
            card.ability.extra.pdem_pointer_charges = card.ability.extra.pdem_pointer_charges - 1
            local juiced = false
            return {
              repetitions = 1,
              effect = true,
              remove_default_message = true,
              no_juice = true,
              func = function ()
                if not juiced then
                  juiced = true
                  G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                      card:juice_up()
                      return true
                    end
                  }))
                end
                return true
              end
            }
          else
            local charges = card.ability.extra.pdem_pointer_charges
            card.ability.extra.pdem_pointer_charges = 0

            local juiced = false
            return {
              repetitions = charges,
              effect = true,
              remove_default_message = true,
              no_juice = true,
              func = function ()
                if not juiced then
                  juiced = true
                  G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                      card:juice_up()
                      return true
                    end
                  }))
                end
                return true
              end
            }
          end
        end
      end
    end
  end,
  check_for_unlock = function (self, args)
    return args.type == 'retrigger_playing_card' and args.count > self.config.pdem_unlock - 1
  end
}

local function redo_blind_skip_hud ()
  if G.blind_select then
    stop_use()
    G.E_MANAGER:add_event(Event({
      trigger = 'before', delay = 0.2,
      func = function()
        G.blind_prompt_box.alignment.offset.y = -10
        G.blind_select.alignment.offset.y = 40
        G.blind_select.alignment.offset.x = 0
        return true
    end}))
    G.E_MANAGER:add_event(Event({
      trigger = 'immediate',
      func = function()
        G.blind_select:remove()
        G.blind_prompt_box:remove()
        G.blind_select = nil
        delay(0.2)
        G.STATE_COMPLETE = false
        G.HUD:recalculate()
        return true
    end}))
  end
end

-- John Balatro: allow skipping non-showdown bosses
SMODS.Joker {
  key = "john_balatro",
  unlocked = false,
  atlas = 'main',
  blueprint_compat = false,
  rarity = 4,
  cost = 20,
  pos = { x = 1, y = 1 },
  soul_pos = { x = 9, y = 1 },
  config = {
    pdem_is_face_card = true,
    extra = { set_ante = 1 }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.set_ante } }
  end,
  calculate = function (self, card, context) end,
  add_to_deck = redo_blind_skip_hud,
  remove_from_deck = redo_blind_skip_hud,
}

local function pdem_try_activate_marty (marty)
  local blind_state = G.GAME.round_resets.blind_states.Small
  if blind_state == 'Upcoming' or blind_state == 'Select' then
    marty.ability.extra.pdem_active = true
    local eval = function (c) return c.ability.extra.pdem_active end
    juice_card_until(marty, eval, true)
  end
end

-- Marty McFly
-- Resets the ante to the first ante if sold in the first shop of the ante
SMODS.Joker {
  key = "marty",
  unlocked = false,
  atlas = 'main',
  blueprint_compat = false,
  rarity = 4,
  cost = 20,
  pos = { x = 2, y = 1 },
  soul_pos = { x = 6, y = 1 },
  config = {
    pdem_is_face_card = true,
    extra = { set_ante = 1, pdem_active = false }
  },
  loc_vars = function (self, info_queue, card)
    local main_end = nil
    if card.area and card.area == G.jokers then
      main_end = {{
        n = G.UIT.C,
        config = { align = "bm", minh = 0.4 },
        nodes = {{
          n = G.UIT.C,
          config = {
            ref_table = card,
            align = "m",
            colour = card.ability.extra.pdem_active and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8),
            r = 0.05,
            padding = 0.06
          },
          nodes = {{
            n = G.UIT.T,
            config = {
              text = ' ' .. localize((card.ability.extra.pdem_active and 'pdem_active' or 'pdem_inactive')) .. ' ',
              colour = G.C.UI.TEXT_LIGHT,
              scale = 0.32 * 0.8 
            }
          }}
        }}
      }}
    end
    return { main_end = main_end, vars = {card.ability.extra.set_ante} }
  end,
  add_to_deck = function(self, card, from_debuff)
    pdem_try_activate_marty(card)
  end,
  calculate = function (self, card, context)
    if context.starting_shop then
      pdem_try_activate_marty(card)
    elseif context.skip_blind or context.setting_blind then
      card.ability.extra.pdem_active = false
      pdem_try_activate_marty(card)
    elseif context.selling_self and card.ability.extra.pdem_active then
      -- Apply ante change
      ease_ante(-G.GAME.round_resets.blind_ante + 1)
      G.GAME.round_resets.blind_ante = card.ability.extra.set_ante
      return { effect = true }
    end
  end,
}

local config = SMODS.current_mod.config

-- Luigi
-- For every card, does nothing.
SMODS.Joker {
  key = "luigi",
  unlocked = false,
  atlas = 'main',
  blueprint_compat = true,
  rarity = 4,
  cost = 20,
  pos = { x = 1, y = 0 },
  soul_pos = { x = 2, y = 0 },
  config = {
    pdem_is_face_card = true,
  },
  calculate = function (self, card, context)
    if context.individual and (context.cardarea == G.play or context.cardarea == G.hand or context.cardarea == "unscored") and not context.end_of_round --[[and not context.other_card.repetition_trigger]] then
      return {
        message = localize('pdem_luigi'),
        message_card = card,
        sound = not (config.shut_him_up and G.GAME.challenge ~= 'c_pdem_luigi') and 'pdem_sfx_luigi' or nil,
        colour = G.C.GREEN,
        effect = true
      }
    end
  end,
}
