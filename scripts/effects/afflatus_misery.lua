-----------------------------------
-- xi.effect.AFFLATUS_MISERY
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:setMod(xi.mod.AFFLATUS_MISERY, 0)
    target:addMod(xi.mod.MAGIC_DAMAGE , 200)
    target:addMod(xi.mod.MATT, 30)
    target:addMod(xi.mod.MACC, 50)
    target:addMod(xi.mod.FASTCAST, 25)

    if target:hasStatusEffect(xi.effect.AUSPICE) then
        local power = target:getStatusEffect(xi.effect.AUSPICE):getPower()
        target:addMod(xi.mod.ENSPELL, 18)
        target:addMod(xi.mod.ENSPELL_DMG, power)
    end
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:setMod(xi.mod.AFFLATUS_MISERY, 0)
    target:delMod(xi.mod.MAGIC_DAMAGE , 200)
    target:delMod(xi.mod.MATT, 30)
    target:delMod(xi.mod.MACC, 50)
    target:delMod(xi.mod.FASTCAST, 25)

    --Clean Up Afflatus Misery Bonuses
    local accuracyBonus = effect:getSubPower()

    target:delMod(xi.mod.ACC, accuracyBonus)

    if target:hasStatusEffect(xi.effect.AUSPICE) then
        target:setMod(xi.mod.ENSPELL, 0)
        target:setMod(xi.mod.ENSPELL_DMG, 0)
    end
end

return effectObject
