SMODS.Suit {
  key = 'joker_suit',
  card_key = 'JOKER',
  lc_ui_atlas = 'ui_assets',
  hc_ui_atlas = 'ui_assets',
  lc_atlas = 'playing_cards_lc',
  hc_atlas = 'playing_cards_hc',
  pos = { y = 5 },
  ui_pos = { x = 0, y = 0 },
  hc_colour = HEX('ff9a00'),
  lc_colour = HEX('ff9a00'),
  in_pool = function () return false end,
  no_mod_badges = true,
  sort_id = 0,
}

SMODS.Rank {
  key = 'joker_rank',
  card_key = 'JOKER',
  lc_atlas = 'playing_cards_lc',
  hc_atlas = 'playing_cards_hc',
  pos = { x = 13 },
  nominal = 0,
  face = false,
  shorthand = '?',
  sort_id = 0,
  strength_effect = { ignore = true },
  no_mod_badges = true,
  in_pool = function () return false end,
}

-- Make sure the jokers suit appears at the end.
for i, s in ipairs(SMODS.Suit.obj_buffer) do
  if s == 'pdem_joker_suit' then
    table.insert(SMODS.Suit.obj_buffer, 1, table.remove(SMODS.Suit.obj_buffer, i))
  end
end

local enhanced_jokers = {
  m_bonus = { x = 1, y = 1 },
  m_mult =  { x = 2, y = 1 },
  m_wild =  { x = 3, y = 1 },
  m_glass = { x = 5, y = 1 },
  m_steel = { x = 6, y = 1 },
  m_stone = { x = 5, y = 0 },
  m_gold =  { x = 6, y = 0 },
  m_lucky = { x = 4, y = 1 },
}

local enhanced_joker_sprites = {

}

SMODS.DrawStep {
  key = 'joker_enhancement',
  order = 2,
  func = function(self, layer)
    if self.ability.pdem_enhancement then
      local pos = enhanced_jokers[self.ability.pdem_enhancement]
      if pos then
        enhanced_joker_sprites[self.ability.pdem_enhancement] =
          enhanced_joker_sprites[self.ability.pdem_enhancement] or
          SMODS.create_sprite(0, 0, G.CARD_W, G.CARD_H, 'pdem_enhancers', pos)
        local sprite = enhanced_joker_sprites[self.ability.pdem_enhancement]
        if sprite then
          local mask_sprite = self.children.center
          love.graphics.push()
          love.graphics.origin()
          local maskCanvas = love.graphics.newCanvas(71, 95)
          local old_canvas = love.graphics.getCanvas()
          love.graphics.setCanvas(maskCanvas)
          love.graphics.clear(0, 0, 0, 0)
          love.graphics.draw(
            mask_sprite.atlas.image,
            mask_sprite.sprite,
            0 ,0,
            0,
            self.VT.w/(self.T.w),
            self.VT.h/(self.T.h)
          )
          love.graphics.pop()
          love.graphics.setCanvas(old_canvas)
          G.SHADERS['pdem_clip']:send('clip_texture', maskCanvas)
          sprite.role.draw_major = self
          sprite:draw_shader('pdem_clip', nil, nil, nil, self.children.center)
        end
      end
    end
  end,
  conditions = { vortex = false, facing = 'front' },
}