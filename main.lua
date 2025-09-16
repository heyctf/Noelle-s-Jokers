SMODS.Atlas{
	key = 'Jokers',
	path = 'Jokers.png',
	px = 71,
	py = 95
}

SMODS.Atlas{
	key = 'Planets',
	path = 'Planets.png',
	px = 71,
	py = 95
}

SMODS.Atlas{
	key = 'lc_cards',
	path = '8BitDeck.png',
	px = 71,
	py = 95
}

SMODS.Atlas{
	key = 'lc_ui',
	path = 'ui_assets.png',
	px = 18,
	py = 18
}

SMODS.Atlas{
	key = 'modicon',
	path = 'ui_assets.png',
	px = 18,
	py = 18
}

SMODS.Atlas{
	key = 'enhancers',
	path = 'Enhancers.png',
	px = 71,
	py = 95
}

SMODS.Suit{
	key = 'Prehistoria',
	card_key = 'PREHISTORIA',
	pos = {y=0},
	ui_pos = {x=0,y=0},
    lc_atlas = 'lc_cards',
    lc_ui_atlas = 'lc_ui',
	lc_colour = HEX('67A347'),
	in_pool = function(self, args)
		return false
	end
}

SMODS.Suit{
	key = 'Tecnologica',
	card_key = 'TECNOLOGICA',
	pos = {y=1},
	ui_pos = {x=0,y=0},
    lc_atlas = 'lc_cards',
    lc_ui_atlas = 'lc_ui',
	lc_colour = HEX('7A9BFF'),
	in_pool = function(self, args)
		return false
	end
}

assert(SMODS.load_file('additions/jokers.lua'))()
assert(SMODS.load_file('additions/functions.lua'))()
assert(SMODS.load_file('additions/enhancements.lua'))()
assert(SMODS.load_file('additions/editions.lua'))()

--ignora eso
--SMODS.Joker{
--	key = 'aspiradora',
--	cost = 6,
--	rarity = 2,
--	blueprint_compat = true,
--	eternal_compat = true,
--	perishable_compat = true,
--	atlas = 'Jokers',
--	pos = {x=2,y=0},
--	config = {extra = {extra=1}},
--	loc_vars = function(self,info_queue,center)
--		return {vars = {center.ability.extra, localize(G.GAME.noelle.pizza_suit, 'suits_singular'), colours = {G.C.SUITS[G.GAME.noelle.pizza_suit]}}}
--	end,
--	calculate = function(self,card,context)
--		local comodin_selecc = nil
--		if context.end_of_round and G.GAME.blind.boss then
--			if context.cardarea == G.jokers then
--				if #G.jokers.cards > 0 then
--					local comodines = {}
--					for k, v in pairs(G.jokers.cards) do
--						if not v.gone and v ~= card and (v.ability.eternal or v.ability.perishable or v.ability.rental) then
--							table.insert(comodines,v)
--						end
--					end
--					if #comodines > 0 then
--						comodin_selecc = pseudorandom_element(comodines, pseudoseed('aspiradora'))
--						if comodin_selecc.ability.eternal or 0 then
--							comodin_selecc:set_eternal(false)
--						else
--							if comodin_selecc.ability.perishable or 0 then
--								comodin_selecc:set_perishable(false)
--							end
--						end
--						if comodin_selecc.ability.rental or 0 then
--							comodin_selecc:set_rental(false)
--						end
--						if not comodin_selecc.edition then
--							local edicion = poll_edition('aspirado', nil, false, true)
--							comodin_selecc:set_edition(edicion,true)
--						end
--					end
--				end
--			end
--		end
--	end,
--	in_pool = function(self)
--        return false
--    end,
--}

--Consumibles

--nuevos "Planetas" pronto
--SMODS.Consumable{
--	key = 'nuevo',
--	set = 'Planet',
--	atlas = 'Planets',
--	pos = {x=0,y=0},
--	config = {},
--	unlocked = true,
--	discovered = false,
--	cost = 3,
--	can_use = function(self, card)
--		if (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and card.area == G.consumeables then
--			return false
--		end
--		if (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and card.area ~= G.consumeables then
--			return true
--		end
--		if G.hand and G.hand.highlighted and #G.hand.highlighted > 0 then
--			return true
--		end
--		return false
--	end,
--	keep_on_use = function(self, card)
--		if G.STATE == G.STATES.PLANET_PACK then
--			return true
--		end
--		return false
--	end,
--	use = function(self, card, area, copier)
--		if G.hand and G.hand.highlighted and #G.hand.highlighted > 0 then
--			local text,disp_text,poker_hands,scoring_hand,non_loc_disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
--			level_up_hand(card, text)
--			G.E_MANAGER:add_event(Event({
--				trigger = 'after',
--				delay = 0.3,
--				func = function()
--					G.hand:unhighlight_all(); return true
--				end
--			}))
--			update_hand_text({nopulse = true, delay = 0.3}, {mult = 0, chips = 0, level = '', handname = ''})
--		end
--	end
--}