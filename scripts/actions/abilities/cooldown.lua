-----------------------------------
-- Ability: Cooldown
-- Description: Reduces the strain on your automaton.
-- Obtained: PUP Level 95
-- Recast Time: 00:05:00
-----------------------------------
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    if not player:getPet() then
        -- TODO: Add check to verify this is an automaton
        return xi.msg.basic.REQUIRES_A_PET, 0
    end

    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    -- local jpValue = player:getJobPointLevel(xi.jp.COOLDOWN_EFFECT) -- something wrong ,  overloading all the time once JP put in and use ability  , thinking it is overflowing into negitive with no clamp to stop 

    -- player:reduceBurden(50, jpValue)
    player:reduceBurden(50)

    if player:hasStatusEffect(xi.effect.OVERLOAD) then
        player:delStatusEffect(xi.effect.OVERLOAD)
    end
end

return abilityObject
