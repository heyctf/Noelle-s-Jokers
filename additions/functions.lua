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

function esCiegaQueActiva()
	local tabla_ciegas = {"The Window","The Head","The Club","The Goad","The Plant","The Pillar","The Flint","The Eye","The Mouth","The Psychic","The Arm","The Ox","Verdant Leaf"}
	for k, v in ipairs(tabla_ciegas) do
		if v == G.GAME.blind.name then
			return true
		end
	end
end

function calcularDientes(card)
	local cantDientesBlancos = 0
	local cantDientesCaries = 0
	for k, v in ipairs(G.playing_cards) do
		if (v.config.center == G.P_CENTERS.c_base or v.config.center == G.P_CENTERS.m_steel) and not v.seal and not v.edition and not v.debuff then
			cantDientesBlancos = cantDientesBlancos + 1
		end
		if (v.config.center ~= G.P_CENTERS.c_base and v.config.center ~= G.P_CENTERS.m_steel) or v.seal or v.edition and not v.debuff then
			cantDientesCaries = cantDientesCaries + 1
		end
	end
	return cantDientesBlancos * card.ability.extra.chips_mas - cantDientesCaries 
end

--function calcularCensoRefris(card)
--	if not G.GAME.noelle then G.GAME.noelle = {} end
--	local tabla_refris = SMODS.find_card('j_noelle_refrigerador',false)
--	local cant = #tabla_refris
--	--if card.ability.name == 'Blueprint' then
--	--	G.GAME.noelle.cantRefris = cant + 1
--	--end
--	return cant
--end

function calcularCensoRefris(i)
    if not G.GAME.noelle then G.GAME.noelle = {} end
    local contador = 0

    local function devolverIndice(card)
		for k, v in ipairs(G.jokers.cards) do
			if v == card then return k end
		end
		return nil
    end
--	if G.STAGE == G.STAGES.RUN then
--		if #G.jokers.cards > 0 then
--			if G.jokers.cards[1].key == 'j_noelle_refrigerador' and #SMODS.find_card('j_brainstorm')>0 then
--				contador = contador + #SMODS.find_card('j_brainstorm')
--			end
--		end
--	end
	if G.STAGE == G.STAGES.RUN then
--		for k, v in ipairs(G.jokers.cards) do
--			if v.key == j_noelle_refrigerador then
--				if k == 1 and G.jokers.cards[1].key ~= j_brainstorm then
--					local brain = SMODS.find_card('j_brainstorm')
--					contador = contador + #brain
--				end
--			end
--		end
		if i~=1 then
			if G.jokers.cards[i-1].ability.name == 'Blueprint' then
				contador = contador + 1
			end
		end
	end
    G.GAME.noelle.cantRefris = contador
end


local set_ability = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
	local old_center = self.config.center
	if self.base then
		if self.base.suit == 'noelle_Prehistoria' then
			if center.name == 'Bonus' then
				center = G.P_CENTERS['m_noelle_adicional_primitiva']
			end
		end
	end
	set_ability(self, center, initial, delay_sprites)
	if not initial and G.STATE ~= G.STATES.SMODS_BOOSTER_OPENED and G.STATE ~= G.STATES.SHOP and not G.SETTINGS.paused or G.TAROT_INTERRUPT then
		SMODS.calculate_context({setting_ability = true, old = old_center.key, new = self.config.center_key, other_card = self, unchanged = old_center.key == self.config.center.key})
	end
end

function aumentar_valor_venta(carta,cantidad)
	G.E_MANAGER:add_event(Event({
		trigger = 'after',
		delay = 0.3,
		func = function()
		carta.ability.extra_value = carta.ability.extra_value + math.abs(cantidad)
		carta:set_cost()
		carta:juice_up(0.3, 0.4)
		play_sound('coin1')
		return true
		end
	}))
end

local ant_ease_dollars = ease_dollars
function ease_dollars(mod, instant)
	local dinero = ant_ease_dollars(mod, instant)
	local huchas = SMODS.find_card('j_noelle_hucha',false)
	local esPaquete = false
	if G.STATE ~= 999 and G.STATE ~= G.STATES.SHOP then
		if #huchas>0 and mod<0 then
			for k, v in ipairs(huchas) do
				aumentar_valor_venta(v,mod)
			end
		end
	end
end



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