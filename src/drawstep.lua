SMODS.DrawSteps['shadow'].func = function(self)
  self.ARGS.send_to_shader = self.ARGS.send_to_shader or {}
  self.ARGS.send_to_shader[1] = math.min(self.VT.r*3, 1) + math.sin(G.TIMERS.REAL/28) + 1 + (self.juice and self.juice.r*20 or 0) + self.tilt_var.amt
  self.ARGS.send_to_shader[2] = G.TIMERS.REAL

  local s_frac = self.ability.pdem_shadow_height_mod or 1
  for k, v in pairs(self.children) do
    v.VT.scale = self.VT.scale
  end

  G.shared_shadow = self.sprite_facing == 'front' and self.children.center or self.children.back

  --Draw the shadow
  if not self.no_shadow and G.SETTINGS.GRAPHICS.shadows == 'On' and((self.ability.effect ~= 'Glass Card' and not self.greyed and self:should_draw_shadow() ) and ((self.area and self.area ~= G.discard and self.area.config.type ~= 'deck') or not self.area or self.states.drag.is)) then
      self.shadow_height = 0*(0.08 + 0.4*math.sqrt(self.velocity.x^2)) + (((((self.highlighted or self.ability.pdem_shadow_height_mod) and self.area == G.play) or self.states.drag.is) and 0.35 * s_frac) or (self.area and self.area.config.type == 'title_2') and 0.04 or 0.1)
      G.shared_shadow:draw_shader('dissolve', self.shadow_height)
  end
end