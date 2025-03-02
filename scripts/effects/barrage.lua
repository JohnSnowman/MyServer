-----------------------------------
-- xi.effect.BARRAGE
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.BARRAGE_EFFECT)

    target:addMod(xi.mod.RATT, jpValue * 3)
    target:addMod(xi.mod.RANGED_DMG_RATING, 30)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.BARRAGE_EFFECT)

    target:delMod(xi.mod.RATT, jpValue * 3)
    target:delMod(xi.mod.RANGED_DMG_RATING, 30)
end

return effectObject
