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

SMODS.Tag {
  key = "tenbou_tag",
  atlas = "pdem_tags",
  pos = { x = 1, y = 0 },
  in_pool = true,
  apply = function(self, tag, context)
    if context.type == 'new_blind_choice' then
      local lock = tag.ID
      G.CONTROLLER.locks[lock] = true
      tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
        local booster = SMODS.create_card { key = 'p_pdem_tenbou_normal_1', area = G.play }
        booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
        booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
        booster.T.w = G.CARD_W * 1.27
        booster.T.h = G.CARD_H * 1.27
        booster.cost = 0
        booster.from_tag = true
        G.FUNCS.use_card({ config = { ref_table = booster } })
        booster:start_materialize()
        G.CONTROLLER.locks[lock] = nil
        return true
      end)
      tag.triggered = true
      return true
    end
  end
}