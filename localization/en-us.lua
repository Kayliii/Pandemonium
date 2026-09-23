return {
  descriptions = {
    Back = {
      b_pdem_riff_raff = {
        name = "Riff-Raff Deck",
        text = {
          "Start run with",
          "{C:attention}52{} random",
          "{C:blue}Common{} {C:attention}Jokers{}",
          "in your deck"
        },
        unlock = {
          "{E:1,s:1.3}?????",
        }
      }
    },
    Planet = {
      c_pdem_void = {
        name = 'Void',
        text = {
          "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
          "{C:attention}#2#",
          "{C:mult}+#3#{} Mult and",
          "{C:chips}+#4#{} chips",
        },
      },
      c_pdem_phobos = {
        name = 'Phobos',
        text = {
          "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
          "{C:attention}#2#",
          "{C:mult}+#3#{} Mult and",
          "{C:chips}+#4#{} chips",
        },
      },
      c_pdem_deimos = {
        name = 'Deimos',
        text = {
          "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
          "{C:attention}#2#",
          "{C:mult}+#3#{} Mult and",
          "{C:chips}+#4#{} chips",
        },
      },
      c_pdem_titan = {
        name = 'Titan',
        text = {
          "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
          "{C:attention}#2#",
          "{C:mult}+#3#{} Mult and",
          "{C:chips}+#4#{} chips",
        },
      },
      c_pdem_triton = {
        name = 'Triton',
        text = {
          "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
          "{C:attention}#2#",
          "{C:mult}+#3#{} Mult and",
          "{C:chips}+#4#{} chips",
        },
      },
      c_pdem_io = {
        name = 'Io',
        text = {
          "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
          "{C:attention}#2#",
          "{C:mult}+#3#{} Mult and",
          "{C:chips}+#4#{} chips",
        },
      },
      c_pdem_europa = {
        name = 'Europa',
        text = {
          "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
          "{C:attention}#2#",
          "{C:mult}+#3#{} Mult and",
          "{C:chips}+#4#{} chips",
        },
      },
      c_pdem_teapot = {
        name = 'Teapot',
        text = {
          "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
          "{C:attention}#2#",
          "{C:mult}+#3#{} Mult and",
          "{C:chips}+#4#{} chips",
        },
      },
    },
    Spectral = {
      c_pdem_pulsar = {
        name = 'Pulsar',
        text = {
          "Downgrade most played",
          "{C:legendary,E:1}poker hand{} by {C:attention}#1#{} levels",
          "Upgrade every other",
          "{C:legendary,E:1}poker hand{} by {C:attention}#2#{} levels",
        },
      },
    },
    Joker = {
      j_four_fingers = {
        name = 'Four Fingers',
        text = {
          'All {C:attention}Flushes{} and',
          '{C:attention}Straights{} can be',
          'made with {C:attention}1{} less',
          'card than usual',
        },
      },
      j_pdem_peppy = {
        name = 'Peppy Joker',
        text = {
          '{C:mult}+#1#{} Mult whenever an',
          'adjacent Joker activates',
        },
      },
      j_pdem_keen = {
        name = 'Keen Joker',
        text = {
          '{C:chips}+#1#{} Chips whenever an',
          'adjacent Joker activates',
        },
      },
      j_pdem_luigi = {
        name = 'Luigi',
        text = {
          'Does {C:attention}nothing{}',
          'for every card',
          '{C:inactive}({}{C:attention}played{}{C:inactive} or',
          '{C:attention}held in hand{}{C:inactive}){}',
        },
        unlock = {
          '{E:1,s:1.3}?????',
        },
        
      },
      j_pdem_john_balatro = {
        name = 'John Balatro',
        text = {
          'Regular {C:attention}Boss Blinds{}',
          'can be skipped',
        },
        unlock = {
          '{E:1,s:1.3}?????',
        },
      },
      j_pdem_laurel_hardy = {
        name = 'Laurel and Hardy',
        text = {
          '',
        },
        unlock = {
          '{E:1,s:1.3}?????',
        },
      },
      j_pdem_marty = {
        name = 'Marty',
        text = {
          'Sell this card at',
          'start of {C:attention}Ante{} to',
          'set Ante to {C:attention}#1#{}',
        },
        unlock = {
          '{E:1,s:1.3}?????',
        },
      },
      j_pdem_long_joker = {
        name = 'Long Joker',
        text = {
          '{C:attention}Play{} or {C:attention}discard{}',
          'up to {C:attention}1{} extra card',
        },
        unlock = {
          'Have at least',
          '{C:attention}80{} cards',
          'in your deck',
        },
      },
      j_pdem_recycled_joker = {
        name = 'Recycled Joker',
        text = {
          '{C:attention}Discarded{} cards are',
          'returned to your {C:attention}deck{}',
        },
        unlock = {
          'Destroy a total of',
          '{C:attention}#1#{} playing cards',
          "{C:inactive}(#2#)",
        },
      },
      j_pdem_pointer = {
        name = 'Joker Poker',
        text = {
          'Gains {C:attention}+#1#{} charge for',
          'every activation of the',
          '{C:attention}Joker{} to the left',
          'Consumes all charges to',
          'retrigger the {C:attention}Joker{} to',
          'the right once per charge',
          '{C:inactive}(Currently {C:attention}#2#{}{C:inactive} charges)',
        },
        unlock = {
          'Retrigger one card',
          '{C:attention}#1#{} times', --5
          'in one hand'
        },
      },
      j_pdem_oops_0s = {
        name = 'Oops! All Naughts',
        text = {
          'Nullifies all {C:attention}listed{}',
          '{C:green,E:1,S:1.1}probabilities{}',
          '{C:inactive}(ex: {C:green}#1# in #2#{C:inactive} -> {C:green}#3# in #4#{C:inactive})',
        },
        unlock = {
          'Get extremely',
          'unlucky', -- i.e. hit the 1/1000 on Cavendish
        },
      },
      j_pdem_oops_1s = {
        name = 'Oops! All 1s',
        text={
          'Halves all {C:attention}listed{}',
          '{C:green,E:1,S:1.1}probabilities{}',
          '{C:inactive}(ex: {C:green}#1# in #2#{C:inactive} -> {C:green}#3# in #4#{C:inactive})',
        },
        unlock = {
          "In one hand,",
          "earn at most",
          "{E:1,C:attention}#1#{} chips", -- Intended to be negative
        },
      },
      j_pdem_oops_random = {
        name = 'Oops! All Random',
        text={
          'Randomizes all {C:attention}listed{}',
          '{C:green,E:1,S:1.1}probabilities{}',
          '{C:inactive}(ex: {C:green}#1# in #2#{C:inactive} -> {C:green}#3# in #4#{C:inactive})',
        },
        unlock = {
          'Roll a {C:green,E:1,S:1.1}probability{}',
          'with odds greater',
          'than {C:green}1 in 1'
        },
      },
      j_pdem_oops_3s = {
        name = 'Oops! All 3s',
        text={
          'All {C:attention}listed{}',
          '{C:green,E:1,S:1.1}probabilities{}',
          'are {C:green}#1# in #2#',
        },
        unlock = {
          "Sell a total of",
          "{C:attention}10{} dice-themed Jokers",
          "{C:inactive}(#2#)",
        },
      },
      j_oops = {
        name = 'Oops! All 6s',
        text={
          "Doubles all {C:attention}listed",
          "{C:green,E:1,S:1.1}probabilities",
          "{C:inactive}(ex: {C:green}#1# in #2#{C:inactive} -> {C:green}#3# in #4#{C:inactive})",
        },
      },
      j_pdem_oops_7s = {
        name = 'Oops! All 7s',
        text={
          'Guarantees all {C:attention}listed{}',
          '{C:green,E:1,S:1.1}probabilities{} not',
          'on playing cards',
          '{C:inactive}(ex: {C:green}#1# in #2#{C:inactive} -> {C:green}#3# in #4#{C:inactive})',
        },
        unlock = {
          'Get very lucky', -- i.e. hit both effects on a lucky card on the same activation
        },
      },
      j_pdem_flipped = {
        name = 'Flipped Joker',
        text={
          'Scores an additional',
          '{C:attention}poker hand{} from',
          '{C:attention}unscored{} cards'
        },
        unlock = {
          'Defeat {C:attention}Amber Acorn{}',
          'in Ante {C:attention}16{} or above',
        },
      },
      j_pdem_balancing_act = {
        name = 'Balancing Act',
        text={
          'Alternates between',
          'permanently adding and',
          'removing {C:mult}#1#{} Mult',
          'from {C:attention}scored cards{}',
        },
        unlock = {
          '',
        },
      },
    },
    Blind = {
      bl_pdem_reed = {
        name = 'The Sedge',
        text = {
          '{C:attention}#1#{}',
          'is debuffed this hand'
        },
      },
      bl_pdem_wick = {
        name = 'The Wick',
        text = {
          'Hands and discards are',
          'averaged and linked'
        },
      },
      bl_pdem_lasso = {
        name = 'The Cord',
        text = {
          'Scored ranks / suits are',
          'debuffed after each hand',
        },
      },
      bl_pdem_owl = {
        name = 'The Owl',
        text = {
          'Switches hands',
          'with discards'
        },
      },
      bl_pdem_sieve = {
        name = 'The Sieve',
        text = {
          'Hand must only',
          'contain 1 suit'
        },
      },
      bl_pdem_crown = {
        name = 'Tyrian Crown',
        text = {
          'Each played or scored',
          'card raises blind by #1#'
        },
      },
      bl_pdem_horn = {
        name = 'Fulvous Horn',
        text = {
          'Played hand must beat',
          'current chip total'
        },
      },
      bl_pdem_key = {
        name = 'Malachite Key',
        text = {
          'Clearing blind early',
          'resets total chips'
        },
      },
      bl_pdem_wand = {
        name = 'Argent Wand',
        text = {
          'Discards 1 played card',
          'for each hand remaining'
        },
      },
      bl_pdem_rose = {
        name = 'Ebony Rose',
        text = {
          'Jokers trigger',
          'only once per hand'
        },
      },
    },
    Voucher = {
      v_pdem_loaded_palm = {
        name="Loaded Palm",
        text={
          '{C:attention}+#1#{} max cards {C:attention,E:1}played',
          '{C:attention}+#1#{} max cards {C:attention,E:1}discarded',
        },
      },
      v_pdem_loaded_sleeve = {
        name="Loaded Sleeve",
        text={
          '{C:attention}+#1#{} max cards {C:attention,E:1}played',
          '{C:attention}+#1#{} max cards {C:attention,E:1}discarded',
        },
        unlock={
          'Play {C:attention}#2#{} or more',
          'cards a total',
          'of {C:attention}#1#{} times',
          '{C:inactive}(#3#)'
        },
      },
    },
    Stake = {
      stake_red={
        name="Red Stake",
        text={
          "Shop can have",
          "{C:attention}Star{} Jokers",
          "{C:inactive,s:0.8}(Limited to {C:attention,s:0.8}1{C:inactive,s:0.8} at a time)",
          "{s:0.4}",
          "{C:attention}Small Blind{} gives",
          "no reward money",
          "{s:0.8}Applies all previous Stakes",
        },
      },
    },
    Tag = {
      tag_pdem_peel = {
        name="Peel Tag",
        text={
          "Removes a random",
          "{C:attention}Sticker{} from",
          "your {C:attention}Jokers",
        },
      },
    },
    pdem_teuila = {
      c_pdem_te_eye = {
        name = 'Eye',
        text = {
          'Move an edition',
          'from a {C:attention}random{} Joker',
          'to {C:attention}#1#{} selected Joker'
        }
      },
      c_pdem_te_gate = {
        name = 'Open Gate',
        text = {
          'Send {C:attention}#1#{} selected',
          '{C:attention}Joker{} to your {C:attention}deck{}',
        }
      },
      c_pdem_te_laurel = {
        name = 'Laurel Crown',
        text = {
          'Makes {C:attention}#1#{} selected',
          'compatible Joker',
          '{C:attention}#2#',
        }
      },
      c_pdem_te_blank = {
        name = "Fate",
        text = {
          'Creates the last',
          '{C:pdem_teuila}Teuila{} or {C:spectral}Spectral{} card',
          'used during this run',
          '{s:0.8,C:pdem_teuila}Fate{s:0.8} excluded',
        },
      },
      c_pdem_te_wheel = {
        name = "Wheel",
        text = {
          'Select {C:attention}#1#{} Joker,',
          'convert the {C:attention}selected{} Joker',
          'into the {C:attention}leftmost{} Joker',
          '{C:inactive}(Drag to rearrange)',
        },
      }
    },
    Other = {
      pdem_gold_star = {
        name = 'Star',
        text = {
          'You only have',
          'room for {C:attention}1{}',
          'Star at a time',
        }
      },
      pdem_green_seal = {
        name = 'Green Seal',
        text = {
          'Creates a {C:teuila}Teuila{} card',
          'at end of round',
          'if {C:attention}held{} in hand',
          '{C:inactive}(Must have room)',
        }
      },
      undiscovered_pdem_teuila = {
        name = "Not Discovered",
        text = {
          "Purchase or use",
          "this card in an",
          "unseeded run to",
          "learn what it does",
        },
      }
    }
  },
  misc = {
    challenge_names = {
      c_pdem_luigi = 'Luigi Wins By Doing Nothing',
      c_pdem_recycled = 'Waste Not',
      c_pdem_one_man = 'One-Man Army',
      c_pdem_showdown = 'Showdown',
    },
    labels = {
      pdem_gold_star = 'Gold Star',
      pdem_antique = 'Antique',
      pdem_infected = 'Infected',
      pdem_lazy = 'Lazy',
      pdem_big = 'Big',
      pdem_blank = 'Blank',
      pdem_addicted = 'Addicted',
      pdem_jumpy = 'Jumpy',
      pdem_pessimist = 'Pessimist',
      pdem_prankster = 'Prankster',
      pdem_fated = 'Fated',
      pdem_teuila = 'Teuila',
      pdem_green_seal = 'Green Seal',
    },
    poker_hands = {
      pdem_x_of_y_kinds = '#1# of #2# Kinds',
      pdem_y_pair = '#2# Pair',
      pdem_x_of_a_kind = '#1# of a Kind',
      pdem_none = 'None',
      pdem_too_many_pairs = 'Too Many Pairs',
      pdem_six_of_a_kind = 'Six of a Kind',
      pdem_frick_of_a_kind = 'Frick You of a Kind',
      pdem_fuck_of_a_kind = 'Fuck You of a Kind',
      pdem_flush_six = 'Flush Six',
      pdem_flush_frick = 'Flush Frick You',
      pdem_flush_fuck = 'Flush Fuck You',
      pdem_full_straight = 'Full Straight',
      pdem_full_straight_flush = 'Full Flush',
      pdem_oops_all_jokers = 'Oops! All Jokers',
    },
    poker_hand_descriptions={
      pdem_none = {
        'Play 0 scoring cards',
        'What did you do???',
      },
      pdem_too_many_pairs = {
        '3 or more pairs with',
        'a different rank for each pair'
      },
      pdem_six_of_a_kind = {
        '6 cards with the same rank'
      },
      pdem_flush_six = {
        '6 cards with the same rank and suit'
      },
      pdem_frick_of_a_kind = {
        '7 or more cards with the same rank'
      },
      pdem_flush_frick = {
        '7 or more cards with',
        'the same rank and suit'
      },
      pdem_fuck_of_a_kind = {
        '7 or more cards with the same rank'
      },
      pdem_flush_fuck = {
        '7 or more cards with',
        'the same rank and suit'
      },
      pdem_full_straight = {
        '1 card of every rank',
      },
      pdem_full_straight_flush = {
        '1 card of every rank with',
        'all cards sharing the same suit',
      },
      pdem_oops_all_jokers = {
        '5 or more Joker cards',
      },
    },
    v_text={
      ch_c_pdem_showdown_only={
        'All {C:attention}Boss Blinds{} are {C:attention}Showdown Blinds{}'
      },
      ch_c_pdem_showdown_smaller_reward={
        'All {C:attention}Showdown Blinds{} give less reward money{}'
      },
    },
    dictionary = {
      pdem_shut_up = 'Shut The Him Up',
      pdem_shut_up_desc_1 = "For legal reasons, we are unable",
      pdem_shut_up_desc_2 = "to provide a formal guarantee that",
      pdem_shut_up_desc_3 = "making use of our famous 'Shut The",
      pdem_shut_up_desc_4 = "Him Up' menu option will have the",
      pdem_shut_up_desc_5 = "desired effect. Refer to the EULA",
      pdem_shut_up_desc_6 = "for more information.",
      pdem_skip_boss_blind = 'Up the Ante',
      pdem_filter_profanity = 'Remove Profanity',
      pdem_custom_menu = 'Modded Menu',

      pdem_too_many_pairs = 'Too Many Pairs',
      pdem_frick_of_a_kind = 'Frick You of a Kind',
      pdem_fuck_of_a_kind = 'Fuck You of a Kind',

      pdem_flush_frick = 'Flush You Of a Kind',
      pdem_flush_fuck = 'Flush You Of a Kind',

      pdem_flush_plus_char = 'u',
      pdem_straight_plus_char = 'a',
      pdem_straight_flush_plus_char_1 = 'a',
      pdem_straight_flush_plus_char_2 = 'u',
      pdem_straight_flush_plus_char_3 = 'u', -- Royal
      pdem_flush_house_plus_char = 'u',

      pdem_downgrade_ex = "Downgrade!",
      pdem_hi = 'hi',
      pdem_upgrade_next = "Next: Upgrade",
      pdem_downgrade_next = "Next: Downgrade",
      k_pdem_teuila = "Teuila",
      k_pdem_jokers = "Jokers",
      b_pdem_teuila_cards = "Teuila Cards",
      k_pdem_plus_teuila = "+1 Teuila",

      pdem_space_debris = "Debris",
      pdem_moon = "Moon",
      pdem_not_a_planet = 'No Planets?',
      pdem_luigi = 'Luigi',
      pdem_random_hand = '(random poker hand)',
      pdem_score_placeholder = '(chips)',
      pdem_active = 'Active',
      pdem_inactive = 'Inactive',
      pdem_number_0 = 'Zero',
      pdem_number_1 = 'One',
      pdem_number_2 = 'Two',
      pdem_number_3 = 'Three',
      pdem_number_4 = 'Four',
      pdem_number_5 = 'Five',
      pdem_number_6 = 'Six',
      pdem_number_7 = 'Seven',
      pdem_number_8 = 'Eight',
      pdem_number_9 = 'Nine',
      pdem_number_10 = 'Ten',
      pdem_number_11 = 'Eleven',
      pdem_number_12 = 'Twelve',
      pdem_number_13 = 'Thirteen',
      pdem_number_14 = 'Fourteen',
      pdem_number_15 = 'Fifteen',
      pdem_number_16 = 'Sixteen',
      pdem_number_17 = 'Seventeen',
      pdem_number_18 = 'Eighteen',
      pdem_number_19 = 'Nineteen',
      pdem_number_20 = 'Twenty',
      pdem_number_21 = 'Twenty-one',
      pdem_number_22 = 'Twenty-two',
      pdem_number_23 = 'Twenty-three',
      pdem_number_24 = 'Twenty-four',
      pdem_number_25 = 'Twenty-five',
      pdem_number_26 = 'Twenty-six',
      pdem_number_27 = 'Twenty-seven',
      pdem_number_28 = 'Twenty-eight',
      pdem_number_29 = 'Twenty-nine',
      pdem_number_30 = 'Thirty',
      pdem_number_31 = 'Thirty-one',
      pdem_number_32 = 'Thirty-two',
      pdem_number_33 = 'Thirty-three',
      pdem_number_34 = 'Thirty-four',
      pdem_number_35 = 'Thirty-five',
      pdem_number_36 = 'Thirty-six',
      pdem_number_37 = 'Thirty-seven',
      pdem_number_38 = 'Thirty-eight',
      pdem_number_39 = 'Thirty-nine',
      pdem_number_40 = 'Forty',
      pdem_number_41 = 'Forty-one',
      pdem_number_42 = 'Forty-two',
      pdem_number_43 = 'Forty-three',
      pdem_number_44 = 'Forty-four',
      pdem_number_45 = 'Forty-five',
      pdem_number_46 = 'Forty-six',
      pdem_number_47 = 'Forty-seven',
      pdem_number_48 = 'Forty-eight',
      pdem_number_49 = 'Forty-nine',
      pdem_number_50 = 'Fifty',
      pdem_number_51 = 'Fifty-one',
      pdem_number_52 = 'Fifty-two',
    },
    v_dictionary = {
      pdem_too_many_pairs = '#1# Pair',
      pdem_flush_plus = 'Flu#1#sh',
      pdem_straight_plus = 'Stra#1#ight',
      pdem_straight_flush_plus = 'Stra#1#ight Flu#2#sh',
      pdem_royal_flush_plus = 'Royal Flu#1#sh',
      pdem_flush_house_plus = 'Flu#1#sh House',

      pdem_charges = '+#1# Charge',
      pdem_bonus_play = '+#1# Play Size',
      pdem_bonus_discard = '+#1# Discard Size',
    },
    suits_singular = {
      pdem_joker_suit = 'Joker',
    },
    suits_plural = {
      pdem_joker_suit = 'Jokers',
    }
  }
}