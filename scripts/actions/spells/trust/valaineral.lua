-----------------------------------
-- Trust: Valaineral
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    -- Records of Eminence: Alter Ego: Valaineral
    if caster:getEminenceProgress(933) then
        xi.roe.onRecordTrigger(caster, 933)
    end

    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    --[[
        Summon: With your courage and valor, Altana's children will live to see a brighter day.
        Summon (Formerly): Let the Royal Family’s blade be seared forever into their memories!
    ]]
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:addSimpleGambit(ai.t.TARGET, ai.c.ALWAYS, 0, ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE)

    mob:addSimpleGambit(ai.t.TARGET, ai.c.NOT_STATUS, xi.effect.FLASH, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH)

    mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.HOLY_CIRCLE, ai.r.JA, ai.s.SPECIFIC, xi.ja.HOLY_CIRCLE)

    mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.SENTINEL, ai.r.JA, ai.s.SPECIFIC, xi.ja.SENTINEL)

    mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.MAJESTY, ai.r.JA, ai.s.SPECIFIC, xi.ja.MAJESTY)

    mob:addSimpleGambit(ai.t.MASTER, ai.c.HPP_LT, 76, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE)

    mob:addSimpleGambit(ai.t.SELF, ai.c.HPP_LT, 76, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 50, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE)
    
    mob:addSimpleGambit(ai.t.PARTY, ai.c.NOT_STATUS, xi.effect.PROTECT, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECT, 7)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.NOT_STATUS, xi.effect.SHELL, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELL, 7)

    
	local trustLevel	= mob:getMainLvl()
	local potencyi		= trustLevel / 4
	local curetoomp		= trustLevel / 15
	local enhdur		= trustLevel * 4
	local castingspeed	= trustLevel / 2
	local refreshmp		= trustLevel / 20
	local mndbonus		= trustLevel
	local vitbonus		= trustLevel
	local accbonus		= trustLevel
	local defbonus		= trustLevel * 2
	local mdefbonus		= trustLevel / 6
	local mevabonus		= trustLevel * 2
	local dmgtakenbon	= trustLevel * 30-- 70 time 75 = 5250 = 52.5%		Damage - 10000 base, 375 = 3.75%        119 time 30 = 3570 = 35.7%
	local phystakenii	= trustLevel * 15-- 40 time 75 = 3000 = 30%			Damage - 10000 base, 375 = 3.75%	
	local magtakenii	= trustLevel * 15-- 40 time 75 = 3000 = 30%			Damage - 10000 base, 375 = 3.75%
	local absdmgmp		= trustLevel / 7
	local magichaste	= trustLevel * 10-- 33 x 75 = 2475 = 24.75% gearhaste
	local gearhaste		= trustLevel * 7-- 33 x 75 = 2475 = 24.75% gearhaste
	local abilhaste		= trustLevel * 7-- 33 x 75 = 2475 = 24.75% abilityhaste
	
	mob:addMod(xi.mod.CURE_POTENCY, potencyi)
	mob:addMod(xi.mod.CURE2MP_PERCENT, curetoomp)
	mob:addMod(xi.mod.ENH_MAGIC_DURATION, enhdur)
	mob:addMod(xi.mod.FASTCAST, castingspeed)
	mob:addMod(xi.mod.REFRESH, refreshmp)
	mob:addMod(xi.mod.MND, mndbonus)
	mob:addMod(xi.mod.VIT, vitbonus)
	mob:addMod(xi.mod.ACC, accbonus)
	mob:addMod(xi.mod.DEF, defbonus)
    mob:addMod(xi.mod.MDEF, mdefbonus)
    mob:addMod(xi.mod.MEVA, mevabonus)
    mob:addMod(xi.mod.DMG, -dmgtakenbon)
    mob:addMod(xi.mod.DMGPHYS_II, -phystakenii)
    mob:addMod(xi.mod.DMGMAGIC_II, -magtakenii)
    mob:addMod(xi.mod.ABSORB_DMG_TO_MP, absdmgmp)
	
	mob:addMod(xi.mod.ENMITY, 150)
	mob:addMod(xi.mod.ENMITY_LOSS_REDUCTION, 50)
    mob:addMod(xi.mod.HASTE_MAGIC, magichaste) -- 1000 = 10% Haste (Magic)
    mob:addMod(xi.mod.HASTE_GEAR, gearhaste) -- 1000 = 10% Haste (gear)
    mob:addMod(xi.mod.HASTE_ABILITY, abilhaste) -- 1000 = 10% Haste (ability)

    -- Movement
	mob:addMod(xi.mod.MOVE_SPEED_OVERIDE, 250)

    -- mob:setMobMod(xi.mobMod.TRUST_DISTANCE, 2)
    
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
