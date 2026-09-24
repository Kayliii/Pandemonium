

--[[local function print_cards (cards)
  local str = ''
  for _, card in ipairs(cards) do
    str = str .. '"' .. card.base.value .. ' of ' .. card.base.suit .. '", '
  end
  sendInfoMessage(str, 'print_cards')
end]]


SMODS.Back {
  name = 'Test Deck',
  key = "test",
  loc_txt = {
    name = 'Test Deck',
    text = {
      "A deck for testing",
    },
  },
  atlas = "main",
  pos = { x = 0, y = 0 },
  config = {
    dollars = 999999999999, hands = 999, discards = 99, joker_slot = 200,
    --[[spectral_rate = 4,]] consumables = { 'c_soul', 'c_pdem_pulsar' },
    jokers = {
      --{ id = 'j_pdem_luigi' },
      --{ id = 'j_pdem_longjoker' },
    },
    vouchers = {
      'v_directors_cut', 'v_retcon',
      'v_overstock_norm', 'v_overstock_plus',
    }
  },
}

local make_deck = function ()
  local res = {}
  for _, suit in ipairs({ 'C', 'H', --[['D', 'S']] }) do
    for _, rank in ipairs({ '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A' }) do
      table.insert(res, { s = suit, r = rank })
      table.insert(res, { s = suit, r = rank })
      table.insert(res, { s = suit, r = rank })
      table.insert(res, { s = suit, r = rank })
    end
  end
  return res
end


SMODS.Challenge {
  key = "luigi_test",
  jokers = {
    { id = 'j_pdem_john_balatro' },
    { id = 'j_sock_and_buskin' },
    { id = 'j_pdem_balancing_act' },
    --{ id = 'j_hanging_chad' },
    --{ id = 'j_hanging_chad' },
    --{ id = 'j_hanging_chad' },
    { id = 'j_pdem_long_joker' },
    { id = 'j_pdem_long_joker' },
    { id = 'j_pdem_long_joker' },
    { id = 'j_pdem_long_joker' },
    { id = 'j_pdem_long_joker' },
    { id = 'j_pdem_long_joker' },
    { id = 'j_pdem_long_joker' },
    { id = 'j_pdem_long_joker' },
    { id = 'j_pdem_long_joker' },
    { id = 'j_pdem_long_joker' },
    { id = 'j_pdem_long_joker' },
    { id = 'j_four_fingers' },
    --{ id = 'j_blueprint' },
    { id = 'j_pdem_flipped' },
    --{ id = 'j_space' },
    --{ id = 'j_oops' },
    --{ id = 'j_oops' },
    --{ id = 'j_pdem_oops_7s' },
    --{ id = 'j_cavendish' },
    { id = 'j_pdem_luigi' },
    { id = 'j_pdem_pointer' },
    { id = 'j_pdem_oops_random' },
  },
  rules = {
    modifiers = {
      { id = 'hand_size', value = 60 },
      { id = 'hands', value = 999 },
      { id = 'discards', value = 99 },
      { id = 'joker_slots', value = 99 },
      { id = 'dollars', value = 999999999999 },
    },
    custom = {
      { id = 'pdem_showdown_only' },
    },
  },
  restrictions = {
    banned_tags = {
      { id = 'tag_uncommon' },
      { id = 'tag_rare' },
      { id = 'tag_negative' },
      { id = 'tag_foil' },
      { id = 'tag_holo' },
      { id = 'tag_polychrome' },
      { id = 'tag_investment' },
      { id = 'tag_voucher' },
      { id = 'tag_boss' },
      { id = 'tag_handy' },
      { id = 'tag_garbage' },
      --{ id = 'tag_ethereal' },
      { id = 'tag_coupon' },
      --{ id = 'tag_double' },
      --{ id = 'tag_juggle' },
      { id = 'tag_d_six' },
      --{ id = 'tag_top_up' },
      --{ id = 'tag_skip' },
      --{ id = 'tag_charm' },
      --{ id = 'tag_meteor' },
      --{ id = 'tag_economy' },
    },
  },
  deck = {
    type = 'Challenge Deck',
    cards = make_deck()
  }
}












function SMODS.scale_card(card, args)
    if not G.deck then return end
    if not args.operation then args.operation = "+" end
    
    args.block_overrides = args.block_overrides or {}
    args.ref_table = args.ref_table or card.ability.extra

    args.scalar_table = args.scalar_table or args.ref_table
    if not args.scalar_value then
        args.scalar_value = "SMODS_scalar_"..args.ref_value
        args.scalar_table[args.scalar_value] = 1
    end
    args.scalar_factor = args.scalar_factor or 1
    args.scaling_card = true
    args.card = card
    args.value = args.ref_table[args.ref_value]
    args.scalar = args.scalar_table[args.scalar_value]
    if args.operation == '-' and args.scalar < 0 then args.scalar = -args.scalar end

    sendInfoMessage(tostring(args.ref_table == card.ability), 'table identity(start)')

    local flags = SMODS.calculate_context(args)
    local value, change = args.value, args.scalar * args.scalar_factor

    sendInfoMessage(tostring(args.ref_table == card.ability), 'table identity(end)')

    if type(args.operation) == 'function' then
        --sendInfoMessage('path 1')
        args.operation(args.ref_table, args.ref_value, value, change)
    elseif args.operation == 'X' then
        --sendInfoMessage('path 2')
        SMODS.multiplicative_scaling(args.ref_table, args.ref_value, value, change)
    elseif args.operation == '-' then
        --sendInfoMessage('path 3')
        SMODS.additive_scaling(args.ref_table, args.ref_value, value, -change)
    else
        --sendInfoMessage('path 4')
        SMODS.additive_scaling(args.ref_table, args.ref_value, value, change)
    end

    args.scaling_message = SMODS.merge_defaults(args.scaling_message, {
        message = localize(args.message_key and {type='variable',key=args.message_key,vars={args.message_key =='a_xmult' and args.ref_table[args.ref_value] or change}} or 'k_upgrade_ex'),
        colour = args.message_colour or G.C.FILTER,
        delay = args.message_delay,
    })
    if next(args.scaling_message) and not args.no_message then
        --sendInfoMessage('path 5')
        SMODS.calculate_effect(args.scaling_message, card)
    end

    for _, ret in ipairs(flags.post_effects or {}) do
        SMODS.calculate_effect(ret, ret.source)
    end
    --sendInfoMessage(args.ref_table[args.ref_value], 'result[1]')
    --sendInfoMessage(change, 'result[2]')
    --sendInfoMessage(args.ref_table[args.ref_value], 'result')
    --sendInfoMessage(inspect(args.ref_table), 'ability')
    --sendInfoMessage(inspect(card.ability), 'ability(alt)')
    --sendInfoMessage(inspect(card.ability.extra), 'ability(alt2)')
    
    return args.ref_table[args.ref_value], change
end