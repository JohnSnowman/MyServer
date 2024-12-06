-----------------------------------
-- Trust: Zeid II
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.ZEID)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.LION_II] = xi.trust.messageOffset.TEAMWORK_1,
    })

    mob:addListener('WEAPONSKILL_USE', 'ZEID_II_WEAPONSKILL_USE', function(mobArg, target, wsid, tp, action)
        if wsid == 56 then -- Ground Strike
            -- Never again will I lose sight of who I am
            xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_1)
        end
    end)
    
    local mlvl = mob:getMainLvl()
    if mlvl > 4 then
    mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.ARCANE_CIRCLE, ai.r.JA, ai.s.SPECIFIC, xi.ja.ARCANE_CIRCLE)
    end
    -- Stun all the things!
    mob:addSimpleGambit(ai.t.TARGET, ai.c.READYING_WS, 0, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN)

    mob:addSimpleGambit(ai.t.TARGET, ai.c.READYING_MS, 0, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN)

    mob:addSimpleGambit(ai.t.TARGET, ai.c.READYING_JA, 0, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN)

    mob:addSimpleGambit(ai.t.TARGET, ai.c.CASTING_MA, 0, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN)

    -- Non-stun things
    if mlvl > 29 then
    mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.SOULEATER, ai.r.JA, ai.s.SPECIFIC, xi.ja.SOULEATER)
    end
    
    if mlvl > 14 then
    mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.LAST_RESORT, ai.r.JA, ai.s.SPECIFIC, xi.ja.LAST_RESORT)
    end
    
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 1250)

    
	
	local trustLevel	= mob:getMainLvl()
	local strbonus		= trustLevel
	local dexbonus		= trustLevel
	local attbonus		= trustLevel * 2
	local accbonus		= trustLevel * 2
	local defbonus		= trustLevel
	local mdefbonus		= trustLevel / 10
	local mevabonus		= trustLevel
	local dabonus		= trustLevel / 3
	local tabonus		= trustLevel / 10
	local stpbonus		= trustLevel / 2
	local sbbonus		= trustLevel * 0.4
	local sbiibonus		= trustLevel * 0.4
	local magichaste	= trustLevel * 10-- 33 x 75 = 2475 = 24.75% gearhaste
	local gearhaste		= trustLevel * 10-- 33 x 75 = 2475 = 24.75% gearhaste
	local abilhaste		= trustLevel * 10-- 33 x 75 = 2475 = 24.75% abilityhaste
	
	mob:addMod(xi.mod.STR, strbonus)
	mob:addMod(xi.mod.DEX, dexbonus)
	mob:addMod(xi.mod.ATT, attbonus)
	mob:addMod(xi.mod.ACC, accbonus)
	mob:addMod(xi.mod.DEF, defbonus)
    mob:addMod(xi.mod.MDEF, mdefbonus)
    mob:addMod(xi.mod.MEVA, mevabonus)
	mob:addMod(xi.mod.DOUBLE_ATTACK, dabonus)
	mob:addMod(xi.mod.TRIPLE_ATTACK, tabonus)
	mob:addMod(xi.mod.STORETP, stpbonus)
	mob:addMod(xi.mod.SUBTLE_BLOW, sbbonus)
	mob:addMod(xi.mod.SUBTLE_BLOW_II, sbiibonus)
	mob:addMod(xi.mod.ENMITY, -30)
--	mob:addMod(xi.mod.REGAIN, 75)
    mob:addMod(xi.mod.HASTE_MAGIC, magichaste) -- 1000 = 10% Haste (Magic)
    mob:addMod(xi.mod.HASTE_GEAR, gearhaste) -- 1000 = 10% Haste (gear)
    mob:addMod(xi.mod.HASTE_ABILITY, abilhaste) -- 1000 = 10% Haste (ability)

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
