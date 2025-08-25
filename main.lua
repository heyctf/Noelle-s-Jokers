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
			'Cada vez que juegues una carta de la {C:attention}suerte{}',
			'y esta no se active, gana {C:chips}+#2#{} fichas',
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

----------------------------------------------
------------MOD CODE END----------------------