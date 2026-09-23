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

SMODS.current_mod.calculate = function (self, context)
  check_retriggers(self, context)
  check_sell_dice(self, context)
  global_calc_oops_random(self, context)
  track_teuila_blank(self, context)

  if context.check_enhancement then
    return joker_temp_enhancements(self, context)
  end
end