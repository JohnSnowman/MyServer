-----------------------------------
-- Ability: Sentinel
-- Reduces physical damage taken and increases enmity.
-- Obtained: Paladin Level 30
-- Recast Time: 5:00
-- Duration: 0:30
-----------------------------------
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    ability:setRecast(ability:getRecast() - 300)
    --ability:setRecast(math.max(0, ability:getRecast() - player:getMod(xi.mod.CALL_BEAST_DELAY)))
    --ability:setRecast(ability:getRecast() - jpValue)
    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    xi.job_utils.paladin.useSentinel(player, target, ability)
end

return abilityObject
