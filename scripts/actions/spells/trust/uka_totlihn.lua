-----------------------------------
-- Trust: Uka Totlihn
-----------------------------------
local spellObject = {}

-- Define the main jobs with access to primary healing used to toggle Samba type
local healingJobs =
{
    xi.job.WHM,
    xi.job.RDM,
    xi.job.SCH,
    xi.job.PLD,
}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.MUMOR   ] = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.ULLEGORE] = xi.trust.messageOffset.TEAMWORK_2,
    })



    local mlvl = mob:getMainLvl()
    if mlvl > 44 then
        mob:addSimpleGambit(ai.t.SELF, ai.c.NO_SAMBA, 0, ai.r.JA, ai.s.SPECIFIC, xi.ja.HASTE_SAMBA)
    elseif mlvl < 45 and mlvl > 4 then
        mob:addSimpleGambit(ai.t.SELF, ai.c.NO_SAMBA, 0, ai.r.JA, ai.s.BEST_SAMBA, xi.ja.DRAIN_SAMBA)
    end

    -- Step Interactions:
    mob:addSimpleGambit(ai.t.TARGET, ai.c.NOT_STATUS, xi.effect.LETHARGIC_DAZE_5, ai.r.JA, ai.s.SPECIFIC, xi.ja.QUICKSTEP, 20)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.READYING_WS, 0, ai.r.JA, ai.s.SPECIFIC, xi.ja.VIOLENT_FLOURISH)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.READYING_MS, 0, ai.r.JA, ai.s.SPECIFIC, xi.ja.VIOLENT_FLOURISH)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.READYING_JA, 0, ai.r.JA, ai.s.SPECIFIC, xi.ja.VIOLENT_FLOURISH)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.CASTING_MA, 0, ai.r.JA, ai.s.SPECIFIC, xi.ja.VIOLENT_FLOURISH)
    

    -- Healing logic
    mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 50, ai.r.JA, ai.s.HIGHEST_WALTZ, xi.ja.CURING_WALTZ)
    mob:addSimpleGambit(ai.t.SELF, ai.c.STATUS_FLAG, xi.effectFlag.WALTZABLE, ai.r.JA, ai.s.SPECIFIC, xi.ja.HEALING_WALTZ)
    

    -- TP use and return
    if mlvl > 39 then
        mob:addSimpleGambit(ai.t.SELF, ai.c.STATUS, xi.effect.FINISHING_MOVE_5, ai.r.JA, ai.s.SPECIFIC, xi.ja.REVERSE_FLOURISH, 60)
    end
    
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 2000)
    
	
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
    mob:addMod(xi.mod.HASTE_MAGIC, magichaste) -- 1000 = 10% Haste (Magic)
    mob:addMod(xi.mod.HASTE_GEAR, gearhaste) -- 1000 = 10% Haste (gear)

    -- Movement
	mob:addMod(xi.mod.MOVE_SPEED_OVERIDE, 250)


    
--[[
    -- Dynamic modifier that checks party member list on tick to apply synergy
    mob:addListener('COMBAT_TICK', 'UKA_TOTLIHN_CTICK', function(mobArg)
        local waltzPotencyBoost = 0
        local party = mobArg:getMaster():getPartyWithTrusts()
        for _, member in pairs(party) do
            if member:getObjType() == xi.objType.TRUST then
                if
                    member:getTrustID() == xi.magic.spell.MUMOR or
                    member:getTrustID() == xi.magic.spell.MUMOR_II
                then
                    waltzPotencyBoost = 10
                end
            end
        end

        -- Always set the boost, even if Mumor wasn't found.
        -- This accounts for her being in the party and giving the boost
        -- and also if she dies and the boost goes away.
        mobArg:setMod(xi.mod.WALTZ_POTENCY, waltzPotencyBoost)
    end)

    for i = 1, #healingJobs do
        local master  = mob:getMaster()
        if master:getMainJob() == healingJobs[i] then
            mob:addSimpleGambit(ai.t.SELF, ai.c.NO_SAMBA, 0, ai.r.JA, ai.s.SPECIFIC, xi.ja.HASTE_SAMBA)
        end
    end

    -- Step Interactions:
    mob:addSimpleGambit(ai.t.TARGET, ai.c.NOT_STATUS, xi.effect.LETHARGIC_DAZE_5, ai.r.JA, ai.s.SPECIFIC, xi.ja.QUICKSTEP, 20)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.READYING_WS, 0, ai.r.JA, ai.s.SPECIFIC, xi.ja.VIOLENT_FLOURISH)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.READYING_MS, 0, ai.r.JA, ai.s.SPECIFIC, xi.ja.VIOLENT_FLOURISH)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.READYING_JA, 0, ai.r.JA, ai.s.SPECIFIC, xi.ja.VIOLENT_FLOURISH)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.CASTING_MA, 0, ai.r.JA, ai.s.SPECIFIC, xi.ja.VIOLENT_FLOURISH)

    -- Ecosystem check to swap to Haste samba if the target is undead
    mob:addSimpleGambit(ai.t.TARGET, ai.c.IS_ECOSYSTEM, xi.ecosystem.UNDEAD, ai.r.JA, ai.s.SPECIFIC, xi.ja.HASTE_SAMBA)

    -- Healing logic
    mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 50, ai.r.JA, ai.s.HIGHEST_WALTZ, xi.ja.CURING_WALTZ)
    mob:addSimpleGambit(ai.t.SELF, ai.c.NO_SAMBA, 0, ai.r.JA, ai.s.BEST_SAMBA, xi.ja.DRAIN_SAMBA)
    mob:addSimpleGambit(ai.t.SELF, ai.c.STATUS_FLAG, xi.effectFlag.WALTZABLE, ai.r.JA, ai.s.SPECIFIC, xi.ja.HEALING_WALTZ)

    -- TP use and return
    mob:addSimpleGambit(ai.t.SELF, ai.c.STATUS, xi.effect.FINISHING_MOVE_5, ai.r.JA, ai.s.SPECIFIC, xi.ja.REVERSE_FLOURISH, 60)
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 2000)
]]--
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
