-----------------------------------
-- xi.effect.ELEMENTAL_SEAL
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)

    target:addMod(xi.mod.MAGIC_DAMAGE , 300)
    target:addMod(xi.mod.MATT, 200)
    
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)

    target:delMod(xi.mod.MAGIC_DAMAGE , 300)
    target:delMod(xi.mod.MATT, 200)
    
end

return effectObject
