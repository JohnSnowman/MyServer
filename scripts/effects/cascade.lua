-----------------------------------
-- xi.effect.CASCADE
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)

    target:addMod(xi.mod.MAGIC_DAMAGE , 250)
    target:addMod(xi.mod.MATT, 150)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)

    target:delMod(xi.mod.MAGIC_DAMAGE , 250)
    target:delMod(xi.mod.MATT, 150)
end

return effectObject
