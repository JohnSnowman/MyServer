-----------------------------------
-- Ability: Meditate
-- Gradually charges TP.
-- Obtained: Samurai Level 30
-- Recast Time: 3:00 (Can be reduced to 2:30 using Merit Points)
-- Duration: 15 seconds
-----------------------------------
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    local amount   = 12
    local duration = 180 + player:getMod(xi.mod.MEDITATE_DURATION)

    if player:getMainJob() == xi.job.SAM then
        amount = 20 + target:getJobPointLevel(xi.jp.MEDITATE_EFFECT)--     * 5     --   x5  is handled in   JobPoint.sql  
    end

    player:addStatusEffectEx(xi.effect.MEDITATE, 0, amount, 3, duration)
end

return abilityObject
