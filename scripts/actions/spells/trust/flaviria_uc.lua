-----------------------------------
-- Trust: Flaviria UC
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    -- xi.trust.message(mob, xi.trust.messageOffset.SPAWN)
    

    
    local mlvl = mob:getMainLvl()

    if mlvl > 4 then
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.ANCIENT_CIRCLE, ai.r.JA, ai.s.SPECIFIC, xi.ja.ANCIENT_CIRCLE)
    end
    if mlvl > 29 then
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.BERSERK, ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK)
    end
    if mlvl > 59 then
        mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.WARCRY, ai.r.JA, ai.s.SPECIFIC, xi.ja.WARCRY)
    end
    

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 1200)

    
    if mlvl > 9 then
        mob:addSimpleGambit(ai.t.TARGET, ai.c.ALWAYS, ai.r.JA, ai.s.SPECIFIC, xi.ja.JUMP)
    end
    if mlvl > 34 then
        mob:addSimpleGambit(ai.t.TARGET, ai.c.ALWAYS, ai.r.JA, ai.s.SPECIFIC, xi.ja.HIGH_JUMP)
    end
    if mlvl > 76 then
        mob:addSimpleGambit(ai.t.TARGET, ai.c.ALWAYS, ai.r.JA, ai.s.SPECIFIC, xi.ja.SPIRIT_JUMP)
    end
    if mlvl > 84 then
        mob:addSimpleGambit(ai.t.TARGET, ai.c.ALWAYS, ai.r.JA, ai.s.SPECIFIC, xi.ja.SOUL_JUMP)
    end

    
	
	local trustLevel	= mob:getMainLvl()
	local strbonus		= trustLevel
	local dexbonus		= trustLevel
	local attbonus		= trustLevel * 4
	local accbonus		= trustLevel * 4
	local defbonus		= trustLevel
	local mdefbonus		= trustLevel / 10
	local mevabonus		= trustLevel
	local maindmgrating	= trustLevel * 2
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
    mob:addMod(xi.mod.MAIN_DMG_RATING, maindmgrating)
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
