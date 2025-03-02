-----------------------------------
-- Trust: Joachim
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    -- Records of Eminence: Alter Ego: Joachim
    if caster:getEminenceProgress(937) then
        xi.roe.onRecordTrigger(caster, 937)
    end

    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 35, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.SLEEP_I, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURAGA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.SLEEP_II, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURAGA)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.POISON, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.POISONA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.PARALYSIS, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.BLINDNESS, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.SILENCE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.PETRIFICATION, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.DISEASE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.CURSE_I, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA)

    mob:addSimpleGambit(ai.t.SELF, ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE)

    -- TODO: BRD trusts need better logic and major overhaul, for now they compliment each other
    local mlvl = mob:getMainLvl()
    if mlvl > 28 then
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.MARCH, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MARCH)
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.MINUET, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.VALOR_MINUET)
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.MADRIGAL, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MADRIGAL)
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.BALLAD, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MAGES_BALLAD)
    elseif mlvl < 29 and mlvl > 24 then
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.MINUET, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.VALOR_MINUET)
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.MADRIGAL, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MADRIGAL)
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.BALLAD, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MAGES_BALLAD)
    else
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.MADRIGAL, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MADRIGAL)
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.MINUET, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.VALOR_MINUET)
    end
    
    -- mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.MARCH, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MARCH)
    -- mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.BALLAD, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MAGES_BALLAD)
    --[[
    if mlvl > 75 then
        mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 75, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_IV)
    elseif mlvl < 75 and mlvl > 27 then
        mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 75, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_III)
    elseif mlvl < 28 and mlvl > 15 then
        mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 75, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_II)
    elseif mlvl < 16 then
        mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 75, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE)
    end
    ]]--
    mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 75, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE)
    
    mob:addSimpleGambit(ai.t.TARGET, ai.c.NOT_STATUS, xi.effect.ELEGY, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.ELEGY)

    local trustLevel	= mob:getMainLvl()
	local songeffbon	= trustLevel / 10
	local songdurbon	= trustLevel * 4
	local songcasttime	= trustLevel / 3
	local maccbonus		= trustLevel * 2
	local castingspeed	= trustLevel / 4

    mob:addMod(xi.mod.MAXIMUM_SONGS_BONUS, 2)
	mob:addMod(xi.mod.ALL_SONGS_EFFECT, songeffbon)
	mob:addMod(xi.mod.SONG_DURATION_BONUS, songdurbon)
	mob:addMod(xi.mod.SONG_SPELLCASTING_TIME, songcasttime)--- is reduction even if not stated , should not be negitive   Confirmation?  mods/sql/item_latents.sql   Minstrel's Ring
    mob:addMod(xi.mod.MACC, maccbonus)
	mob:addMod(xi.mod.FASTCAST, castingspeed)

    -- Movement
	mob:addMod(xi.mod.MOVE_SPEED_OVERIDE, 250)

    -- Try and ranged attack every 60s
    mob:addSimpleGambit(ai.t.TARGET, ai.c.ALWAYS, 0, ai.r.RATTACK, 0, 0, 60)

    mob:setAutoAttackEnabled(false)

    --  mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, 4)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
