-- Peel Tag
-- Removes a random sticker from a joker.
SMODS.Tag {
  key = "peel",
  atlas = "pdem_tags",
  pos = { x = 0, y = 0 },
  in_pool = function ()
    return (
      G.GAME.modifiers.enable_pdem_gold_star or
      G.GAME.modifiers.enable_perishables_in_shop or
      G.GAME.modifiers.enable_rentals_in_shop or
      G.GAME.modifiers.enable_eternals_in_shop
    )
  end,
  apply = function(self, tag, context)
    if context.type == 'immediate' then
      local sticker_list = {}
      for _, joker in ipairs(G.jokers.cards) do
        for k, _ in pairs(SMODS.Stickers) do
          if joker.ability[k] and joker.ability[k] ~= 'pdem_peel' then
            table.insert(sticker_list, { joker = joker, sticker = k, sort_id = joker.sort_id })
          end
        end
      end

      if #sticker_list > 0 then
        local selection = pseudorandom_element(sticker_list, pseudoseed('pdem_peel_tag'))
        selection.joker.ability[selection.sticker] = 'pdem_peel'
        tag:yep('+', G.C.BLUE, function ()
          selection.joker:remove_sticker(selection.sticker)
          play_sound('cardFan2', 1.5, 1.8)
          selection.joker:juice_up()
          return true
        end)
      else
        tag:nope()
      end
      tag.triggered = true
    end
  end
}