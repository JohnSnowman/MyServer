-----------------------------------
-- xi.effect.HOLY_CIRCLE
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.UNDEAD_KILLER, effect:getPower())
    target:addMod(xi.mod.ENMITY, 150)
    target:addMod(xi.mod.DEFP, 150)
    target:addMod(xi.mod.MDEF, 40)
    target:addMod(xi.mod.DMG, -2500)
    target:addMod(xi.mod.DMGPHYS_II, -1000)
    target:addMod(xi.mod.DMGMAGIC_II, -1000)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.UNDEAD_KILLER, effect:getPower())
    target:delMod(xi.mod.ENMITY, 150)
    target:delMod(xi.mod.DEFP, 150)
    target:delMod(xi.mod.MDEF, 40)
    target:delMod(xi.mod.DMG, -2500)
    target:delMod(xi.mod.DMGPHYS_II,-1000)
    target:delMod(xi.mod.DMGMAGIC_II, -1000)
end

return effectObject
