-----------------------------------
-- Trust: King of Hearts
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

    mob:addSimpleGambit(ai.t.SELF, ai.c.MPP_LT, 5, ai.r.JA, ai.s.SPECIFIC, xi.ja.CONVERT)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 50, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.SLEEP_I, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.SLEEP_II, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE)

    mob:addSimpleGambit(ai.t.MASTER, ai.c.NOT_STATUS, xi.effect.HASTE, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE, 18)
    mob:addSimpleGambit(ai.t.MELEE, ai.c.NOT_STATUS, xi.effect.HASTE, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE, 18)
    mob:addSimpleGambit(ai.t.CASTER, ai.c.NOT_STATUS, xi.effect.REFRESH, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.REFRESH, 18)
    mob:addSimpleGambit(ai.t.TANK, ai.c.NOT_STATUS, xi.effect.REFRESH, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.REFRESH, 18)
    mob:addSimpleGambit(ai.t.RANGED, ai.c.NOT_STATUS, xi.effect.FLURRY, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FLURRY, 18)

    mob:addSimpleGambit(ai.t.TOP_ENMITY, ai.c.NOT_STATUS, xi.effect.PHALANX, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PHALANX_II)

    mob:addSimpleGambit(ai.t.TARGET, ai.c.STATUS_FLAG, xi.effectFlag.DISPELABLE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.DISPEL)

    mob:addSimpleGambit(ai.t.TARGET, ai.c.NOT_STATUS, xi.effect.DIA, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.DIA, 6)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.NOT_STATUS, xi.effect.SLOW, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SLOW, 18)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.NOT_STATUS, xi.effect.EVASION_DOWN, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.DISTRACT, 8)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.NOT_STATUS, xi.effect.PARALYSIS, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PARALYZE, 18)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.NOT_STATUS, xi.effect.PROTECT, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECT, 5)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.NOT_STATUS, xi.effect.SHELL, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELL, 5)

    local trustLevel	= mob:getMainLvl()
	local potencyi		= trustLevel / 4
	local potencyii		= trustLevel / 6
	local curetomp		= trustLevel / 20
	local enhdur		= trustLevel * 6
	local refpot		= trustLevel / 20
	local phalpot		= trustLevel / 10
	local enfpot		= trustLevel
	local castingspeed	= trustLevel / 3
	local refreshmp		= trustLevel / 15
	local mndbonus		= trustLevel
	local intbonus		= trustLevel
	local maccbonus		= trustLevel * 2
	local mdefbonus		= trustLevel / 12
	local mevabonus		= trustLevel * 3
	local dmgtakenbon	= trustLevel * 10
	
	mob:addMod(xi.mod.CURE_POTENCY, potencyi)
	mob:addMod(xi.mod.CURE_POTENCY_II, potencyii)
	mob:addMod(xi.mod.CURE2MP_PERCENT, curetomp)
	mob:addMod(xi.mod.ENH_MAGIC_DURATION, enhdur)
	mob:addMod(xi.mod.ENHANCES_REFRESH, refpot)
	mob:addMod(xi.mod.PHALANX, phalpot)
	mob:addMod(xi.mod.ENF_MAG_POTENCY, enfpot)
	mob:addMod(xi.mod.FASTCAST, castingspeed)
	mob:addMod(xi.mod.REFRESH, refreshmp)
	mob:addMod(xi.mod.MND, mndbonus)
	mob:addMod(xi.mod.INT, intbonus)
    mob:addMod(xi.mod.MACC, maccbonus)
    mob:addMod(xi.mod.MDEF, mdefbonus)
    mob:addMod(xi.mod.MEVA, mevabonus)
    mob:addMod(xi.mod.DMG, -dmgtakenbon)
    mob:addMod(xi.mod.SLEEP_MEVA, 25)
    mob:addMod(xi.mod.SILENCE_MEVA, 25)
	mob:addMod(xi.mod.ENMITY, -50)

    -- Movement
	mob:addMod(xi.mod.MOVE_SPEED_OVERIDE, 250)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
