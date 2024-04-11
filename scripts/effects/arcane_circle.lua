-----------------------------------
-- xi.effect.ARCANE_CIRCLE
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.ARCANA_KILLER, effect:getPower())
    target:addMod(xi.mod.ATTP, 125)
    target:addMod(xi.mod.HASTE_ABILITY, 1500)
    target:addMod(xi.mod.DOUBLE_ATTACK, 25)
    target:addMod(xi.mod.DOUBLE_ATTACK_DMG, 100)
    target:addMod(xi.mod.MAIN_DMG_RATING, 30)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.ARCANA_KILLER, effect:getPower())
    target:delMod(xi.mod.ATTP, 125)
    target:delMod(xi.mod.HASTE_ABILITY, 1500)
    target:delMod(xi.mod.DOUBLE_ATTACK, 25)
    target:delMod(xi.mod.DOUBLE_ATTACK_DMG, 100)
    target:delMod(xi.mod.MAIN_DMG_RATING, 30)
end

return effectObject
