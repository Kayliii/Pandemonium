local PANDEMONIUM = SMODS.current_mod

function SMODS.current_mod.save_config (self)
  SMODS.save_mod_config(self)
end

local function ui_node (type, config, nodes)
  return { n = type, config = config, nodes = nodes }
end

local function config_tab ()
  local root_style = { r = 0.1, minw = 4, align = "tm", padding = 0.2, colour = G.C.BLACK }
  local col_style = { r = 0.1, minw = 4, align = "tl", padding = 0.2, colour = G.C.BLACK }
  local row_style = { align = "cm", r = 0.1, emboss = 0.1, outline = 1, padding = 0.14 }

  return (
    ui_node(G.UIT.ROOT, root_style, {
      ui_node(G.UIT.C, col_style, {
        ui_node(G.UIT.R, row_style, {
          create_toggle({
            label = G.localization.misc.dictionary.pdem_shut_up,
            info = {
              G.localization.misc.dictionary.pdem_shut_up_desc_1,
              G.localization.misc.dictionary.pdem_shut_up_desc_2,
              G.localization.misc.dictionary.pdem_shut_up_desc_3,
              G.localization.misc.dictionary.pdem_shut_up_desc_4,
              G.localization.misc.dictionary.pdem_shut_up_desc_5,
              G.localization.misc.dictionary.pdem_shut_up_desc_6,
              G.localization.misc.dictionary.pdem_shut_up_desc_7,
              G.localization.misc.dictionary.pdem_shut_up_desc_8,
              G.localization.misc.dictionary.pdem_shut_up_desc_9,
            },
            ref_table = PANDEMONIUM.config,
            ref_value = 'shut_him_up',
          })
        }),
        ui_node(G.UIT.R, row_style, {
          create_toggle({
            label = G.localization.misc.dictionary.pdem_filter_profanity,
            info = {},
            ref_table = PANDEMONIUM.config,
            ref_value = 'filter_profanity',
          })
        }),
        ui_node(G.UIT.R, row_style, {
          create_toggle({
            label = G.localization.misc.dictionary.pdem_custom_menu,
            info = {},
            ref_table = PANDEMONIUM.config,
            ref_value = 'custom_menu',
          })
        })
      })
    })
  )
end

SMODS.current_mod.config_tab = config_tab
