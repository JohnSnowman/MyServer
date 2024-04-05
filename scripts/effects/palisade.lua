-----------------------------------
-- xi.effect.PALISADE
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.PALISADE_BLOCK_BONUS, effect:getPower())
    target:addMod(xi.mod.ENMITY, 100)
    target:addMod(xi.mod.SHIELDBLOCKRATE, 30)
    target:addMod(xi.mod.REPRISAL_BLOCK_BONUS, 10)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.PALISADE_BLOCK_BONUS, effect:getPower())
    target:delMod(xi.mod.ENMITY, 100)
    target:delMod(xi.mod.SHIELDBLOCKRATE, 30)
    target:delMod(xi.mod.REPRISAL_BLOCK_BONUS, 10)
end

return effectObject
