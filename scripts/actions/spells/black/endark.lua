-----------------------------------
-- Spell: Endark
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local effect = xi.effect.ENDARK
    --local magicskill = target:getSkillLevel(xi.skill.DARK_MAGIC)
    local potency = 0.1

    if target:addStatusEffect(effect, potency, 0, 1800) then
        spell:setMsg(xi.msg.basic.MAGIC_GAIN_EFFECT)
    else
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
    end

    return effect
end

return spellObject


--[[
-----------------------------------
-- Spell: Endark
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local effect = xi.effect.ENDARK
    local magicskill = target:getSkillLevel(xi.skill.DARK_MAGIC)
    local potency = (magicskill / 8) + 12.5

    if target:addStatusEffect(effect, potency, 0, 3600) then
        spell:setMsg(xi.msg.basic.MAGIC_GAIN_EFFECT)
    else
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
    end

    return effect
end

return spellObject
]]--
