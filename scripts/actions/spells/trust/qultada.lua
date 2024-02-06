-----------------------------------
-- Trust: Qultada
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.NOT_STATUS, xi.effect.CORSAIRS_ROLL, ai.r.JA, ai.s.SPECIFIC, xi.ja.CORSAIRS_ROLL)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.NOT_STATUS, xi.effect.CHAOS_ROLL, ai.r.JA, ai.s.SPECIFIC, xi.ja.CHAOS_ROLL)

    mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.VELOCITY_SHOT, ai.r.JA, ai.s.SPECIFIC, xi.ja.VELOCITY_SHOT)

    mob:addSimpleGambit(ai.t.TARGET, ai.c.ALWAYS, 0, ai.r.RATTACK, 0, 0, 7)

    -- Notable: Uses a balance of melee and ranged attacks.
    -- TODO: Observe his WS behaviour on retail
    mob:setTrustTPSkillSettings(ai.tp.OPENER, ai.s.RANDOM)

    -- https://forum.square-enix.com/ffxi/threads/49425-Dec-10-2015-%28JST%29-Version-Update?p=567979&viewfull=1#post567979
    -- Per the December 10, 2015 update:
    -- "The "Enhanced Magic Accuracy" attribute has been added."

	local trustLevel	= mob:getMainLvl()
	local rollbonus		= trustLevel / 12
	local rolldur		= trustLevel * 3
	local agibonus		= trustLevel
	local maccbonus		= trustLevel
	local rattbonus		= trustLevel * 2
	local raccbonus		= trustLevel * 2
	
	mob:addMod(xi.mod.PHANTOM_ROLL, rollbonus)
	mob:addMod(xi.mod.PHANTOM_DURATION, rolldur)
	mob:addMod(xi.mod.ROLL_RANGE, 15)
	mob:addMod(xi.mod.AGI, agibonus)
    mob:addMod(xi.mod.MACC, maccbonus)
	mob:addMod(xi.mod.RATT, rattbonus)
	mob:addMod(xi.mod.RACC, raccbonus)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, 7)
    
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
