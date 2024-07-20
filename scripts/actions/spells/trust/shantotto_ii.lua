-----------------------------------
-- Trust: Shantotto II
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.SHANTOTTO)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.ELEMENTAL_SEAL, ai.r.JA, ai.s.SPECIFIC, xi.ja.ELEMENTAL_SEAL)

    mob:addSimpleGambit(ai.t.TARGET, ai.c.MB_AVAILABLE, 0, ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.NOT_SC_AVAILABLE, 0, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE, 8)

    
    local trustLevel	= mob:getMainLvl()
	local mabbonus      = trustLevel / 2
	local maccbonus     = trustLevel
	local spellDamage	= trustLevel * math.floor((trustLevel + 1) / 4)
	local castingspeed	= trustLevel / 3
	local intbonus		= trustLevel / 2
	
	mob:addMod(xi.mod.MATT, mabbonus)
	mob:addMod(xi.mod.MACC, maccbonus)
	mob:addMod(xi.mod.MAGIC_DAMAGE, spellDamage)
	mob:addMod(xi.mod.FASTCAST, castingspeed)
	mob:addMod(xi.mod.INT, intbonus)

    -- Movement
	mob:addMod(xi.mod.MOVE_SPEED_OVERIDE, 250)



    -- Shantotto has 100% melee hit rate always.
    -- TODO: Add support for 'perfect accuracy' in c++ land and stop hacking her accuracy.
    mob:addMod(xi.mod.ACC, 1000)

    -- Shantotto II attack type is suposed to be 'typeless physical, like requiescat WS.'
    mob:setMobSkillAttack(1163)

    -- TODO: Her regular attacks have a big range (distance from mob, not AoE)

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 2500)

    mob:addListener('WEAPONSKILL_USE', 'SHANTOTTO_II_WEAPONSKILL_USE', function(mobArg, target, wsid, tp, action)
        if wsid == 3740 then -- Final Exam
            -- And yet again, the flames of life are snuffed out, and I'll say this--it was an out and out rout!
            xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_1)
        end
    end)

    -- Spellcast (occasionally)
    mob:addListener('MAGIC_USE', 'SHANTOTTO_II_MAGIC', function(mobArg, target, spell, action)
        if math.random(1, 100) <= 33 then
            -- Ohohohohoho!
            xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_2)
        end
    end)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
