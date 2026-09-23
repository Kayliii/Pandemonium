SMODS.Consumable {
  key = 'pulsar',
  set = 'Spectral',
  atlas = 'tarots',
  pos = { x = 2, y = 2 },
  hidden = true,
  soul_set = 'Planet',
  config = { extra = { pdem_pulsar_up = 2, pdem_pulsar_down = 3 } },
  loc_vars = function (self, info_queue, card)
    return { vars = {card.ability.extra.pdem_pulsar_down, card.ability.extra.pdem_pulsar_up} }
  end,
  use = function (self, card, area, copier)
    local most_played = 0
    local upgrade = {}
    local downgrade = {}
    for _, hand in pairs(G.GAME.hands) do
      most_played = math.max(hand.played, most_played)
    end

    for key, hand in pairs(G.GAME.hands) do
      if hand.visible then
        if hand.played == most_played then
          downgrade[key] = math.min(card.ability.extra.pdem_pulsar_down, hand.level - 1)
        else
          table.insert(upgrade, key)
        end
      end
    end

    for key, level in pairs(downgrade) do
      SMODS.upgrade_poker_hands({
        hands = key,
        from = card,
        level_up = -level,
      })
    end

    SMODS.upgrade_poker_hands({
      hands = upgrade,
      from = card,
      level_up = card.ability.extra.pdem_pulsar_up
    })
  end,
  can_use = function (self, card) return true end,
}