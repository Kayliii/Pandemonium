local function redeem_plus_play_or_discard_size_voucher (card)
  local bonus_limit = card.ability.extra.pdem_bonus_limit
  SMODS.change_play_limit(bonus_limit)
  SMODS.change_discard_limit(bonus_limit)

  SMODS.calculate_effect({
    message = localize{ type = 'variable', key = 'pdem_bonus_play', vars = {bonus_limit} },
    message_card = card,
    colour = G.C.BLUE,
    delay = 0.4
  }, card, nil)
  SMODS.calculate_effect({
    message = localize{ type = 'variable', key = 'pdem_bonus_discard', vars = {bonus_limit} },
    message_card = card,
    colour = G.C.RED,
    delay = 0.4
  }, card, nil)
end


SMODS.Voucher {
  key = 'loaded_palm',
  pos = { x = 0, y = 0 },
  config = { extra = { pdem_bonus_limit = 1 } },
  unlocked = true,
  atlas = 'vouchers',
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.pdem_bonus_limit } }
  end,
  redeem = function(self, card) redeem_plus_play_or_discard_size_voucher(card) end,
}

SMODS.Voucher {
  key = 'loaded_sleeve',
  pos = { x = 0, y = 1 },
  config = { extra = { pdem_bonus_limit = 1 }, pdem_unlock_total = 25, pdem_unlock_size = 6 },
  unlocked = false,
  requires = { 'v_pdem_loaded_palm' },
  atlas = 'vouchers',
  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.pdem_bonus_limit} }
  end,
  locked_loc_vars = function(self, info_queue, card)
    return { vars = {
      self.config.pdem_unlock_total,
      self.config.pdem_unlock_size,
      G.PROFILES[G.SETTINGS.profile].career_stats['pdem_played_' .. tostring(self.config.pdem_unlock_size) .. '_plus'] or 0
    } }
  end,
  redeem = function(self, card) redeem_plus_play_or_discard_size_voucher(card) end,
  check_for_unlock = function(self, args)
    if args.type == 'career_stat' and args.statname == 'pdem_played_' .. tostring(self.config.pdem_unlock_size) .. '_plus' then
      return G.PROFILES[G.SETTINGS.profile].career_stats[args.statname] >= self.config.pdem_unlock_total
    end
  end
}