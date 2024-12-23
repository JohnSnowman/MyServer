-----------------------------------
-- xi.effect.ENLIGHT
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.ENLIGHT_EFFECT)
    local battleTarget = target:getTarget()

    target:addMod(xi.mod.ENSPELL, xi.element.LIGHT)
    target:addMod(xi.mod.ENSPELL_DMG, effect:getPower() + jpValue)
    target:addMod(xi.mod.ACC, jpValue)
    mob:addEnmity(player, 3000, 3000)
    --target:addEnmity(player, 450, 900)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.ENLIGHT_EFFECT)

    target:setMod(xi.mod.ENSPELL_DMG, 0)
    target:setMod(xi.mod.ENSPELL, 0)
    target:delMod(xi.mod.ACC, jpValue)
end

return effectObject
