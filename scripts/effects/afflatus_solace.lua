-----------------------------------
-- xi.effect.AFFLATUS_SOLACE
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.AFFLATUS_SOLACE, 0)
    target:addMod(xi.mod.BARSPELL_MDEF_BONUS, 5)
    target:addMod(xi.mod.MAGIC_DAMAGE , 100)
    target:addMod(xi.mod.MATT, 10)
    target:addMod(xi.mod.MACC, 50)
    target:addMod(xi.mod.CURE_POTENCY_BONUS, 300)
    target:addMod(xi.mod.FASTCAST, 25)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.AFFLATUS_SOLACE, 0)
    target:delMod(xi.mod.BARSPELL_MDEF_BONUS, 5)
    target:delMod(xi.mod.MAGIC_DAMAGE , 100)
    target:delMod(xi.mod.MATT, 10)
    target:delMod(xi.mod.MACC, 50)
    target:delMod(xi.mod.CURE_POTENCY_BONUS, 300)
    target:delMod(xi.mod.FASTCAST, 25)
end

return effectObject
