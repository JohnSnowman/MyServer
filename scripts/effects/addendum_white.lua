-----------------------------------
-- xi.effect.ADDENDUM_WHITE
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:recalculateAbilitiesTable()
    local bonus = effect:getPower()
    local regen = effect:getSubPower()

    target:addMod(xi.mod.WHITE_MAGIC_COST, -bonus)
    target:addMod(xi.mod.WHITE_MAGIC_CAST, -bonus)
    target:addMod(xi.mod.WHITE_MAGIC_RECAST, -bonus)

    if not (target:hasStatusEffect(xi.effect.TABULA_RASA)) then
        target:addMod(xi.mod.WHITE_MAGIC_COST, -40)
        target:addMod(xi.mod.WHITE_MAGIC_CAST, -40)
        target:addMod(xi.mod.WHITE_MAGIC_RECAST, -40)
        target:addMod(xi.mod.BLACK_MAGIC_COST, 40)
        target:addMod(xi.mod.BLACK_MAGIC_CAST, 40)
        target:addMod(xi.mod.BLACK_MAGIC_RECAST, 40)
        target:addMod(xi.mod.LIGHT_ARTS_REGEN, regen * 6)
        target:addMod(xi.mod.REGEN_DURATION, regen * 6)
        
        target:addMod(xi.mod.CURE_POTENCY, 40)
        target:addMod(xi.mod.CURE_POTENCY_II, 20)
        target:addMod(xi.mod.ENH_MAGIC_DURATION, 150)
    end

    target:recalculateSkillsTable()
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:recalculateAbilitiesTable()
    local bonus = effect:getPower()
    local regen = effect:getSubPower()

    target:delMod(xi.mod.WHITE_MAGIC_COST, -bonus)
    target:delMod(xi.mod.WHITE_MAGIC_CAST, -bonus)
    target:delMod(xi.mod.WHITE_MAGIC_RECAST, -bonus)

    if not (target:hasStatusEffect(xi.effect.TABULA_RASA)) then
        target:delMod(xi.mod.WHITE_MAGIC_COST, -40)
        target:delMod(xi.mod.WHITE_MAGIC_CAST, -40)
        target:delMod(xi.mod.WHITE_MAGIC_RECAST, -40)
        target:delMod(xi.mod.BLACK_MAGIC_COST, 40)
        target:delMod(xi.mod.BLACK_MAGIC_CAST, 40)
        target:delMod(xi.mod.BLACK_MAGIC_RECAST, 40)
        target:delMod(xi.mod.LIGHT_ARTS_REGEN, regen * 6)
        target:delMod(xi.mod.REGEN_DURATION, regen * 6)
        
        target:delMod(xi.mod.CURE_POTENCY, 40)
        target:delMod(xi.mod.CURE_POTENCY_II, 20)
        target:delMod(xi.mod.ENH_MAGIC_DURATION, 150)
    end

    target:recalculateSkillsTable()
end

return effectObject
