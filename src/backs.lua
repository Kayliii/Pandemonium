-- Riff Raff Deck
SMODS.Back {
  key = "riff_raff",
  atlas = "enhancers",
  pos = { x = 1, y = 0 },
  config = {},
  unlocked = false,
  check_for_unlock = function (self, args)
    return args.type == 'pdem_teuila_gate'

  end,
  apply = function (self, back)
    G.E_MANAGER:add_event(Event({
      func = function()
        for i = #G.playing_cards, 1, -1 do G.playing_cards[i]:remove() end
        for _ = 1, 52 do
          local card = SMODS.create_card({
            set = 'Joker',
            area = G.deck,
            rarity = 'Common',
            skip_materialize = true,
            no_edition = true,
            allow_duplicates = true,
            bypass_discovery_center = true,
            discover = false,
          })
          SMODS.change_base(card, 'pdem_joker_suit', 'pdem_joker_rank')
          SMODS.add_to_deck(card, {
            playing_card = -100,
            area = G.deck
          })
        end
        return true
      end
    }))
  end
}