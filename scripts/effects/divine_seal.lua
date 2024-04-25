-----------------------------------
-- xi.effect.DIVINE_SEAL
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)

    target:addMod(xi.mod.MAGIC_DAMAGE , 150)
    target:addMod(xi.mod.MATT, 40)
    target:addMod(xi.mod.MACC, 50)
    target:addMod(xi.mod.CURE_POTENCY, 50)
    target:addMod(xi.mod.CURE_POTENCY_II, 40)
    target:addMod(xi.mod.FASTCAST, 25)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)

    target:delMod(xi.mod.MAGIC_DAMAGE , 150)
    target:delMod(xi.mod.MATT, 40)
    target:delMod(xi.mod.MACC, 50)
    target:delMod(xi.mod.CURE_POTENCY, 50)
    target:delMod(xi.mod.CURE_POTENCY_II, 40)
    target:delMod(xi.mod.FASTCAST, 25)
end

return effectObject
