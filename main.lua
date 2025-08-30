--- STEAMODDED HEADER
--- MOD_NAME: Noelle's Jokers
--- MOD_ID: NOELLESJOKERS
--- MOD_AUTHOR: [heyctf]
--- MOD_DESCRIPTION: Blee :p
--- PREFIX: noelle
----------------------------------------------
------------MOD CODE -------------------------

SMODS.Atlas{
	key = 'Jokers',
	path = 'Jokers.png',
	px = 71,
	py = 95
}

SMODS.Joker{
	key = 'gato_negro',
	loc_txt = {
		name = 'Gato negro',
		text = { 
		--Sé que está hardcodeado pero no me quiero meter todavía en la localización y esa cosa, solo quería hacerlo rápido
		--Lo cual es chistoso porque me tardo muchas más horas que pensaba xd
			'Todas las {C:green,E:1,S:1.1}probabilidades',
			'empeoran: {C:green}1 en 2{C:inactive} -> {C:green}1 en 4{C:inactive}',
			'Cada que una carta de la {C:attention}suerte{}',
			'no se active, obtiene {C:chips}+#2#{} fichas',
			'{C:inactive}(Actual {C:chips}+#1#{} {C:inactive}fichas)'
		}
	},
	cost = 3,
	rarity = 1,
	blueprint_compat = true,
	eternal_compat = true,
	atlas = 'Jokers',
	pos = {x=0,y=0},
	config = {extra = {chips = 0, chip_mod = 5, plus_odds = 2}},
	loc_vars = function(self,info_queue,center)
		return {vars = {center.ability.extra.chips, center.ability.extra.chip_mod}}
	end,
	calculate = function(self,card,context)
		if context.individual and context.cardarea == G.play and context.other_card.ability.name == 'Lucky Card' and not context.blueprint then
			if not context.other_card.lucky_trigger then
				card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
				return {
					message = 'Miau', --Miau
					colour = G.C.CHIPS,
					delay = 0.45,
				}
			end
		end
		
		if context.joker_main and card.ability.extra.chips > 0 then
			return {
				message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}, 
				colour = G.C.CHIPS,
				chip_mod = card.ability.extra.chips
			}
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		G.GAME.probabilities.normal = G.GAME.probabilities.normal / card.ability.extra.plus_odds --Se enseña como decimal, así que no será como 1 en 2 -> 1 en 4, sino 0.5 en 2
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.GAME.probabilities.normal = G.GAME.probabilities.normal * card.ability.extra.plus_odds
	end,
	in_pool = function(self)
        return true
    end,
}

SMODS.Joker:take_ownership('joker',
    {
	cost = 5,
	calculate = function(self, card, context)

	end
    },
    true
)

SMODS.Joker{
	key = 'refrigerador',
	loc_txt = {
		name = 'Refrigerador',
		text = {
			'Los comodines {C:attention}perecederos',
			'y que {C:attention}decrecen con su uso',
			'{C:inactive,s:0.8}(ej. Palomitas de maíz, Helado, etc.)',
			'duran el {C:attention}doble'
		}
	},
	cost = 5,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	atlas = 'Jokers',
	pos = {x=1,y=0},
	config = {extra = {mano_par=false,descartada_par=false}},
	update = function(self,card,dt)
		for i = 1, (G.jokers and G.jokers.cards and #G.jokers.cards or 0) do
			if G.jokers.cards[i].ability.name == 'Ice Cream' then G.jokers.cards[i].ability.extra.chip_mod = 2.5 end
			if G.jokers.cards[i].ability.name == 'Popcorn' then G.jokers.cards[i].ability.extra = 2 end
			if G.jokers.cards[i].ability.name == 'Turtle Bean' then G.jokers.cards[i].ability.extra.h_mod = 0.5 end
		end
	end,
	calculate = function(self,card,context)
		if context.discard and context.cardarea == G.jokers then
			if context.blueprint then
				card.ability.extra.descartada_par = not card.ability.extra.descartada_par
				for k, v in ipairs(G.jokers.cards) do
					if v.ability.name == 'Ramen' then
						if card.ability.extra.descartada_par then
							v.ability.x_mult = v.ability.x_mult + v.ability.extra
							return {
								message = '¡Conservado!',
								colour = G.C.FILTER
							}
						end
					end
				end
			else
				card.ability.extra.descartada_par = not card.ability.extra.descartada_par
				for k, v in ipairs(G.jokers.cards) do
					if v.ability.name == 'Ramen' then
						if card.ability.extra.descartada_par then
							v.ability.x_mult = v.ability.x_mult + v.ability.extra
							return {
								message = '¡Conservado!',
								colour = G.C.FILTER
							}
						end
					end
				end			
			end
		end
		if context.after then
			for k, v in ipairs(G.jokers.cards) do
				if v.ability.name == 'Seltzer' then
					v.ability.extra = v.ability.extra + 0.5
					return {
						message = '¡Conservado!',
						colour = G.C.FILTER
					}
				end
			end
			if context.blueprint then
				for k, v in ipairs(G.jokers.cards) do
					if v.ability.name == 'Ice Cream' then
						v.ability.extra.chips = v.ability.extra.chips + 2.5
						return {
							message = '¡Conservado!',
							colour = G.C.FILTER
						}
					end
				end
			end
		end
		if context.end_of_round and context.blueprint and context.cardarea == G.jokers then
			local activado = false
			for k, v in ipairs(G.jokers.cards) do
				if v.ability.name == 'Popcorn' then
					v.ability.mult = v.ability.mult + 2
				end
				if v.ability.name == 'Turtle Bean' then
					v.ability.extra.h_size = v.ability.extra.h_size + 0.5
				end
				if v.ability.name == 'Popcorn' or v.ability.name == 'Turtle Bean' then
					activado = true
				end
			end
			if activado then
				return {
					message = '¡Conservado!',
					colour = G.C.FILTER
				}
			end
		end
    end,
	add_to_deck = function(self, card, from_debuff)
		G.GAME.perishable_rounds = 10
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.GAME.perishable_rounds = 5
		for k, v in ipairs(G.jokers.cards) do
			if v.ability.name == 'Popcorn' then v.ability.extra = 4 end
			if v.ability.name == 'Ice Cream' then v.ability.extra.chip_mod = 5 end
			if v.ability.name == 'Turtle Bean' then v.ability.extra.h_mod = 1 end
		end
	end,
	in_pool = function(self)
        return true
    end,
}

----------------------------------------------
------------MOD CODE END----------------------