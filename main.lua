--- STEAMODDED HEADER
--- MOD_NAME: Noelle's Jokers
--- MOD_ID: NOELLESJOKERS
--- MOD_AUTHOR: [heyctf]
--- MOD_DESCRIPTION: Mod basado en las adiciones creadas por Noelle_owo_, arte creado por MorbZeno
--- PREFIX: noelle
----------------------------------------------
------------MOD CODE -------------------------

SMODS.Atlas{
	key = 'Jokers',
	path = 'Jokers.png',
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

--local palo_tostado = SMODS.Suit{
--	key = 'Prehistoria',
--	card_key = 'PREHISTORIA',
--	pos = {y=0},
--	ui_pos = {x=0,y=0},
--    lc_atlas = 'lc_cards',
--    lc_ui_atlas = 'lc_ui',
--	lc_colour = HEX('67A347'),
--	in_pool = false
--}

SMODS.Joker{
	key = 'gato_negro',
	cost = 3,
	rarity = 1,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
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

SMODS.Joker{
	key = 'refrigerador',
	cost = 5,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
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
						v.ability.extra.chips = v.ability.extra.chips + v.ability.extra.chip_mod
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
					v.ability.mult = v.ability.mult + v.ability.extra
				end
				if v.ability.name == 'Turtle Bean' then
					v.ability.extra.h_size = v.ability.extra.h_size + v.ability.extra.h_mod
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

function reset_pizza_palo()
	if not G.GAME.noelle then G.GAME.noelle = {} end
	G.GAME.noelle.pizza_suit = 'Spades'
    local cartas_validas = {}
	if G.STAGE == G.STAGES.RUN then
		for k, v in ipairs(G.playing_cards) do
			if v.ability.effect ~= 'Stone Card' then
				cartas_validas[#cartas_validas+1] = v
			end
		end
		if cartas_validas[1] then 
			local carta = pseudorandom_element(cartas_validas, pseudoseed('pizza'..G.GAME.round_resets.ante))
			G.GAME.noelle.pizza_suit = carta.base.suit
		end
	end
end

SMODS.Joker{
	key = 'pizza_4_sabores',
	cost = 6,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = 'Jokers',
	pos = {x=2,y=0},
	config = {extra = {retrigger=1}},
	loc_vars = function(self,info_queue,center)
		return {vars = {localize(G.GAME.noelle.pizza_suit, 'suits_singular'), colours = {G.C.SUITS[G.GAME.noelle.pizza_suit]}}}
	end,
	set_ability = function(self, card, initial, delay_sprites)
		reset_pizza_palo()
	end,
	calculate = function(self,card,context)
		if context.repetition then
			if context.cardarea == G.play then
				if context.other_card:is_suit(G.GAME.noelle.pizza_suit) then
					return {
						message = localize('k_again_ex'),
						repetitions = card.ability.extra.retrigger,
						card = card
					}
				end
			end
		end
		if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
			reset_pizza_palo()
		end
	end,
	in_pool = function(self)
        return true
    end,
}

--creo que empezaré a poner comentarios
--fiorela es una boba
--tú tambien
function cargar_mayorpalo()
	if not G.GAME.noelle then G.GAME.noelle = {} end
	G.GAME.noelle.mayorpalo = 'Random'
	local empatePalos = false
	local maxPalo = nil
	local maxCant = 0
    local tabla_palos = {}
	if G.STAGE == G.STAGES.RUN then
		for k, v in ipairs(G.playing_cards) do
			local palo = v.base.suit
			tabla_palos[palo] = (tabla_palos[palo] or 0) + 1 --usa el palo para sumar la cantidad y lo crea sino... lua es curioso
			if tabla_palos[palo] > maxCant then
				maxCant = tabla_palos[palo]
				maxPalo = palo
				empatePalos = false
			--este tipo de problemas recuerdo hacer mucho en fundamentos de progra
			--pero estoy muy acostumbrado a c++
			elseif palo ~= maxPalo and tabla_palos[palo] == maxCant then --por que es ~= ... grr // aca se chequea si otro palo tiene la misma cantidad que el max actual
				empatePalos = true
			end
		end
		
		if empatePalos then
			G.GAME.noelle.mayorpalo = 'Random'
		else
			G.GAME.noelle.mayorpalo = maxPalo
		end
	end
end

--me gusta mucho la idea de este comodín :p

SMODS.Joker{
	key = 'pintor',
	cost = 8,
	rarity = 3,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = 'Jokers',
	pos = {x=3,y=0},
	config = {extra = {paloSelecc = 'random_suit'}},
	loc_vars = function(self,info_queue,center)
		return {vars = {center.ability.extra.paloSelecc, colours = {G.C.SUITS[G.GAME.noelle.mayorpalo]}}}
	end,
	--espero no sea malo en rendimiento
	--o sea dudo que afecte tanto pero que sea medio malo en rendimiento
	--nose
	
	--tengo ideas de como hacerlo más simple pero,, lo dejaré así xd
	update = function(self,card,dt)
		if (G.STAGE == G.STAGES.RUN) then
			cargar_mayorpalo()
		else
			G.GAME.noelle.mayorpalo = 'Random'
		end
		
		if G.GAME.noelle.mayorpalo == 'Random' then
			card.ability.extra.paloSelecc = localize('random_suit') --creo que está bien que use más el localize, sé que probablemente no llegue a tanto este mod en otros paises pero bueno
		else
			card.ability.extra.paloSelecc = localize(G.GAME.noelle.mayorpalo, 'suits_singular')
		end
	end,
	calculate = function(self,card,context)
		if context.evaluate_poker_hand and not context.blueprint then
			if next(context.poker_hands['Straight']) then
				return {
					replace_scoring_name = 'Straight Flush',
				}
			end
		end
		if context.cardarea == G.jokers and not context.blueprint then
			if context.before and next(context.poker_hands['Straight']) then
				if context.scoring_hand then
					delay(0.02)
					local paloACambiar = nil
					if (G.GAME.noelle.mayorpalo == 'Random') then
						local cartas_validas = {}
						for k, v in ipairs(G.playing_cards) do
							if v.ability.effect ~= 'Stone Card' then --nota para yo del futuro: qué pasa si solo tienes una carta de piedra?
								cartas_validas[#cartas_validas+1] = v
							end
						end
						local carta = pseudorandom_element(cartas_validas, pseudoseed('pintor'..G.GAME.round_resets.ante))
						paloACambiar = carta.base.suit
					else
						paloACambiar = G.GAME.noelle.mayorpalo
					end
					for k, v in pairs(context.scoring_hand) do
						v:juice_up(0.3, 0.5)
						v:change_suit(paloACambiar)
					end
				end
			end
		end
	end,
	in_pool = function(self)
        return true
    end,
}

function esCiegaQueActiva()
	local tabla_ciegas = {"The Window","The Head","The Club","The Goad","The Plant","The Pillar","The Flint","The Eye","The Mouth","The Psychic","The Arm","The Ox","Verdant Leaf"}
	for k, v in ipairs(tabla_ciegas) do
		if v == G.GAME.blind.name then
			return true
		end
	end
end

SMODS.Joker{
	key = 'robocop',
	cost = 6,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = 'Jokers',
	pos = {x=4,y=0},
	config = {extra = {chips = 20, chip_mod = 50}},
	loc_vars = function(self,info_queue,center)
		return {vars = {center.ability.extra.chips,center.ability.extra.chip_mod}}
	end,
	calculate = function(self,card,context)
		if context.end_of_round and context.cardarea == G.jokers then
			if context.beat_boss and esCiegaQueActiva() then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
				return {
                    message = localize('k_upgrade_ex'),
                    card = card,
                    colour = G.C.CHIPS
                }
			end
		end
		if context.joker_main and context.cardarea == G.jokers then
			return{
				message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}, 
				colour = G.C.CHIPS,
				chip_mod = card.ability.extra.chips
			}
		end
	end,
	in_pool = function(self)
        return true
    end,
}

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

----------------------------------------------
------------MOD CODE END----------------------