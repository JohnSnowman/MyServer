-----------------------------------
-- xi.effect.WARDING_CIRCLE
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.WARDING_CIRCLE_EFFECT)

    target:addMod(xi.mod.DEMON_KILLER, effect:getPower() + jpValue)
    target:addMod(xi.mod.STORETP, 125)
    target:addMod(xi.mod.HASTE_ABILITY, 1500)
    target:addMod(xi.mod.WEAPONSKILL_DAMAGE_BASE, 25)
    target:addMod(xi.mod.ALL_WSDMG_ALL_HITS, 100)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.WARDING_CIRCLE_EFFECT)

    target:delMod(xi.mod.DEMON_KILLER, effect:getPower() + jpValue)
    target:delMod(xi.mod.STORETP, 125)
    target:delMod(xi.mod.HASTE_ABILITY, 1500)
    target:delMod(xi.mod.WEAPONSKILL_DAMAGE_BASE, 25)
    target:delMod(xi.mod.ALL_WSDMG_ALL_HITS, 100)
end

return effectObject
