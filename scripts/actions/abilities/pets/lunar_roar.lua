-----------------------------------
-- Aerial Armor
-----------------------------------
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0, 0
end

abilityObject.onPetAbility = function(target, pet, skill)
    target:dispelStatusEffect()
    target:dispelStatusEffect()
    skill:setMsg(xi.msg.basic.NONE)
    return 0
end

return abilityObject
