-----------------------------------
-- Spell: Endark_II
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    
    target:addStatusEffect(xi.effect.BLOOD_WEAPON, 1, 0, 3600)

    spell:setMsg(xi.msg.basic.MAGIC_GAIN_EFFECT)
    
    --local effect = xi.effect.ENDARK_II
    --local magicskill = target:getSkillLevel(xi.skill.DARK_MAGIC)
    --local potency = (magicskill / 2) + 12.5

    --if target:addStatusEffect(effect, potency, 0, 3600) then
    --    spell:setMsg(xi.msg.basic.MAGIC_GAIN_EFFECT)
    --else
    --    spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
    --end

    return effect
end

return spellObject
