-----------------------------------
-- xi.effect.DEFENDER
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local jpLevel = target:getJobPointLevel(xi.jp.DEFENDER_EFFECT)

    target:addMod(xi.mod.DEFP, 100)
    target:addMod(xi.mod.RATTP, -25)
    target:addMod(xi.mod.ATTP, -25)
    
    target:addMod(xi.mod.MEVA, 75)
    target:addMod(xi.mod.MDEF, 40)
    target:addMod(xi.mod.DMG, -2500)
    target:addMod(xi.mod.DMGPHYS_II, -1000)
    target:addMod(xi.mod.DMGMAGIC_II, -1000)

    -- JP Bonus
    target:addMod(xi.mod.DEF, jpLevel * 3)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    local jpLevel = target:getJobPointLevel(xi.jp.DEFENDER_EFFECT)

    target:delMod(xi.mod.DEF, jpLevel * 3)
    target:delMod(xi.mod.DEFP, 100)
    target:delMod(xi.mod.ATTP, -25)
    target:delMod(xi.mod.RATTP, -25)
    
    target:delMod(xi.mod.MEVA, 75)
    target:delMod(xi.mod.MDEF, 40)
    target:delMod(xi.mod.DMG, -2500)
    target:delMod(xi.mod.DMGPHYS_II,-1000)
    target:delMod(xi.mod.DMGMAGIC_II, -1000)
end

return effectObject
