-- The Reed: Debuffs a random hand type each round
SMODS.Blind {
  key = 'reed',
  dollars = 5,
  mult = 2,
  pos = { x = 0, y = 6 },
  boss = { min = 2 },
  atlas = 'blinds',
  boss_colour = HEX 'a4a554',
  collection_loc_vars = function (self)
    return { vars = {localize('pdem_random_hand')} }
  end,
  loc_vars = function (self)
    local debuffed_hand = nil

    if G.GAME.blind and G.GAME.blind.hands then
      for key, value in pairs(G.GAME.blind.hands) do
        if value then debuffed_hand = key break end
      end
    end

    if debuffed_hand == nil then
      return { vars = {localize('pdem_random_hand')} }
    else
      return { vars = {localize(debuffed_hand, 'poker_hands')} }
    end
  end,
  calculate = function (self, blind, context)
    if not blind.disabled then
      if context.after or context.setting_blind then
        local items = {}
        blind.hands = {}

        for _, key in pairs(G.handlist) do
          local label = key:gsub("%s+", "")
          blind.hands[key] = false
          if G.GAME.hand_usage[label] and G.GAME.hand_usage[label].count > 0 then
            table.insert(items, key)
          end
        end

        if #items > 0 then
          local target_hand_index = math.ceil(pseudorandom('pdem_reed') * #items)
          blind.hands[items[target_hand_index]] = true
          blind.triggered = true

          G.E_MANAGER:add_event(Event({
            func = function ()
              blind:wiggle()
              blind:set_text()
              return true
            end
          }))
        end

      elseif context.debuff_hand then
        if blind.hands[context.scoring_name] then
          blind.triggered = true
          blind:set_text()
          return { debuff = true }
        end
      end
    end
  end
}

-- The Lasso: Debuffs the rank and suit of all scored cards for the next hand.
SMODS.Blind {
  key = 'lasso',
  dollars = 5,
  mult = 2,
  pos = { x = 0, y = 7 },
  boss = { min = 1 },
  atlas = 'blinds',
  boss_colour = HEX '99561d',
  config = {},
  disable = function (self)
    for _, card in ipairs(G.playing_cards) do
      if card.ability.pdem_lasso_debuffed then
        card.debuff = false
      end
      card.ability.pdem_lasso_debuffed = nil
    end
  end,
  calculate = function (self, blind, context)
    if not G.GAME.blind.disabled then
      if context.setting_blind then
        for _, card in ipairs(G.playing_cards) do card.ability.pdem_lasso_debuffed = nil end
        blind.prepped = true
      end
      if context.after then
        local scoring_hand = SMODS.last_hand.scoring_hand
        G.E_MANAGER:add_event(Event({
          trigger = 'immediate',
          func = function()
            blind:wiggle()

            local scored_ranks = {}
            local scored_suits = {}
            for _, scored_card in ipairs(scoring_hand) do
              if not scored_card.debuff then
                if not SMODS.has_no_suit(scored_card) then scored_suits[scored_card.base.suit] = true end
                if not SMODS.has_no_rank(scored_card) then scored_ranks[scored_card.base.value] = true end
              end
            end

            for _, card in ipairs(G.playing_cards) do
              if not card.debuff or card.ability.pdem_lasso_debuffed then
                local must_debuff = false
                for suit, _ in pairs(scored_suits) do
                  if card:is_suit(suit, true) then
                    must_debuff = true
                    break
                  end
                end

                if not must_debuff then
                  for rank, _ in pairs(scored_ranks) do
                    if card:pdem_is_rank(rank, true) then
                      must_debuff = true
                      break
                    end
                  end
                end

                card.debuff = must_debuff
                card.ability.pdem_lasso_debuffed = must_debuff
              end
            end
            return true
          end
        }))
      end
    end
  end
}

-- The Owl: Switches hands and discards at the start of the round.
SMODS.Blind {
  key = 'owl',
  dollars = 5,
  mult = 2,
  pos = { x = 0, y = 8 },
  boss = { min = 1 },
  atlas = 'blinds',
  boss_colour = HEX 'f7ce77',
  calculate = function(self, blind, context)
    if context.blind_disabled then
      ease_discard(blind.effect.discards_sub)
      ease_hands_played(blind.effect.hands_sub)
    end

    if blind.disabled then return end

    if context.setting_blind then
      local diff = G.GAME.current_round.discards_left - G.GAME.current_round.hands_left
      blind.effect.discards_sub = diff
      blind.effect.hands_sub = -diff
      ease_discard(-blind.effect.discards_sub)
      ease_hands_played(-blind.effect.hands_sub)
      blind:wiggle()
      blind.prepped = true
    end
  end
}

-- The Wick: Averages hands and discards into one resource
SMODS.Blind {
  key = 'wick',
  dollars = 5,
  mult = 2,
  pos = { x = 0, y = 5 },
  boss = { min = 3 },
  atlas = 'blinds',
  boss_colour = HEX 'c0bbbe',
  calculate = function(self, blind, context)
    if not blind.disabled then
      if context.setting_blind then
        blind.prepped = true

        -- Average hands and discards
        local hands = G.GAME.round_resets.hands
        local discards = G.GAME.current_round.discards_left
        local combined = math.ceil((hands + discards) / 2)

        G.GAME.blind.hands_sub = hands - combined
        blind.discards_sub = discards - combined
        G.GAME.current_round.hands_left = G.GAME.current_round.hands_left - G.GAME.blind.hands_sub
        G.GAME.current_round.discards_left = G.GAME.current_round.discards_left - blind.discards_sub
        
        local hand_UI = G.HUD:get_UIE_by_ID('hand_UI_count')
        local discard_UI = G.HUD:get_UIE_by_ID('discard_UI_count')
        hand_UI.config.object:update()
        discard_UI.config.object:update()
        G.HUD:recalculate()
        
        play_sound('gong', 0.94, 0.3)
        play_sound('gong', 0.94*1.5, 0.2)
        play_sound('tarot1', 1.5)

        ease_colour(G.C.UI_HANDS, {0.8, 0.45, 0.85, 1}, 0.5)
        ease_colour(G.C.UI_DISCARDS, {0.8, 0.45, 0.85, 1}, 0.5)

        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          blockable = false,
          blocking = false,
          delay =  4.3,
          func = function ()
            ease_colour(G.C.UI_HANDS, G.C.BLUE, 2)
            ease_colour(G.C.UI_DISCARDS, G.C.RED, 2)
            return true
          end
        }))
      elseif context.press_play then
        -- Subtract a discard when playing
        blind.discards_sub = blind.discards_sub + 1
        ease_discard(-1)
      elseif context.pre_discard then
        -- Subtract a hand when discarding
        G.GAME.blind.hands_sub = G.GAME.blind.hands_sub + 1
        ease_hands_played(-1)

        -- Check for a game over (not automatic after discard)
        G.E_MANAGER:add_event(Event({
          func = function ()
            if G.GAME.current_round.hands_left < 1 then end_round() end
            return true
          end
        }))
      end
    end
  end,
  disable = function(self)
    if blind.prepped then
      blind.prepped = false
      ease_hands_played(G.GAME.blind.hands_sub)
      ease_discard(G.GAME.blind.discards_sub)
    end
  end,
}

-- The Sieve: Must play at most 1 suit.
SMODS.Blind {
  key = 'sieve',
  dollars = 5,
  mult = 2,
  pos = { x = 0, y = 9 },
  boss = { min = 2 },
  atlas = 'blinds',
  boss_colour = HEX 'c56bb1',
  debuff_hand = function (self, cards, hand, handname, check)
    for key, _ in pairs(SMODS.Suits) do
      local is_flush_hand = true
      for _, card in ipairs(cards) do
        if not SMODS.has_no_suit(card) and not card:is_suit(key, true) then
          is_flush_hand = false
          break
        end
      end
      if is_flush_hand then return false end
    end
    return true
  end
}


---------------------
-- Showdown blinds --
---------------------

-- Argent Wand: Discard 1 card from your played hand for every remaining hand.
-- TODO: maybe move cards to unscored instead of discarding them
SMODS.Blind {
  key = 'wand',
  dollars = 8,
  mult = 2,
  pos = { x = 0, y = 3 },
  boss = { showdown = true, min = 2 },
  atlas = 'blinds',
  boss_colour = HEX '97bfcb',
  press_play  = function (self)
    if not G.GAME.blind.disabled then
      local discard_count = math.min(G.GAME.current_round.hands_left - 1, #G.hand.highlighted)
      for it = 1, discard_count do
        local target_index = math.ceil(pseudorandom('pdem_wand') * #G.hand.highlighted)
        local card = G.hand.highlighted[target_index]

        -- Remove the card so it can't count towards any poker hand.
        G.hand:remove_from_highlighted(card, true)
        G.hand:remove_card(card)

        -- Remove the card AGAIN, this time to prevent it from scoring.
        G.E_MANAGER:add_event(Event({
          func = function ()
            draw_card(
              G.play,
              G.discard,
              it * 100 / discard_count,
              'down',
              false,
              card
            )
            return true
          end
        }))

        -- Note that `draw_card` must only be called once per card, or it ruins
        -- the remaining card count of your deck for the rest of the run.
      end
      if discard_count > 0 then
        G.E_MANAGER:add_event(Event({
          func = function ()
            G.GAME.blind:wiggle()
            return true
          end
        }))
      end
    end
    return false
  end,
}

-- Tyrian Crown: Each card played increases required score.
SMODS.Blind {
  key = 'crown',
  dollars = 8,
  mult = 2,
  pos = { x = 0, y = 0 },
  boss = { showdown = true },
  atlas = 'blinds',
  boss_colour = HEX '871155',
  --config = { extra = { scale_factor = 0.5, current_factor = 0 } },
  collection_loc_vars = function (self)
    return { vars = {localize('pdem_score_placeholder')} }
  end,
  loc_vars = function (self)
    return { vars = {tostring(
      get_blind_amount(G.GAME.round_resets.ante) *
      G.GAME.starting_params.ante_scaling *
      0.5 -- Scaling factor
    )} }
  end,
  calculate = function (self, blind, context)
    if not blind.disabled then
      if context.setting_blind then
        blind.prepped = true
      end
      if context.individual and (context.cardarea == G.play or context.cardarea == "unscored") and not context.end_of_round then
        local scale_amount =
          get_blind_amount(G.GAME.round_resets.ante) *
          G.GAME.starting_params.ante_scaling *
          0.5 -- Scaling factor

        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          delay = 0.4,
          func = function ()
            blind.chips = blind.chips + scale_amount
            blind.chip_text = number_format(blind.chips)
            G.HUD_blind:recalculate(false)
            blind:wiggle()
            return true
          end
        }))
      end
    end
  end,
  disable = function (self)
    if blind.prepped then
      blind.prepped = false
      local blind = G.GAME.blind
      G.GAME.blind.chips = 
        get_blind_amount(G.GAME.round_resets.ante) *
        G.GAME.starting_params.ante_scaling *
        2 -- Default factor
      G.GAME.blind.chip_text = number_format(blind.chips)
      G.HUD_blind:recalculate(false)
    end
  end,
}

-- Malachite Key: Clearing the round early sets your round score to 0.
SMODS.Blind {
  key = 'key',
  dollars = 8,
  mult = 2,
  pos = { x = 0, y = 1 },
  boss = { showdown = true },
  atlas = 'blinds',
  boss_colour = HEX '31c964',
  calculate = function (self, blind, context)
    if not blind.disabled then
      if context.final_scoring_step then
        if context.final_scoring_step then
          local chips = SMODS.get_scoring_parameter('chips', false)
          local mult = SMODS.get_scoring_parameter('mult', false)
          local hand_score = SMODS.calculate_round_score()

          if
            G.GAME.chips + hand_score >= G.GAME.blind.chips and
            G.GAME.current_round.hands_left > 0
          then
            G.GAME.chips = 0
            blind:wiggle()
            G.E_MANAGER:add_event(Event({
              func = function ()
                blind:wiggle()
                return true
              end
            }))
            
            return { mult = -mult, chips = -chips }
          end
        end
      end
    end
  end,
}

-- Fulvous Horn: If played hand doesn't exceed accumulated round score, score 0.
SMODS.Blind {
  key = 'horn',
  dollars = 8,
  mult = 2,
  pos = { x = 0, y = 2 },
  boss = { showdown = true },
  atlas = 'blinds',
  boss_colour = HEX 'dc8531',
  disable = function (self)
    G.GAME.blind.effect.pdem_tracked_jokers = {}
    G.GAME.blind.effect.pdem_tracked_jokers_trusted = {}
  end,
  calculate = function (self, blind, context)
    if not blind.disabled then
      if context.final_scoring_step then
        local chips = SMODS.get_scoring_parameter('chips', false)
        local mult = SMODS.get_scoring_parameter('mult', false)
        local hand_score = SMODS.calculate_round_score()
        local round_score = G.GAME.chips

        if hand_score <= round_score then
          blind:wiggle()
          return { mult = -mult, chips = -chips }
        end
      end
    end
  end,
}

-- Ebony Rose
SMODS.Blind {
  key = 'rose',
  dollars = 8,
  mult = 2,
  pos = { x = 0, y = 4 },
  boss = { showdown = true }, --{ min = 1 }, -- { showdown = true },
  atlas = 'blinds',
  boss_colour = HEX '3c4b4e',
  config = { tracked_jokers = {} },
  press_play  = function (self)
    G.GAME.blind.effect.tracked_jokers = {}
  end,
  disable = function (self)
    G.GAME.blind.effect.tracked_jokers = {}
  end,
}