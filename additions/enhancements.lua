local m_noelle_adicional_primitiva = SMODS.Enhancement{key='adicional_primitiva',atlas='enhancers',pos={x=0,y=0},config={bonus=90},loc_vars=function(self,info_queue,center)return{vars={center.ability.bonus}}end,in_pool=function(self,args)return false end}
local m_noelle_multi_primitiva = SMODS.Enhancement{key='multi_primitiva',atlas='enhancers',pos={x=1,y=0},config={mult=9},loc_vars=function(self,info_queue,center)return{vars={center.ability.mult}}end,in_pool=function(self,args)return false end}
--local m_noelle_versatil_primitiva = SMODS.Enhancement{key='versatil_primitiva',atlas='enhancers',pos={x=2,y=0},config={mult=9},loc_vars=function(self,info_queue,center)return{vars={center.ability.mult}}end,in_pool=function(self,args)return false end}
local m_noelle_suerte_primitiva = SMODS.Enhancement{key='suerte_primitiva',atlas='enhancers',pos={x=3,y=0},config={extra={mult=45,p_dollars=45}},loc_vars=function(self,info_queue,center)return{vars={center.ability.extra.mult,center.ability.extra.p_dollars,G.GAME.probabilities.normal}}end,
calculate = function(self,card,context)
	if context.main_scoring and context.cardarea == G.play then
		local dinero = false
		local multi = false
		if pseudorandom('primitiva_multi') < G.GAME.probabilities.normal/5 then
			card.lucky_trigger = true
			multi = true
		end
		if pseudorandom('primitiva_dinero') < G.GAME.probabilities.normal/15 then
			card.lucky_trigger = true
			dinero = true
		end
		--esta es la peor cosa que he hecho como informatico
		--PERO FUNCIONA
		if multi and not dinero then
			return{
				mult = card.ability.extra.mult
			}
		end
		if not multi and dinero then
			return{
				p_dollars = card.ability.extra.p_dollars
			}
		end
		if multi and dinero then
			return{
				mult = card.ability.extra.mult,
				p_dollars = card.ability.extra.p_dollars
			}
		end
	end
end,
in_pool = function(self,args) return false end}

G.P_CENTERS['m_noelle_adicional_primitiva'] = m_noelle_adicional_primitiva
G.P_CENTERS['m_noelle_multi_primitiva'] = m_noelle_multi_primitiva
G.P_CENTERS['m_noelle_suerte_primitiva'] = m_noelle_suerte_primitiva