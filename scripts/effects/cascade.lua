-----------------------------------
-- xi.effect.CASCADE
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)

    target:addMod(xi.mod.MAGIC_DAMAGE , 200)
    target:addMod(xi.mod.MATT, 200)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)

    target:delMod(xi.mod.MAGIC_DAMAGE , 200)
    target:delMod(xi.mod.MATT, 200)
end

return effectObject
