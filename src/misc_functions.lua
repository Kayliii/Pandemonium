local function check_retriggers (self, context)
  if context.individual then
    local card = context.other_card
    if card.repetition_trigger then
      check_for_unlock{ type = 'retrigger_playing_card', count = card.repetition_trigger }
    end
  end
end

local function check_sell_dice (self, context)
  if context.selling_card then
    local key = context.card.config.center_key
    if 
      key == 'j_oops' or
      key == 'j_pdem_oops_0s' or
      key == 'j_pdem_oops_1s' or
      key == 'j_pdem_oops_3s' or
      key == 'j_pdem_oops_7s' or
      key == 'j_pdem_oops_random'
    then
      inc_career_stat('pdem_dice_sold', 1)
      check_for_unlock({ type = 'career_stat', statname = 'pdem_dice_sold' })
    end
  end
end

local function global_calc_oops_random (self, context)
  if context.card_added and context.card.label == 'j_pdem_oops_random' then
    -- Newly added Oops! All Random; update all tooltips.
    G.GAME.pdem_resetting_oops_random = true
    G.E_MANAGER:add_event(Event({
      trigger = 'immediate',
      func = function()
        pdem_ensure_oops_random_table(true)
        local cards = SMODS.merge_lists({
          G.playing_cards or {},
          G.jokers and G.jokers.cards or {},
          G.consumeables and G.consumeables.cards or {},
          G.vouchers and G.vouchers.cards or {},
          G.shop_jokers and G.shop_jokers.cards or {},
          G.shop_booster and G.shop_booster.cards or {},
          G.shop_vouchers and G.shop_vouchers.cards or {},
          G.pack_cards and G.pack_cards.cards or {},
        })
        for _, card in ipairs(cards) do
          card:generate_UIBox_ability_table(false)
        end
        G.GAME.pdem_resetting_oops_random = nil
        return true
      end
    }))
  elseif SMODS.find_card('j_pdem_oops_random') then
    -- Something changed, so update the affected objects' tooltips.
    if context.setting_ability or context.to_area then
      context.other_card:generate_UIBox_ability_table(false)
    elseif context.card_added or context.modify_shop_card or context.modify_card or context.modify_booster_card then
      context.card:generate_UIBox_ability_table(false)
    end
  end
end

local function track_teuila_blank (self, context)
  if context.using_consumeable then
    local center = context.consumeable.config.center
    if center.set == 'Spectral' or center.set == 'pdem_teuila' then
      G.GAME.pdem_last_spectral_teuila = center.key
    end
  end
end

local function joker_temp_enhancements (self, context)
  if context.other_card.ability.pdem_enhancement then
    return { [context.other_card.ability.pdem_enhancement] = true }
  end
end

local function track_tenbou_condition (self, context)
  if context.using_consumeable then
    local center = context.consumeable.config.center
    if center.set == 'pdem_tenbou' then
      G.GAME.pdem_last_tenbou = center.key
    end
  elseif context.setting_blind then
    G.GAME.pdem_ippatsu = 0
    -- Progress Sakura cooldown.
    G.GAME.pdem_sakura_used = math.max(0, (G.GAME.pdem_sakura_used or 0) - 1)
    sendInfoMessage(G.GAME.pdem_sakura_used, 'sakura cooldown')
  elseif context.end_of_round then
    -- Unblock riichi after last hand of round
    G.GAME.pdem_riichi_blocked = false
  elseif context.press_play then
    -- Block riichi after first hand of round
    G.GAME.pdem_riichi_blocked = true
    G.GAME.pdem_ippatsu = (G.GAME.pdem_ippatsu or 0) + 1
  elseif context.pre_discard then
    -- Block riichi after first discard of round
    G.GAME.pdem_riichi_blocked = true
  elseif context.modify_final_cashout then
    -- Riichi payout
    local ippatsu =  G.GAME.pdem_ippatsu == 1
    G.GAME.pdem_ippatsu = nil
    local cashout_mod = G.GAME.pdem_riichi_count or 0
    G.GAME.pdem_riichi_count = 0
    if G.GAME.pdem_riichi_discards_deducted and G.GAME.pdem_riichi_discards_deducted > 0 then
      ease_discard(G.GAME.pdem_riichi_discards_deducted)
      G.GAME.pdem_riichi_discards_deducted = 0
    end
    if cashout_mod > 0 then
      local payout_total = context.amount
      local riichi_bonus = 0
      local riichi_text = ippatsu
        and localize('pdem_riichi_bonus_ippatsu')
        or localize('pdem_riichi_bonus')

      for _ = 1, cashout_mod do
        local row_amount = math.min(25, payout_total)
        if ippatsu then row_amount = row_amount * 2 end -- Ippatsu bonus
        payout_total = payout_total + row_amount
        riichi_bonus = riichi_bonus + row_amount
      end

      if riichi_bonus > 0 then
        if cashout_mod > 1 then
          return {
            modify = riichi_bonus,
            cashout_row = {
              number = cashout_mod,
              number_colour = G.C.MONEY,
              name = 'pdem_riichi_bonus_custom',
              dollars = riichi_bonus,
              text = ' '..riichi_text,
            }
          }
        else
          return {
            modify = riichi_bonus,
            cashout_row = {
              name = 'pdem_riichi_bonus_custom',
              dollars = riichi_bonus,
              text = riichi_text,
              text_scale = 0.6,
            }
          }
        end
      end
    end
  elseif context.final_scoring_step then
    -- Add chips and xmult
    local chips_mod = (G.GAME.pdem_next_hand_chips or 0)
    local emult_mod = (G.GAME.pdem_next_hand_emult or {})
    G.GAME.pdem_next_hand_chips = 0
    G.GAME.pdem_next_hand_emult = nil
    local result = {}
    if chips_mod > 0 then result.chips = chips_mod end

    local mult = SMODS.Scoring_Parameters.mult.current
    for _, emult in ipairs(emult_mod) do
      mult = mult ^ emult
    end
    if next(emult_mod) then
      SMODS.Scoring_Parameters.mult:modify(mult - SMODS.Scoring_Parameters.mult.current)
    end

    if chips_mod > 0 or next(emult_mod) then return result end
  elseif context.before then
    -- Add hand level
    local level_up_mod = G.GAME.pdem_next_hand_level_up
    G.GAME.pdem_next_hand_level_up = 0
    if level_up_mod and level_up_mod > 0 then
       return { level_up = level_up_mod }
    end
  end
end


SMODS.current_mod.calculate = function (self, context)
  check_retriggers(self, context)
  check_sell_dice(self, context)
  global_calc_oops_random(self, context)
  track_teuila_blank(self, context)

  local result = track_tenbou_condition(self, context)
  if result then return result end

  if context.check_enhancement then
    return joker_temp_enhancements(self, context)
  end
end