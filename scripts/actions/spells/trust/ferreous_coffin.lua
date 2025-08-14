-----------------------------------
-- Trust: Ferreous Coffin
-- Auto Refresh II (Cleric's Bliaut +2). HP-10%, MP+35%
-- Will only cast Raise III on KO party members in casting range.
-- Will only cast status ailment removal spells on the player with the highest enmity.
-- Has a high Cursna success rate (only casts on the highest threat player) Official note
-- Ferreous Coffin only uses Randgrith and benefits from relic aftermath (acc +20).
-- Will use TP as soon as he gets it, so he is good at maintaining enemy Evasion Down and initiating Light skillchains.
-- Casts Haste on party members regardless of job.
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
    
    local mlvl = mob:getMainLvl()
    if mlvl > 14 then
	mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.DIVINE_SEAL, ai.r.JA, ai.s.SPECIFIC, xi.ja.DIVINE_SEAL)
    elseif mlvl > 29 then
    mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.BERSERK, ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK)
    elseif mlvl > 39 then
	mob:addSimpleGambit(ai.t.SELF, ai.c.NOT_STATUS, xi.effect.AFFLATUS_SOLACE, ai.r.JA, ai.s.SPECIFIC, xi.ja.AFFLATUS_SOLACE)
    end

    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.SLOW, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.NOT_STATUS, xi.effect.HASTE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HASTE)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.SLEEP_I, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE)
    mob:addSimpleGambit(ai.t.PARTY, ai.c.STATUS, xi.effect.SLEEP_II, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE)

    mob:addSimpleGambit(ai.t.PARTY, ai.c.HPP_LT, 75, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE)

    mob:addSimpleGambit(ai.t.TOP_ENMITY, ai.c.STATUS, xi.effect.PARALYSIS, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA)
    mob:addSimpleGambit(ai.t.TOP_ENMITY, ai.c.STATUS, xi.effect.BLINDNESS, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA)
    mob:addSimpleGambit(ai.t.TOP_ENMITY, ai.c.STATUS, xi.effect.SILENCE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA)
    mob:addSimpleGambit(ai.t.TOP_ENMITY, ai.c.STATUS, xi.effect.PETRIFICATION, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA)
    mob:addSimpleGambit(ai.t.TOP_ENMITY, ai.c.STATUS, xi.effect.DISEASE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA)

    mob:addSimpleGambit(ai.t.TOP_ENMITY, ai.c.STATUS, xi.effect.CURSE_I, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA)
    mob:addSimpleGambit(ai.t.TOP_ENMITY, ai.c.STATUS, xi.effect.CURSE_II, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA)
    mob:addSimpleGambit(ai.t.TOP_ENMITY, ai.c.STATUS, xi.effect.BANE, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA)
    mob:addSimpleGambit(ai.t.TOP_ENMITY, ai.c.STATUS, xi.effect.DOOM, ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA)

    mob:addSimpleGambit(ai.t.PARTY_DEAD, ai.c.ALWAYS, 0, ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.RAISE)

    mob:addListener('WEAPONSKILL_USE', 'FERREOUS_COFFIN_WEAPONSKILL_USE', function(mobArg, target, wsid, tp, action)
        if wsid == 170 then -- Randgrith
        -- Return to the dust whence you came! Randgrith!!!
            if math.random(1, 100) <= 66 then
                xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_1)
            end

            mob:addStatusEffect(xi.effect.ACCURACY_BOOST, 20, 0, 20) -- Cheat in Relic AM ACC
            -- TODO: Expand Relic (Mjollnir) Handling (Occ. Double Damage, etc)
        end
    end)

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)

    local trustLevel	= mob:getMainLvl()
	local potencyi		= trustLevel / 5
	local potencyii		= trustLevel / 8
	local cureamount	= trustLevel * 2
	local affsol		= trustLevel / 5
	local enhdur		= trustLevel * 2
	local castingspeed	= trustLevel / 4
	local refreshmp		= trustLevel / 15
	local mndbonus		= trustLevel
	local mdefbonus		= trustLevel / 9
	local mevabonus		= trustLevel * 3
	local dmgtakenbon	= trustLevel * 15-- 35 time 75 = 2625 = 26.245%		Damage - 10000 base, 375 = 3.75%

    
    -- HPP/MPP mods migrated to sql/mob_pool_mods
    mob:addMod(xi.mod.ENHANCES_CURSNA, 20)
	
	mob:addMod(xi.mod.CURE_POTENCY, potencyi)
	mob:addMod(xi.mod.CURE_POTENCY_II, potencyii)
	mob:addMod(xi.mod.CURE_POTENCY_BONUS, cureamount)
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
    
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
