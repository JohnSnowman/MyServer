-----------------------------------
-- xi.effect.COMPOSURE
-- Increases accuracy and lengthens recast time. Enhancement effects gained through white
-- and black magic you cast on yourself last longer.
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.COMPOSURE_EFFECT)

    target:addMod(xi.mod.ACC, 15 + jpValue)
    target:addMod(xi.mod.MAGIC_DAMAGE , 150)
    target:addMod(xi.mod.MATT, 30)
    target:addMod(xi.mod.MACC, 50)
    target:addMod(xi.mod.FASTCAST, 25)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.COMPOSURE_EFFECT)

    target:delMod(xi.mod.ACC, 15 + jpValue)
    target:delMod(xi.mod.MAGIC_DAMAGE , 150)
    target:delMod(xi.mod.MATT, 30)
    target:delMod(xi.mod.MACC, 50)
    target:delMod(xi.mod.FASTCAST, 25)
end

return effectObject
