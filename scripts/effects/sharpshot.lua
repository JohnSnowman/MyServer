-----------------------------------
-- xi.effect.SHARPSHOT
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.SHARPSHOT_EFFECT)

    target:addMod(xi.mod.RACC, effect:getPower())
    target:addMod(xi.mod.RATT, jpValue * 2)
    
    target:addMod(xi.mod.RATTP, 125)
    target:addMod(xi.mod.RANGED_DELAY, -150)
    target:addMod(xi.mod.DOUBLE_SHOT_RATE, 75)
    target:addMod(xi.mod.RECYCLE, 80)
    target:addMod(xi.mod.RANGED_DMG_RATING, 40)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.SHARPSHOT_EFFECT)

    target:delMod(xi.mod.RACC, effect:getPower())
    target:delMod(xi.mod.RATT, jpValue * 2)
    
    target:delMod(xi.mod.RATTP, 125)
    target:delMod(xi.mod.RANGED_DELAY, -150)
    target:delMod(xi.mod.DOUBLE_SHOT_RATE, 75)
    target:delMod(xi.mod.RECYCLE, 80)
    target:delMod(xi.mod.RANGED_DMG_RATING, 40)
end

return effectObject
