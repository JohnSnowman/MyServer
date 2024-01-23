-----------------------------------
-- Trust: Tenzen
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.TENZEN_II)
end

spellObject.onSpellCast = function(caster, target, spell)
    -- Records of Eminence: Alter Ego: Tenzen
    if caster:getEminenceProgress(935) then
        xi.roe.onRecordTrigger(caster, 935)
    end

    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.IROHA] = xi.trust.messageOffset.TEAMWORK_1,
    })

    mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.HASSO,
        ai.r.JA, ai.s.SPECIFIC, xi.ja.HASSO)

    mob:addSimpleGambit(ai.t.SELF, ai.c.HAS_TOP_ENMITY, 0,
        ai.r.JA, ai.s.SPECIFIC, xi.ja.THIRD_EYE)

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 1500)

    
	
	local trustLevel	= mob:getMainLvl()
	local strbonus		= trustLevel
	local dexbonus		= trustLevel
	local attbonus		= trustLevel * 2
	local accbonus		= trustLevel * 2
	local defbonus		= trustLevel
	local mdefbonus		= trustLevel / 10
	local mevabonus		= trustLevel
	local dabonus		= trustLevel / 2
	local tabonus		= trustLevel / 8
	local sbbonus		= trustLevel * 0.4
	local sbiibonus		= trustLevel * 0.4
	local gearhaste		= trustLevel * 20-- 33 x 75 = 2475 = 24.75% gearhaste
	local abilhaste		= trustLevel * 20-- 33 x 75 = 2475 = 24.75% abilityhaste
	
	mob:addMod(xi.mod.STR, strbonus)
	mob:addMod(xi.mod.DEX, dexbonus)
	mob:addMod(xi.mod.ATT, attbonus)
	mob:addMod(xi.mod.ACC, accbonus)
	mob:addMod(xi.mod.DEF, defbonus)
    mob:addMod(xi.mod.MDEF, mdefbonus)
    mob:addMod(xi.mod.MEVA, mevabonus)
	mob:addMod(xi.mod.DOUBLE_ATTACK, dabonus)
	mob:addMod(xi.mod.TRIPLE_ATTACK, tabonus)
	mob:addMod(xi.mod.SUBTLE_BLOW, sbbonus)
	mob:addMod(xi.mod.SUBTLE_BLOW_II, sbiibonus)
	mob:addMod(xi.mod.ENMITY, -30)
--	mob:addMod(xi.mod.REGAIN, 75)
    mob:addMod(xi.mod.HASTE_MAGIC, 1000) -- 1000 = 10% Haste (Magic)
    mob:addMod(xi.mod.HASTE_GEAR, gearhaste) -- 1000 = 10% Haste (gear)
    mob:addMod(xi.mod.HASTE_ABILITY, abilhaste) -- 1000 = 10% Haste (ability)
    
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
