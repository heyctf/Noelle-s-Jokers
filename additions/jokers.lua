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
	enhancement_gate = 'm_lucky',
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
				chips = card.ability.extra.chips
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
	config = {extra = {descarte_activado=0}},
	loc_vars = function(self,info_queue,center)
		return {vars = {G.GAME.noelle.cantRefris}}
	end,
	--yupiii
	calculate = function(self,card,context)
		if context.hand_drawn then
			G.GAME.noelle.cantRefris = 0
		end
		if context.cardarea == G.jokers and context.before then
			G.GAME.noelle.cantRefris = G.GAME.noelle.cantRefris + 1
		end
		if context.pre_discard then
			G.GAME.noelle.cantRefris = G.GAME.noelle.cantRefris + 1
		end
		if context.discard and context.cardarea == G.jokers then
			card.ability.extra.descarte_activado = card.ability.extra.descarte_activado + 1
			for k, v in ipairs(G.jokers.cards) do
				if v.ability.name == 'Ramen' then
					if card.ability.extra.descarte_activado == 2^G.GAME.noelle.cantRefris and G.GAME.noelle.cantRefris > 0 then
						v.ability.x_mult = v.ability.x_mult + v.ability.extra
						card.ability.extra.descarte_activado = 0
						return {
							message = '¡Conservado!',
							colour = G.C.FILTER
						}
					end
				end
			end
		end
    end,
	add_to_deck = function(self, card, from_debuff)
		G.GAME.perishable_rounds = 10
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.GAME.perishable_rounds = 5
	end,
	in_pool = function(self)
        return true
    end,
}

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
					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = 0.3,
						func = function()
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
								v:juice_up(0.4, 0.5)
								v:change_suit(paloACambiar)
							end
							return true
						end
					}))
				end
			end
		end
	end,
	in_pool = function(self)
        return true
    end,
}

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
			if context.beat_boss and esCiegaQueActiva() and not context.blueprint then
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
				chips = card.ability.extra.chips
			}
		end
	end,
	in_pool = function(self)
        return true
    end,
}

SMODS.Joker{
	key = 'gata_parca',
	cost = 6,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = false,
	perishable_compat = true,
	atlas = 'Jokers',
	pos = {x=5,y=0},
	config = {extra = {vidas=9,x_mult_mod=0.25,x_mult=1}},
	loc_vars = function(self,info_queue,center)
		return {vars = {center.ability.extra.vidas,center.ability.extra.x_mult_mod,center.ability.extra.x_mult}}
	end,
	calculate = function(self,card,context)
		if context.joker_main and context.cardarea == G.jokers and card.ability.extra.x_mult > 1 then
			return{
				x_mult = card.ability.extra.x_mult
			}
		end
		if context.end_of_round and not context.blueprint then
			if context.game_over and G.GAME.chips/G.GAME.blind.chips >= 0.8 then
				G.E_MANAGER:add_event(Event({
					func = function()
						G.hand_text_area.blind_chips:juice_up()
						G.hand_text_area.game_chips:juice_up()
						play_sound('tarot1')
						card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_mod
						card.ability.extra.vidas = card.ability.extra.vidas - 1
						if card.ability.extra.vidas <= 0 then
							card:start_dissolve()
						end
						return true
					end
				}))
				return {
					message = localize('k_saved_ex'),
					saved = true,
					colour = G.C.RED
				}
			end
		end
	end,
	in_pool = function(self)
        return true
    end,
}

SMODS.Joker{
	key = 'dentista',
	cost = 5,
	rarity = 1,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = 'Jokers',
	pos = {x=0,y=1},
	config = {extra = {chips_mas=3, chips_menos = 1,chips = 156}},
	loc_vars = function(self,info_queue,center)
		return {vars = {center.ability.extra.chips_mas,center.ability.extra.chips_menos,center.ability.extra.chips}}
	end,
	update = function(self,card,dt)
		if (G.deck) then
			card.ability.extra.chips = calcularDientes(card)
		end
	end,
	calculate = function(self,card,context)
		if context.joker_main and context.cardarea == G.jokers then
			card.ability.extra.chips = calcularDientes(card)
			return{
				chips = card.ability.extra.chips
			}
		end
	end,
	in_pool = function(self)
        return true
    end,
}

SMODS.Joker{
	key = 'soda_mermelada',
	cost = 6,
	rarity = 2,
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = false,
	atlas = 'Jokers',
	pos = {x=1,y=1},
	config = {extra = {rondas=6, rondas_mod=1}},
	loc_vars = function(self,info_queue,center)
		return {vars = {(center.ability.extra.rondas)/(center.ability.extra.rondas_mod)}}
	end,
	update = function(self,card,dt)
		if not G.GAME.noelle then G.GAME.noelle = {} end
		if (G.GAME.noelle.cantRefris) then
			local cantMod = G.GAME.noelle.cantRefris
			if cantMod then
			if (G.GAME.noelle.cantRefris > 0 and not (cantMod==0 and #SMODS.find_card('j_noelle_refrigerador',false)>0)) then
				card.ability.extra.rondas_mod = 1/(2^cantMod)
			end
			end
		end
	end,
	calculate = function(self,card,context)
        if context.cardarea == G.jokers then
			if context.before then
				local numericas = {}
				for k, v in ipairs(context.scoring_hand) do
					if v.base.id < 11 then --11 es el id de las jotas
						numericas[#numericas+1] = v
						v:set_ability(G.P_CENTERS.m_mult, nil, true)
						G.E_MANAGER:add_event(Event({
							func = function()
								v:juice_up()
								return true
							end
						})) 
					end
				end
				if #numericas > 0 then 
					return {
						message = localize('k_spread_jam'),
						colour = G.C.MULT,
						card = card
					}
				end
			end
			if context.end_of_round then
				if card.ability.extra.rondas - card.ability.extra.rondas_mod <= 0 then 
					G.E_MANAGER:add_event(Event({
						func = function()
							play_sound('tarot1')
							card.T.r = -0.2
							card:juice_up(0.3, 0.4)
							card.states.drag.is = true
							card.children.center.pinch.x = true
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
								func = function()
										G.jokers:remove_card(self)
										card:remove()
										card = nil
									return true; end})) 
							return true
						end
					})) 
					return {
						message = localize('k_nom_jam'),
						colour = G.C.FILTER
					}
				else
					card.ability.extra.rondas = card.ability.extra.rondas - card.ability.extra.rondas_mod
					return {
						message = tostring((card.ability.extra.rondas)/(card.ability.extra.rondas_mod)),
						colour = G.C.FILTER
					}
				end

			end
		end
	end,
	in_pool = function(self)
        return true
    end,
}

SMODS.Joker:take_ownership('popcorn',
    {
	update = function(self,card,dt)
		local cantMod = G.GAME.noelle.cantRefris
		if cantMod then
		if (G.GAME.noelle.cantRefris > 0 and not (cantMod==0 and #SMODS.find_card('j_noelle_refrigerador',false)>0)) then
			card.ability.extra = 4/(2^cantMod)
		end
		end
	end,
    },
    true
)
SMODS.Joker:take_ownership('ice_cream',
    {
	update = function(self,card,dt)
		if not G.GAME.noelle then G.GAME.noelle = {} end
		if (G.GAME.noelle.cantRefris) then
			local cantMod = G.GAME.noelle.cantRefris
			if cantMod then
			if (G.GAME.noelle.cantRefris > 0 and not (cantMod==0 and #SMODS.find_card('j_noelle_refrigerador',false)>0)) then
				card.ability.extra.chip_mod = 5/(2^cantMod)
			end
			end
		end
	end,
    },
    true
)
SMODS.Joker:take_ownership('selzer',
    {
	config = {extra = 10,refris_real=0},
	loc_vars = function(self,info_queue,center)
		return {vars = {center.ability.extra*(2^center.ability.refris_real)}}
	end,
	update = function(self,card,dt)
		local cantMod = G.GAME.noelle.cantRefris
		if cantMod then
		if (G.GAME.noelle.cantRefris > 0 and not (cantMod==0 and #SMODS.find_card('j_noelle_refrigerador',false)>0)) then
			card.ability.refris_real = G.GAME.noelle.cantRefris
		end
		end
	end,
	calculate = function(self,card,context)
		if context.after then
			if card.ability.name == 'Seltzer' and not context.blueprint then
				if card.ability.extra - 1/(2^G.GAME.noelle.cantRefris) <= 0 then 
					G.E_MANAGER:add_event(Event({
						func = function()
							play_sound('tarot1')
							card.T.r = -0.2
							card:juice_up(0.3, 0.4)
							card.states.drag.is = true
							card.children.center.pinch.x = true
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
								func = function()
										G.jokers:remove_card(card)
										card:remove()
										card = nil
									return true; end})) 
							return true
						end
					})) 
					return {
						message = localize('k_drank_ex'),
						colour = G.C.FILTER
					}
				else
					card.ability.extra = card.ability.extra - 1/(2^G.GAME.noelle.cantRefris)
					return {
						message = card.ability.extra..'',
						colour = G.C.FILTER
					}
				end
			end
		end
	end,
    },
    true
)

SMODS.Joker:take_ownership('turtle_bean',
    {
	loc_vars = function(self,info_queue,center)
		return {vars = {math.floor(center.ability.extra.h_size), center.ability.extra.h_mod}}
	end,
	update = function(self,card,dt)
		if not G.GAME.noelle then G.GAME.noelle = {} end
		if (G.GAME.noelle.cantRefris) then
			local cantMod = G.GAME.noelle.cantRefris
			if cantMod then
			if (G.GAME.noelle.cantRefris > 0 and not (cantMod==0 and #SMODS.find_card('j_noelle_refrigerador',false)>0)) then
				card.ability.extra.h_mod = 1/(2^G.GAME.noelle.cantRefris)
			end
			end
		end
	end,
    },
    true
)


--local setabilityog = Card.set_ability
--function Card:set_ability(center, initial, delay_sprites)
--	if (G.STAGE == G.STAGES.RUN) then
--		if center.name == 'Bonus' and self.base.suit == 'noelle_Prehistoria' then
--			center = G.P_CENTERS['m_noelle_adicional_primitiva']
--		end
--		self.config.center = center
--		if self.ability then
--			self.ability.bonus = 40
--		end
--	end
--	return setabilityog(self,center, initial, delay_sprites)
--end


--local usarconsumibleog = Card.use_consumeable
--function Card:use_consumeable()
--	if self.ability.consumeable.mod_conv or self.ability.consumeable.suit_conv then
--		if self.ability.name == 'The Hierophant' then
--			local mejora = nil
--			for i=1, #G.hand.highlighted do
--				if G.hand.highlighted[i].base.suit == 'noelle_Prehistoria' then
--					mejora = m_noelle_adicional_primitiva
--				else
--					mejora = G.P_CENTERS[self.ability.consumeable.mod_conv]
--				end
--				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() G.hand.highlighted[i]:set_ability(mejora);return true end }))
--			end 
--		end
--	end
--	return usarconsumibleog(self,area, copier)
--end

--local getchipref = Card.get_chip_bonus
--function Card:get_chip_bonus()
--    if self.base.suit == 'noelle_Tecnologica' then
--		return 10 --self.base.nominal + self.ability.bonus + self.ability.bonus + (self.ability.perma_bonus or 0)
--	end
--    return getchipref(self)
--end

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