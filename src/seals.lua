local teuila_secondary_color = HEX('3b8c3b')

-- Green Seal
SMODS.Seal {
  key = 'green',
  atlas = 'enhancers',
  pos = { x = 2, y = 0 },
  badge_colour = teuila_secondary_color,
  calculate = function(self, card, context)
    if context.playing_card_end_of_round and context.cardarea == G.hand and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
      G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
      G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 0.0,
        func = function()
          SMODS.add_card({ set = 'pdem_teuila' })
          G.GAME.consumeable_buffer = 0
          return true
        end
      }))
      return { message = localize('k_pdem_plus_teuila'), colour = teuila_secondary_color }
    end
  end
}