-----------------------------------
-- Trust: Apururu UC
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

local isWearingApururuShirt = function(player)
    local wearingBody = player:getEquipID(xi.slot.BODY) == xi.item.APURURU_UNITY_SHIRT
    return wearingBody
end

spellObject.onMobSpawn = function(mob)
    local master = mob:getMaster()
    if isWearingApururuShirt(master) then
        xi.trust.message(mob, xi.trust.messageOffset.TEAMWORK_2)
    else
        xi.trust.message(mob, xi.trust.messageOffset.SPAWN)
    end

    -- Unity ranking high : xi.trust.message(mob, xi.trust.messageOffset.TEAMWORK_1)

    -- TODO: Nott weaponskill needs implemented and logic added here for Apururu to use at 50% MP at level 50.
    -- TODO: UC trusts are supposed to get bonuses depending on unity ranking. Needs research.
    -- TODO: Custom spawn messages if Unity ranking is higher.
    -- TODO: Setup conditional behaviors for Devotion, Martyr

    mob:addSimpleGambit(ai.t.SELF, ai.c.MPP_LT, 25, ai.r.JA, ai.s.SPECIFIC, xi.ja.CONVERT)
    
	mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.AFFLATUS_SOLACE, ai.r.JA, ai.s.SPECIFIC, xi.ja.AFFLATUS_SOLACE)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 40, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.SLEEP_I, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURAGA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.SLEEP_II, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURAGA)
    
    local mlvl = mob:getMainLvl()
    if mlvl > 90 then
        mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 80, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_IV)
    elseif mlvl < 91 and mlvl > 30 then
        mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 80, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_III)
    elseif mlvl < 31 and mlvl > 17 then
        mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 80, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_II)
    elseif mlvl < 18 then
        mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 80, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE)
    end
    --  mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 75, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.NOT_STATUS, xi.effect.PROTECT, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECTRA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.NOT_STATUS, xi.effect.SHELL, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELLRA)

    mob:addSimpleGambit(ai.t.MELEE, ai.c.NOT_STATUS, xi.effect.HASTE, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.POISON, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.POISONA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.PARALYSIS, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.BLINDNESS, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.SILENCE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.PETRIFICATION, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.DISEASE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.CURSE_I, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA)

    mob:addSimpleGambit(ai.t.SELF, ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE)

    mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.STONESKIN, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONESKIN)

    local trustLevel	= mob:getMainLvl()
	local potencyi		= trustLevel / 3
	local potencyii		= trustLevel / 5
	local curetoomp		= trustLevel / 15
	local affsol		= trustLevel / 3
	local enhdur		= trustLevel * 3
	local castingspeed	= trustLevel / 3
	local refreshmp		= trustLevel / 15
	local mndbonus		= trustLevel
	local mdefbonus		= trustLevel / 9
	local mevabonus		= trustLevel * 4
	local dmgtakenbon	= trustLevel * 15-- 35 time 75 = 2625 = 26.245%		Damage - 10000 base, 375 = 3.75%
	
	mob:addMod(xi.mod.CURE_POTENCY, potencyi)
	mob:addMod(xi.mod.CURE_POTENCY_II, potencyii)
	mob:addMod(xi.mod.CURE2MP_PERCENT, curetoomp)
	mob:addMod(xi.mod.AFFLATUS_SOLACE, affsol)
	mob:addMod(xi.mod.ENH_MAGIC_DURATION, enhdur)
	mob:addMod(xi.mod.FASTCAST, castingspeed)
	mob:addMod(xi.mod.REFRESH, refreshmp)
	mob:addMod(xi.mod.MND, mndbonus)
    mob:addMod(xi.mod.MDEF, mdefbonus)
    mob:addMod(xi.mod.MEVA, mevabonus)
    mob:addMod(xi.mod.DMG, -dmgtakenbon)
    mob:addMod(xi.mod.SLEEP_MEVA, 50)
    mob:addMod(xi.mod.SILENCE_MEVA, 50)
	mob:addMod(xi.mod.ENMITY, -50)

    -- Movement
	mob:addMod(xi.mod.MOVE_SPEED_OVERIDE, 250)

    mob:setAutoAttackEnabled(false)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
