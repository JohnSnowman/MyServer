-----------------------------------
-- Spell: Drain III
-- Drain functions only on skill level!!
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    if target:isUndead() then
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT) -- No effect
        return 0
    end

    --calculate raw damage (unknown function  -> only dark skill though) - using http://www.bluegartr.com/threads/44518-Drain-Calculations
    -- also have small constant to account for 0 dark skill
    local dmg = 105 + (15 * caster:getSkillLevel(xi.skill.DARK_MAGIC))
    local targetHP = target:getHP()


    --get resist multiplier (1x if no resist)
    local params = {}
    params.diff = caster:getStat(xi.mod.INT)-target:getStat(xi.mod.INT)
    params.attribute = xi.mod.INT
    params.skillType = xi.skill.DARK_MAGIC
    params.bonus = 1.0
    local resist = applyResistance(caster, target, spell, params)
    --get the resisted damage
    dmg = dmg * resist
    --add on bonuses (staff/day/weather/jas/mab/etc all go in this function)
    dmg = addBonuses(caster, spell, target, dmg)
    --add in target adjustment
    dmg = adjustForTarget(target, dmg, spell:getElement())

    if dmg < 0 then
        dmg = 0
    end

    --add in final adjustments and deal damage
    dmg = finalMagicAdjustments(caster, target, spell, dmg)

    if targetHP < dmg then
        dmg = targetHP
    end

    local leftOver = (caster:getHP() + dmg) - caster:getMaxHP()

    if leftOver > 0 then
        caster:addStatusEffect(xi.effect.MAX_HP_BOOST, (leftOver / caster:getMaxHP()) * 100, 0, 3600)
    end

    caster:addHP(dmg)
    spell:setMsg(xi.msg.basic.MAGIC_DRAIN_HP) --change msg to 'xxx hp drained from the yyyy.'
    return dmg
end

return spellObject
