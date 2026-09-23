-- Gold Star
-- Can only have one Gold Star joker at a time.
SMODS.Sticker{
  key = "gold_star",
  name = "Gold Star",
  atlas = "pdem_sticker",
  pos = { x = 0, y = 0 },
  needs_enable_flag = true,
  rate = 0.1,
  badge_colour = HEX 'e3b448',
  config = {},
  should_apply = function(self, card, center, area, bypass_roll)
    if area == G.shop_jokers then
      return (
        G.GAME.modifiers.enable_pdem_gold_star and
        SMODS.Sticker.should_apply(self, card, center, area, bypass_roll)
      )
    end
  end,
}