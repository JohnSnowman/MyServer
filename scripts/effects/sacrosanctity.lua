-----------------------------------
-- xi.effect.SACROSANCTITY
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.MDEF, 75)
    target:addMod(xi.mod.MEVA, 150)
    target:addMod(xi.mod.DMG, -2500)
    target:addMod(xi.mod.DMGMAGIC_II, -2500)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.MDEF, 75)
    target:delMod(xi.mod.MEVA, 150)
    target:delMod(xi.mod.DMG, -2500)
    target:delMod(xi.mod.DMGMAGIC_II, -2500)
end

return effectObject
