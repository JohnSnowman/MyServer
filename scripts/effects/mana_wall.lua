-----------------------------------
-- xi.effect.MANA_WALL
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.DMG, -5000)
    target:addMod(xi.mod.UDMGPHYS, -2500)
    target:addMod(xi.mod.UDMGMAGIC, -2500)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.DMG, -5000)
    target:delMod(xi.mod.UDMGPHYS, -2500)
    target:delMod(xi.mod.UDMGMAGIC, -2500)
end

return effectObject
