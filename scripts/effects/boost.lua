-----------------------------------
-- xi.effect.BOOST
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.ATTP, effect:getPower())
    target:addMod(xi.mod.MARTIAL_ARTS, 150)
   
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.ATTP, effect:getPower())
    target:delMod(xi.mod.MARTIAL_ARTS, 150)
end

return effectObject
