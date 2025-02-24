-----------------------------------
-- xi.effect.BOOST
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.ATTP, effect:getPower())
    target:addMod(xi.mod.MARTIAL_ARTS, 150)
    
    target:addMod(xi.mod.HASTE_ABILITY, 1000)
    target:addMod(xi.mod.DOUBLE_ATTACK, 15)
    target:addMod(xi.mod.DOUBLE_ATTACK_DMG, 50)
    target:addMod(xi.mod.MAIN_DMG_RATING, 15)
    target:addMod(xi.mod.STORETP, 70)
    target:addMod(xi.mod.WEAPONSKILL_DAMAGE_BASE, 15)
    target:addMod(xi.mod.ALL_WSDMG_ALL_HITS, 50)
    target:addMod(xi.mod.SAVETP, 250)
   
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.ATTP, effect:getPower())
    target:delMod(xi.mod.MARTIAL_ARTS, 150)
    
    target:delMod(xi.mod.HASTE_ABILITY, 1000)
    target:delMod(xi.mod.DOUBLE_ATTACK, 15)
    target:delMod(xi.mod.DOUBLE_ATTACK_DMG, 50)
    target:delMod(xi.mod.MAIN_DMG_RATING, 15)
    target:delMod(xi.mod.STORETP, 70)
    target:delMod(xi.mod.WEAPONSKILL_DAMAGE_BASE, 15)
    target:delMod(xi.mod.ALL_WSDMG_ALL_HITS, 50)
    target:delMod(xi.mod.SAVETP, 250)
end

return effectObject
