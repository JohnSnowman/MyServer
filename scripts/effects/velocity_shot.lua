-----------------------------------
-- xi.effect.VELOCITY_SHOT
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.VELOCITY_SHOT_EFFECT)

    target:addMod(xi.mod.RATT, jpValue * 20)
    target:addMod(xi.mod.ATTP, -75)
    target:addMod(xi.mod.HASTE_ABILITY, -1500)
    target:addMod(xi.mod.RATTP, 500)
    target:addMod(xi.mod.RANGED_DELAYP, -95)
    target:addMod(xi.mod.RANGED_DMG_RATING, 150)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.VELOCITY_SHOT_EFFECT)

    target:delMod(xi.mod.RATT, jpValue * 20)
    target:delMod(xi.mod.ATTP, -75)
    target:delMod(xi.mod.HASTE_ABILITY, -1500)
    target:delMod(xi.mod.RATTP, 500)
    target:delMod(xi.mod.RANGED_DELAYP, -95)
    target:delMod(xi.mod.RANGED_DMG_RATING, 150)
end

return effectObject
