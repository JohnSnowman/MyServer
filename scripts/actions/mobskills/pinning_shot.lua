-----------------------------------
--  Pinning Shot
--
--  Description: Delivers a threefold ranged attack to targets in an area of effect. Additional effect: Bind
--  Type: Physical
--  Utsusemi/Blink absorb: 2-3 shadows
--  Range: Unknown
--  Notes: Used only by Medusa.
-----------------------------------
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local numhits = math.random(2, 3)
    local accmod = 1
    local dmgmod = 1
    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, numhits, accmod, dmgmod, xi.mobskills.magicalTpBonus.NO_EFFECT)
    local dmg = xi.mobskills.mobFinalAdjustments(info.dmg, mob, skill, target, xi.attackType.RANGED, xi.damageType.PIERCING, info.hitslanded)

    local typeEffect = xi.effect.BIND

    xi.mobskills.mobPhysicalStatusEffectMove(mob, target, skill, typeEffect, 1, 0, 60)

    target:takeDamage(dmg, mob, xi.attackType.RANGED, xi.damageType.PIERCING)
    return dmg
end

return mobskillObject
