-----------------------------------
-- Contains all common weaponskill calculations including but not limited to:
-- fSTR
-- Alpha
-- Ratio -> cRatio
-- min/max cRatio
-- applications of fTP
-- applications of critical hits ('Critical hit rate varies with TP.')
-- applications of accuracy mods ('Accuracy varies with TP.')
-- applications of damage mods ('Damage varies with TP.')
-- performance of the actual WS (rand numbers, etc)
-----------------------------------
require('scripts/globals/magicburst')
require('scripts/globals/ability')
require('scripts/globals/magic')
require('scripts/globals/utils')
require('scripts/globals/combat/physical_utilities')
-----------------------------------
xi = xi or {}
xi.weaponskills = xi.weaponskills or {}

-- Obtains alpha, used for working out WSC on legacy servers
-- Retail has no alpha anymore as of 2014. Weaponskill functions
-- should be checking for xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES and
-- overwriting the results of this function if the server has it set
local function getAlpha(level)
    local alpha = 1

    if level > 75 then
        alpha = 0.85
    elseif level > 59 then
        alpha = 0.9 - math.floor((level - 60) / 2) / 100
    elseif level > 5 then
        alpha = 1 - math.floor(level / 6) / 100
    end

    return alpha
end

-- Returns fSTR based on range and divisor
local function calculateRawFstr(dSTR, divisor)
    local fSTR = 0

    if dSTR >= 12 then
        fSTR = dSTR + 4
    elseif dSTR >= 6 then
        fSTR = dSTR + 6
    elseif dSTR >= 1 then
        fSTR = dSTR + 7
    elseif dSTR >= -2 then
        fSTR = dSTR + 8
    elseif dSTR >= -7 then
        fSTR = dSTR + 9
    elseif dSTR >= -15 then
        fSTR = dSTR + 10
    elseif dSTR >= -21 then
        fSTR = dSTR + 12
    else
        fSTR = dSTR + 13
    end

    return fSTR / divisor
end

-- Given the attacker's str and the mob's vit, fSTR2 is calculated (for ranged WS)
xi.weaponskills.fSTR2 = function(atkStr, defVit, weaponRank)
    local dSTR  = atkStr - defVit
    local fSTR2 = calculateRawFstr(dSTR, 2)

    -- Apply fSTR2 caps.
    local lowerCap = weaponRank * -2

    if weaponRank == 0 then
        lowerCap = -2
    elseif weaponRank == 1 then
        lowerCap = -3
    end

    fSTR2 = utils.clamp(fSTR2, lowerCap, (weaponRank + 8) * 2)

    return fSTR2
end

-- http://wiki.ffo.jp/html/1705.html
-- https://www.ffxiah.com/forum/topic/21497/stalwart-soul/ some anecdotal data that aligns with JP
-- https://www.bg-wiki.com/ffxi/Agwu%27s_Scythe Souleater Effect that goes beyond established cap, Stalwart Soul bonus being additive to trait
local function souleaterBonus(attacker, wsParams)
    if attacker:hasStatusEffect(xi.effect.SOULEATER) then
        local souleaterEffect   = attacker:getMaxGearMod(xi.mod.SOULEATER_EFFECT) / 100
        local souleaterEffectII = attacker:getMod(xi.mod.SOULEATER_EFFECT_II) / 100
        local stalwartSoulBonus = 1 - attacker:getMod(xi.mod.STALWART_SOUL) / 100
        local bonusDamage       = math.floor(attacker:getHP() * (0.1 + souleaterEffect + souleaterEffectII))

        if bonusDamage >= 1 then
            attacker:delHP(utils.stoneskin(attacker, bonusDamage * stalwartSoulBonus))

            if attacker:getMainJob() ~= xi.job.DRK then
                return math.floor(bonusDamage / 2)
            end

            return bonusDamage
        end
    end

    return 0
end

local scarletDeliriumBonus = function(attacker)
    local bonus = 1

    if attacker:hasStatusEffect(xi.effect.SCARLET_DELIRIUM_1) then
        local power = attacker:getStatusEffect(xi.effect.SCARLET_DELIRIUM_1):getPower()

        bonus = 1 + power / 100
    end

    return bonus
end

local function shadowAbsorb(target)
    local targetShadows = target:getMod(xi.mod.UTSUSEMI)
    local shadowType    = xi.mod.UTSUSEMI

    if targetShadows == 0 then
        if math.random(1, 100) <= 80 then
            targetShadows = target:getMod(xi.mod.BLINK)
            shadowType    = xi.mod.BLINK
        end
    end

    if targetShadows > 0 then
        targetShadows = targetShadows - 1

        if shadowType == xi.mod.UTSUSEMI then
            local effect = target:getStatusEffect(xi.effect.COPY_IMAGE)
            if effect then
                if targetShadows == 1 then
                    effect:setIcon(xi.effect.COPY_IMAGE)
                elseif targetShadows == 2 then
                    effect:setIcon(xi.effect.COPY_IMAGE_2)
                elseif targetShadows == 3 then
                    effect:setIcon(xi.effect.COPY_IMAGE_3)
                end
            end
        end

        target:setMod(shadowType, targetShadows)
        if targetShadows == 0 then
            target:delStatusEffect(xi.effect.COPY_IMAGE)
            target:delStatusEffect(xi.effect.BLINK)
        end

        return true
    end

    return false
end

local function accVariesWithTP(baseHitRate, acc, tp, a1, a2, a3)
    -- acc varies with tp ALL apply an acc PENALTY, the acc at various %s are given as a1 a2 a3
    local accLost      = acc - acc * xi.weaponskills.fTP(tp, a1, a2, a3)
    local finalHitRate = baseHitRate - accLost / 200

    finalHitRate = utils.clamp(finalHitRate, 0.2, 1)

    return finalHitRate
end

local function getMultiAttacks(attacker, target, wsParams, firstHit, offHand)
    local numHits      = 0
    local bonusHits    = 0
    local doubleRate   = attacker:getMod(xi.mod.DOUBLE_ATTACK) + attacker:getMerit(xi.merit.DOUBLE_ATTACK_RATE)
    local tripleRate   = attacker:getMod(xi.mod.TRIPLE_ATTACK) + attacker:getMerit(xi.merit.TRIPLE_ATTACK_RATE)
    local quadRate     = attacker:getMod(xi.mod.QUAD_ATTACK)
    local oaThriceRate = attacker:getMod(xi.mod.MYTHIC_OCC_ATT_THRICE)
    local oaTwiceRate  = attacker:getMod(xi.mod.MYTHIC_OCC_ATT_TWICE)
    local isJump       = wsParams.isJump or false

    if isJump then
        doubleRate = doubleRate + attacker:getMod(xi.mod.JUMP_DOUBLE_ATTACK)
    end

    -- TODO: Assasin vest +2 Ambush augment.
    -- The logic here wasnt actually checking for the augment.
    -- Also, it was in a completely different scale, making triple attack trigger always.

    if math.random(1, 100) <= quadRate then
        bonusHits = bonusHits + 3
    elseif math.random(1, 100) <= tripleRate then
        bonusHits = bonusHits + 2
    elseif math.random(1, 100) <= doubleRate then
        bonusHits = bonusHits + 1
    elseif firstHit and math.random(1, 100) <= oaThriceRate then -- Can only proc on first hit
        bonusHits = bonusHits + 2
    elseif firstHit and math.random(1, 100) <= oaTwiceRate then -- Can only proc on first hit
        bonusHits = bonusHits + 1
    end

    attacker:delStatusEffect(xi.effect.ASSASSINS_CHARGE)
    attacker:delStatusEffect(xi.effect.WARRIORS_CHARGE)

    -- Try OaX for Jumps
    -- ... What's the correct dual wield interaction?
    if isJump and bonusHits == 0 and attacker:isPC() then
        -- getWeaponHitCount will always return 1 if there's a weapon in the slot, which is already accounted for.
        if offHand then
            bonusHits = attacker:getWeaponHitCount(true) - 1
        else
            bonusHits = attacker:getWeaponHitCount(false) - 1
        end
    end

    numHits = numHits + bonusHits

    return numHits
end

local function cRangedRatio(attacker, defender, params, ignoredDef, tp)
    local atkmulti        = xi.weaponskills.fTP(tp, params.atk100, params.atk200, params.atk300)
    local cratio          = attacker:getRATT() / (defender:getStat(xi.mod.DEF) - ignoredDef)
    local levelCorrection = 0

    if attacker:getMainLvl() < defender:getMainLvl() then
        levelCorrection = (defender:getMainLvl() - attacker:getMainLvl()) / 40
    end

    cratio = cratio - levelCorrection
    cratio = cratio * atkmulti

    -- adding cap check base on weapon https://www.bg-wiki.com/ffxi/PDIF info
    local weaponType = attacker:getWeaponSkillType(xi.slot.RANGED)
    local cRatioCap  = 0

    if weaponType == xi.skill.MARKSMANSHIP then
        cRatioCap = 3.5
    else
        cRatioCap = 3.25
    end

    if cratio < 0 then
        cratio = 0
    elseif cratio > cRatioCap then
        cratio = cRatioCap
    end

    -- max
    local pdifmax = 0

    if cratio < 0.9 then
        pdifmax = cratio * 10 / 9
    elseif cratio < 1.1 then
        pdifmax = 1
    else
        pdifmax = cratio
    end

    -- min
    local pdifmin = 0

    if cratio < 0.9 then
        pdifmin = cratio
    elseif cratio < 1.1 then
        pdifmin = 1
    else
        pdifmin = cratio * 20 / 19 - 3 / 19
    end

    local pdif = {}
    pdif[1] = pdifmin
    pdif[2] = pdifmax

    local pdifcrit = {}

    pdifmin = pdifmin * 1.25
    pdifmax = pdifmax * 1.25

    pdifcrit[1] = pdifmin
    pdifcrit[2] = pdifmax

    return pdif, pdifcrit
end

local function getRangedHitRate(attacker, target, capHitRate, bonus)
    local acc = attacker:getRACC()
    local eva = target:getEVA()

    if bonus == nil then
        bonus = 0
    end

    if
        target:hasStatusEffect(xi.effect.YONIN) and
        target:isFacing(attacker, 23)
    then
        -- Yonin evasion boost if defender is facing attacker
        bonus = bonus - target:getStatusEffect(xi.effect.YONIN):getPower()
    end

    if attacker:hasTrait(76) and attacker:isBehind(target, 23) then --TRAIT_AMBUSH
        bonus = bonus + attacker:getMerit(xi.merit.AMBUSH)
    end

    acc = acc + bonus

    if attacker:getMainLvl() > target:getMainLvl() then -- acc bonus
        acc = acc + (attacker:getMainLvl() - target:getMainLvl()) * 4
    elseif attacker:getMainLvl() < target:getMainLvl() then -- acc penalty
        acc = acc - (target:getMainLvl() - attacker:getMainLvl()) * 4
    end

    local hitdiff = 0
    local hitrate = 75

    hitdiff = (acc - eva) / 2 -- no need to check if eva is hier or lower than acc it will be negative if eva is higher and positive if acc is higher

    hitrate = hitrate + hitdiff
    hitrate = hitrate / 100

    -- Applying hitrate caps
    if capHitRate then -- this isn't capped for when acc varies with tp, as more penalties are due
        if hitrate > 1 then
            hitrate = 1
        end
    end

    if hitrate < 0.2 then
        hitrate = 0.2
    end

    return hitrate
end

-- Function to calculate if a hit in a WS misses, criticals, and the respective damage done
local function getSingleHitDamage(attacker, target, dmg, wsParams, calcParams)
    local criticalHit = false
    local finaldmg    = 0
    -- local pdif = 0 Reminder for Future Implementation!

    local missChance = math.random()

    if
        (missChance <= calcParams.hitRate or -- See if we hit the target
        calcParams.guaranteedHit) and
        not calcParams.mustMiss
    then
        if not shadowAbsorb(target) then
            local critChance = math.random() -- See if we land a critical hit
            criticalHit = (wsParams.canCrit and critChance <= calcParams.critRate) or
                calcParams.forcedFirstCrit or
                calcParams.mightyStrikesApplicable

            if criticalHit then
                calcParams.criticalHit = true
                calcParams.pdif = xi.weaponskills.generatePdif(calcParams.ccritratio[1], calcParams.ccritratio[2], true)
            else
                calcParams.pdif = xi.weaponskills.generatePdif(calcParams.cratio[1], calcParams.cratio[2], true)
            end

            finaldmg = dmg * calcParams.pdif

            -- Duplicate the first hit with an added magical component for hybrid WSes
            if calcParams.hybridHit then
                -- Calculate magical bonuses and reductions
                local magicdmg = addBonusesAbility(attacker, wsParams.ele, target, finaldmg, wsParams)
                local baseMagicDamageBonus = attacker:getMod(xi.mod.MAGIC_DAMAGE)
                local MAB_Bonus = attacker:getMod(xi.mod.MATT) / 100
                
                --magicdmg = magicdmg + baseMagicDamageBonus
                magicdmg = finaldmg + baseMagicDamageBonus
                magicdmg = magicdmg * (1 + MAB_Bonus)
                magicdmg = magicdmg * applyResistanceAbility(attacker, target, wsParams.ele, wsParams.skill, calcParams.bonusAcc)
                magicdmg = target:magicDmgTaken(magicdmg, wsParams.ele)

                if magicdmg > 0 then
                    magicdmg = adjustForTarget(target, magicdmg, wsParams.ele) -- this may absorb or nullify
                end

                if magicdmg > 0 then                                           -- handle nonzero damage if previous function does not absorb or nullify
                    magicdmg = magicdmg - target:getMod(xi.mod.PHALANX)
                    magicdmg = utils.clamp(magicdmg, 0, 99999)
                    magicdmg = utils.oneforall(target, magicdmg)
                    magicdmg = utils.stoneskin(target, magicdmg)
                end

                finaldmg = finaldmg + magicdmg
            end

            calcParams.hitsLanded = calcParams.hitsLanded + 1
        else
            calcParams.shadowsAbsorbed = calcParams.shadowsAbsorbed + 1
        end
    end

    return finaldmg, calcParams
end

local function modifyMeleeHitDamage(attacker, target, attackTbl, wsParams, rawDamage)
    local adjustedDamage = rawDamage

    if not wsParams.formless then
        adjustedDamage = target:physicalDmgTaken(adjustedDamage, attackTbl.damageType)

        if attackTbl.weaponType == xi.skill.HAND_TO_HAND then
            adjustedDamage = adjustedDamage * target:getMod(xi.mod.HTH_SDT) / 1000
        elseif
            attackTbl.weaponType == xi.skill.DAGGER or
            attackTbl.weaponType == xi.skill.POLEARM
        then
            adjustedDamage = adjustedDamage * target:getMod(xi.mod.PIERCE_SDT) / 1000
        elseif
            attackTbl.weaponType == xi.skill.CLUB or
            attackTbl.weaponType == xi.skill.STAFF
        then
            adjustedDamage = adjustedDamage * target:getMod(xi.mod.IMPACT_SDT) / 1000
        else
            adjustedDamage = adjustedDamage * target:getMod(xi.mod.SLASH_SDT) / 1000
        end
    end

    -- Scarlet Delirium
    adjustedDamage = adjustedDamage * scarletDeliriumBonus(attacker)

    -- Souleater
    adjustedDamage = adjustedDamage + souleaterBonus(attacker, wsParams)

    if adjustedDamage > 0 then
        adjustedDamage = adjustedDamage - target:getMod(xi.mod.PHALANX)
        adjustedDamage = utils.clamp(adjustedDamage, 0, 99999)
    end

    adjustedDamage = utils.stoneskin(target, adjustedDamage)

    return adjustedDamage
end

local modParameters =
{
    [xi.mod.WS_STR_BONUS] = 'str_wsc',
    [xi.mod.WS_DEX_BONUS] = 'dex_wsc',
    [xi.mod.WS_VIT_BONUS] = 'vit_wsc',
    [xi.mod.WS_AGI_BONUS] = 'agi_wsc',
    [xi.mod.WS_INT_BONUS] = 'int_wsc',
    [xi.mod.WS_MND_BONUS] = 'mnd_wsc',
    [xi.mod.WS_CHR_BONUS] = 'chr_wsc',
}

local function calculateWsMods(attacker, calcParams, wsParams)
    local wsMods = calcParams.fSTR + calcParams.alpha *
        (attacker:getStat(xi.mod.STR) * wsParams.str_wsc +
        attacker:getStat(xi.mod.DEX) * wsParams.dex_wsc +
        attacker:getStat(xi.mod.VIT) * wsParams.vit_wsc +
        attacker:getStat(xi.mod.AGI) * wsParams.agi_wsc +
        attacker:getStat(xi.mod.INT) * wsParams.int_wsc +
        attacker:getStat(xi.mod.MND) * wsParams.mnd_wsc +
        attacker:getStat(xi.mod.CHR) * wsParams.chr_wsc)
    return wsMods
end

-- Calculates the raw damage for a weaponskill, used by both xi.weaponskills.doPhysicalWeaponskill and xi.weaponskills.doRangedWeaponskill.
-- Behavior of damage calculations can vary based on the passed in calcParams, which are determined by the calling function
-- depending on the type of weaponskill being done, and any special cases for that weaponskill
--
-- wsParams can contain: ftp100, ftp200, ftp300, str_wsc, dex_wsc, vit_wsc, int_wsc, mnd_wsc, canCrit, crit100, crit200, crit300,
-- acc100, acc200, acc300, ignoresDef, ignore100, ignore200, ignore300, atk100, atk200, atk300, kick, hybridWS, hitsHigh, formless
--
-- See xi.weaponskills.doPhysicalWeaponskill or xi.weaponskills.doRangedWeaponskill for how calcParams are determined.

-- TODO: Reduce complexity
-- Disable cyclomatic complexity check for this function:
-- luacheck: ignore 561
xi.weaponskills.calculateRawWSDmg = function(attacker, target, wsID, tp, action, wsParams, calcParams)
    local targetLvl = target:getMainLvl()
    local targetHp  = target:getHP() + target:getMod(xi.mod.STONESKIN)

    -- Recalculate accuracy if it varies with TP, applied to all hits
    if wsParams.acc100 ~= 0 then
        calcParams.hitRate = accVariesWithTP(calcParams.hitRate, calcParams.accStat, tp, wsParams.acc100, wsParams.acc200, wsParams.acc300)
    else
        -- clamp hitRate now if accuracy doesn't vary with TP
        calcParams.hitRate = utils.clamp(calcParams.hitRate, 0.2, 1)
    end

    -- Calculate alpha, WSC, and our modifiers for our base per-hit damage
    if not calcParams.alpha then
        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            calcParams.alpha = 1
        else
            calcParams.alpha = getAlpha(attacker:getMainLvl())
        end
    end

    -- Begin Checks for bonus wsc bonuses. See the following for details:
    -- https://www.bg-wiki.com/bg/Utu_Grip
    -- https://www.bluegartr.com/threads/108199-Random-Facts-Thread-Other?p=6826618&viewfull=1#post6826618

    for modId, parameterName in pairs(modParameters) do
        if attacker:getMod(modId) > 0 then
            wsParams[parameterName] = wsParams[parameterName] + (attacker:getMod(modId) / 100)
        end
    end

    local wsMods   = calculateWsMods(attacker, calcParams, wsParams)
    local mainBase = calcParams.weaponDamage[1] + wsMods + calcParams.bonusWSmods

    -- Calculate fTP multiplier
    local ftp = xi.weaponskills.fTP(tp, wsParams.ftp100, wsParams.ftp200, wsParams.ftp300) + calcParams.bonusfTP

    -- Calculate critrates
    local criticalRate = 0

    -- TODO: calc per-hit with weapon crit+% on each hand (if dual wielding)
    if wsParams.canCrit then -- Work out critical hit ratios
        criticalRate = xi.combat.physical.calculateSwingCriticalRate(attacker, target, true, wsParams.crit100, wsParams.crit200, wsParams.crit300)
    end

    calcParams.critRate = criticalRate

    -- Start the WS
    local hitsDone                = 1
    local hitdmg                  = 0
    local finaldmg                = 0
    local mainhandTPGain          = xi.combat.tp.getSingleWeaponTPReturn(attacker, xi.slot.MAIN)
    local subTPGain               = xi.combat.tp.getSingleWeaponTPReturn(attacker, xi.slot.SUB)
    local isJump                  = wsParams.isJump or false
    local attackerTPMult          = wsParams.attackerTPMult or 1
    calcParams.hitsLanded         = 0
    calcParams.shadowsAbsorbed    = 0
    calcParams.mainhandHitsLanded = 0
    calcParams.offhandHitsLanded  = 0

    -- Calculate the damage from the first hit
    if
        not isJump and
        calcParams.firstHitRate
    then
        calcParams.origHitRate = calcParams.hitRate
        calcParams.hitRate = calcParams.firstHitRate
    end

    local dmg = mainBase * ftp
    hitdmg, calcParams = getSingleHitDamage(attacker, target, dmg, wsParams, calcParams)

    if
        not isJump and
        calcParams.origHitRate
    then
        calcParams.hitRate = calcParams.origHitRate
    end

    if calcParams.melee then
        hitdmg = modifyMeleeHitDamage(attacker, target, calcParams.attackInfo, wsParams, hitdmg)
    end

    if calcParams.skillType and hitdmg > 0 then
        attacker:trySkillUp(calcParams.skillType, targetLvl)

        if isJump then
            attacker:addTP(mainhandTPGain * attackerTPMult)
        end
    end

    finaldmg = finaldmg + hitdmg

    calcParams.tpHitsLanded   = calcParams.hitsLanded -- Store number of TP hits that have landed thus far
    calcParams.mainHitsLanded = calcParams.tpHitsLanded
    -- Finish first/mainhand hit

    local numMainHandMultis = getMultiAttacks(attacker, target, wsParams, true, false)
    local numOffhandMultis  = 0
    local numMultiProcs     = numMainHandMultis > 0 and 1 or 0

    -- Have to calculate added bonus for SA/TA here since it is done outside of the fTP multiplier
    if attacker:getMainJob() == xi.job.THF then
        -- Add DEX/AGI bonus to first hit if THF main and valid Sneak/Trick Attack
        if calcParams.sneakApplicable then
            finaldmg = finaldmg + calcParams.pdif * attacker:getStat(xi.mod.DEX) * (1 + attacker:getMod(xi.mod.SNEAK_ATK_DEX) / 100) * (1 + attacker:getMod(xi.mod.AUGMENTS_SA) / 100)
        end

        if calcParams.trickApplicable then
            finaldmg = finaldmg + calcParams.pdif * attacker:getStat(xi.mod.AGI) * (1 + attacker:getMod(xi.mod.TRICK_ATK_AGI) / 100) * (1 + attacker:getMod(xi.mod.AUGMENTS_TA) / 100)
        end
    end

    -- We've now accounted for any crit from SA/TA, or damage bonus for a Hybrid WS, so nullify them
    calcParams.forcedFirstCrit = false
    calcParams.hybridHit       = false

    -- For items that apply bonus damage to the first hit of a weaponskill (but not later hits),
    -- store bonus damage for first hit, for use after other calculations are done
    local firstHitBonus = finaldmg * attacker:getMod(xi.mod.ALL_WSDMG_FIRST_HIT) / 100

    -- Reset fTP if it's not supposed to carry over across all hits for this WS
    -- We'll recalculate our mainhand damage after doing offhand
    if not wsParams.multiHitfTP then
        ftp = 1
    end

    local offhandSkill = attacker:getWeaponSkillType(xi.slot.SUB)
    if calcParams.skillType == xi.skill.HAND_TO_HAND then
        offhandSkill = xi.skill.HAND_TO_HAND
        subTPGain    = mainhandTPGain
    end

    -- Do the extra hit for our offhand if applicable
    if calcParams.extraOffhandHit and finaldmg < targetHp then
        calcParams.hitsLanded = 0
        local offhandDmg      = (calcParams.weaponDamage[2] + wsMods) * ftp
        hitdmg, calcParams    = getSingleHitDamage(attacker, target, offhandDmg, wsParams, calcParams)

        if calcParams.melee then
            hitdmg = modifyMeleeHitDamage(attacker, target, calcParams.attackInfo, wsParams, hitdmg)
        end

        if hitdmg > 0 then
            attacker:trySkillUp(offhandSkill, targetLvl)

            if isJump then
                attacker:addTP(subTPGain * attackerTPMult)
            end
        end

        finaldmg = finaldmg + hitdmg
        hitsDone = hitsDone + 1

        calcParams.tpHitsLanded      = calcParams.tpHitsLanded + calcParams.hitsLanded
        calcParams.offhandHitsLanded = calcParams.hitsLanded

        numOffhandMultis = getMultiAttacks(attacker, target, wsParams, false, true)
        numMultiProcs    = numOffhandMultis > 0 and numMultiProcs + 1 or numMultiProcs
    end

    calcParams.guaranteedHit = false -- Accuracy bonus from SA/TA applies only to first main and offhand hit

    dmg = mainBase * ftp

    -- First mainhand hit is already accounted for
    local mainhandHits     = wsParams.numHits - 1
    local mainhandHitsDone = 0

    -- Use up any remaining hits in the WS's numhits
    while hitsDone < 8 and mainhandHitsDone < mainhandHits and finaldmg < targetHp do
        calcParams.hitsLanded = 0
        hitdmg, calcParams    = getSingleHitDamage(attacker, target, dmg, wsParams, calcParams)

        if calcParams.melee then
            hitdmg = modifyMeleeHitDamage(attacker, target, calcParams.attackInfo, wsParams, hitdmg)
        end

        if hitdmg > 0 then
            attacker:trySkillUp(calcParams.skillType, targetLvl)

            if isJump then
                attacker:addTP(mainhandTPGain * attackerTPMult)
            end
        end

        finaldmg                  = finaldmg + hitdmg
        hitsDone                  = hitsDone + 1
        mainhandHitsDone          = mainhandHitsDone + 1
        calcParams.mainHitsLanded = calcParams.mainHitsLanded + calcParams.hitsLanded

        -- Check each hit for multis, but stop after we get 2 multi procs
        if numMultiProcs < 2 then
            local extraMultis = getMultiAttacks(attacker, target, wsParams, false, false)
            numMainHandMultis = numMainHandMultis + extraMultis
            numMultiProcs     = extraMultis > 0 and numMultiProcs + 1 or numMultiProcs
        end
    end

    -- Proc any mainhand multi attacks.
    local mainhandMultiHitsDone = 0

    while hitsDone < 8 and mainhandMultiHitsDone < numMainHandMultis and finaldmg < targetHp do
        calcParams.hitsLanded = 0
        hitdmg, calcParams    = getSingleHitDamage(attacker, target, dmg, wsParams, calcParams)

        if calcParams.melee then
            hitdmg = modifyMeleeHitDamage(attacker, target, calcParams.attackInfo, wsParams, hitdmg)
        end

        if hitdmg > 0 then
            attacker:trySkillUp(calcParams.skillType, targetLvl)

            if isJump then
                attacker:addTP(mainhandTPGain * attackerTPMult)
            end
        end

        finaldmg                  = finaldmg + hitdmg
        hitsDone                  = hitsDone + 1
        mainhandMultiHitsDone     = mainhandMultiHitsDone + 1
        calcParams.mainHitsLanded = calcParams.mainHitsLanded + calcParams.hitsLanded
    end

    -- Proc any offhand multi attacks.
    local offhandMultiHitsDone = 0
    while hitsDone < 8 and offhandMultiHitsDone < numOffhandMultis and finaldmg < targetHp do
        local offhandDmg      = (calcParams.weaponDamage[2] + wsMods) * ftp
        calcParams.hitsLanded = 0
        hitdmg, calcParams    = getSingleHitDamage(attacker, target, offhandDmg, wsParams, calcParams)

        if calcParams.melee then
            hitdmg = modifyMeleeHitDamage(attacker, target, calcParams.attackInfo, wsParams, hitdmg)
        end

        if hitdmg > 0 then
            attacker:trySkillUp(offhandSkill, targetLvl)

            if isJump then
                attacker:addTP(subTPGain * attackerTPMult)
            end
        end

        finaldmg                     = finaldmg + hitdmg
        hitsDone                     = hitsDone + 1
        offhandMultiHitsDone         = offhandMultiHitsDone + 1
        calcParams.offhandHitsLanded = calcParams.offhandHitsLanded + calcParams.hitsLanded
    end

    calcParams.extraHitsLanded = calcParams.mainHitsLanded + calcParams.offhandHitsLanded

    -- Remove the TP hit landed from the count if it did -- otherwise we would gain extra TP
    if calcParams.tpHitsLanded > 1 then
        calcParams.extraHitsLanded = calcParams.extraHitsLanded - 1
    end

    -- Factor in "all hits" bonus damage mods
    -- TODO: does this apply to every hit of a multi hit WS as it's coming in to account for potentially excess damage here?
    local bonusdmg = 0

    if not isJump then
        bonusdmg = attacker:getMod(xi.mod.ALL_WSDMG_ALL_HITS) -- For any WS

        if
            attacker:getMod(xi.mod.WEAPONSKILL_DAMAGE_BASE + wsID) > 0 and
            not attacker:isPet()
        then
            -- For specific WS
            bonusdmg = bonusdmg + attacker:getMod(xi.mod.WEAPONSKILL_DAMAGE_BASE + wsID)
        end

        finaldmg = finaldmg * (100 + bonusdmg) / 100 -- Apply our "all hits" WS dmg bonuses
        finaldmg = finaldmg + firstHitBonus -- Finally add in our "first hit" WS dmg bonus from before
    end

    -- Return our raw damage to then be modified by enemy reductions based off of melee/ranged
    calcParams.finalDmg = finaldmg

    return calcParams
end

-- Sets up the necessary calcParams for a melee WS before passing it to calculateRawWSDmg. When the raw
-- damage is returned, handles reductions based on target resistances and passes off to xi.weaponskills.takeWeaponskillDamage.
xi.weaponskills.doPhysicalWeaponskill = function(attacker, target, wsID, wsParams, tp, action, primaryMsg, taChar)
    -- Determine cratio and ccritratio
    local ignoredDef = 0

    if wsParams.ignoresDef then
        ignoredDef = xi.weaponskills.calculatedIgnoredDef(tp, target:getStat(xi.mod.DEF), wsParams.ignored100, wsParams.ignored200, wsParams.ignored300)
    end

    local cratio, ccritratio = xi.weaponskills.cMeleeRatio(attacker, target, wsParams, ignoredDef, tp)

    -- Set up conditions and wsParams used for calculating weaponskill damage
    local gorgetBeltFTP, gorgetBeltAcc = xi.weaponskills.handleWSGorgetBelt(attacker)
    local attack =
    {
        ['type']       = xi.attackType.PHYSICAL,
        ['slot']       = xi.slot.MAIN,
        ['weaponType'] = attacker:getWeaponSkillType(xi.slot.MAIN),
        ['damageType'] = attacker:getWeaponDamageType(xi.slot.MAIN)
    }

    local calcParams = {}
    calcParams.wsID                    = wsID
    calcParams.attackInfo              = attack
    calcParams.weaponDamage            = xi.weaponskills.getMeleeDmg(attacker, attack.weaponType, wsParams.kick)
    calcParams.fSTR                    = xi.weaponskills.fSTR(attacker:getStat(xi.mod.STR), target:getStat(xi.mod.VIT), attacker:getWeaponDmgRank())
    calcParams.cratio                  = cratio
    calcParams.ccritratio              = ccritratio
    calcParams.accStat                 = attacker:getACC()
    calcParams.melee                   = true
    calcParams.mustMiss                = target:hasStatusEffect(xi.effect.PERFECT_DODGE) or (target:hasStatusEffect(xi.effect.ALL_MISS) and not wsParams.hitsHigh)
    calcParams.sneakApplicable         = attacker:hasStatusEffect(xi.effect.SNEAK_ATTACK) and (attacker:isBehind(target) or attacker:hasStatusEffect(xi.effect.HIDE) or target:hasStatusEffect(xi.effect.DOUBT))
    calcParams.taChar                  = taChar
    calcParams.trickApplicable         = calcParams.taChar ~= nil
    calcParams.assassinApplicable      = calcParams.trickApplicable and attacker:hasTrait(68)
    calcParams.guaranteedHit           = calcParams.sneakApplicable or calcParams.trickApplicable
    calcParams.mightyStrikesApplicable = attacker:hasStatusEffect(xi.effect.MIGHTY_STRIKES)
    calcParams.forcedFirstCrit         = calcParams.sneakApplicable or calcParams.assassinApplicable
    calcParams.extraOffhandHit         = attacker:isDualWielding() or attack.weaponType == xi.skill.HAND_TO_HAND
    calcParams.hybridHit               = wsParams.hybridWS
    calcParams.flourishEffect          = attacker:getStatusEffect(xi.effect.BUILDING_FLOURISH)
    calcParams.bonusTP                 = wsParams.bonusTP or 0

    local isJump = wsParams.isJump or false
    if isJump then
        calcParams.bonusfTP    = 0
        calcParams.bonusAcc    = attacker:getMod(xi.mod.JUMP_ACC_BONUS)
        calcParams.bonusWSmods = 0
    else
        calcParams.bonusfTP    = gorgetBeltFTP or 0
        calcParams.bonusAcc    = (gorgetBeltAcc or 0) + attacker:getMod(xi.mod.WSACC)
        calcParams.bonusWSmods = wsParams.bonusWSmods or 0
    end

    calcParams.firstHitRate = xi.weaponskills.getHitRate(attacker, target, true, calcParams.bonusAcc + 100)
    calcParams.hitRate      = xi.weaponskills.getHitRate(attacker, target, false, calcParams.bonusAcc)
    calcParams.skillType    = attack.weaponType

    -- Send our wsParams off to calculate our raw WS damage, hits landed, and shadows absorbed
    calcParams     = xi.weaponskills.calculateRawWSDmg(attacker, target, wsID, tp, action, wsParams, calcParams)
    local finaldmg = calcParams.finalDmg

    -- Delete statuses that may have been spent by the WS
    attacker:delStatusEffectsByFlag(xi.effectFlag.DETECTABLE)
    -- attacker:delStatusEffect(xi.effect.SNEAK_ATTACK)
    attacker:delStatusEffectSilent(xi.effect.BUILDING_FLOURISH)

    finaldmg            = finaldmg * xi.settings.main.WEAPON_SKILL_POWER -- Add server bonus
    calcParams.finalDmg = finaldmg
    finaldmg            = xi.weaponskills.takeWeaponskillDamage(target, attacker, wsParams, primaryMsg, attack, calcParams, action)

    return finaldmg, calcParams.criticalHit, calcParams.tpHitsLanded, calcParams.extraHitsLanded, calcParams.shadowsAbsorbed
end

-- Sets up the necessary calcParams for a ranged WS before passing it to calculateRawWSDmg. When the raw
-- damage is returned, handles reductions based on target resistances and passes off to xi.weaponskills.takeWeaponskillDamage.
xi.weaponskills.doRangedWeaponskill = function(attacker, target, wsID, wsParams, tp, action, primaryMsg)
    -- Determine cratio and ccritratio
    local ignoredDef = 0

    if wsParams.ignoresDef then
        ignoredDef = xi.weaponskills.calculatedIgnoredDef(tp, target:getStat(xi.mod.DEF), wsParams.ignored100, wsParams.ignored200, wsParams.ignored300)
    end

    local cratio, ccritratio = cRangedRatio(attacker, target, wsParams, ignoredDef, tp)

    -- Set up conditions and params used for calculating weaponskill damage
    local gorgetBeltFTP, gorgetBeltAcc = xi.weaponskills.handleWSGorgetBelt(attacker)
    local attack =
    {
        ['type']       = xi.attackType.RANGED,
        ['slot']       = xi.slot.RANGED,
        ['weaponType'] = attacker:getWeaponSkillType(xi.slot.RANGED),
        ['damageType'] = attacker:getWeaponDamageType(xi.slot.RANGED)
    }

    local calcParams =
    {
        wsID                    = wsID,
        weaponDamage            = { attacker:getRangedDmg() },
        skillType               = attacker:getWeaponSkillType(xi.slot.RANGED),
        fSTR                    = xi.weaponskills.fSTR2(attacker:getStat(xi.mod.STR), target:getStat(xi.mod.VIT), attacker:getRangedDmgRank()),
        cratio                  = cratio,
        ccritratio              = ccritratio,
        accStat                 = attacker:getRACC(),
        melee                   = false,
        mustMiss                = false,
        sneakApplicable         = false,
        trickApplicable         = false,
        assassinApplicable      = false,
        mightyStrikesApplicable = false,
        forcedFirstCrit         = false,
        extraOffhandHit         = false,
        flourishEffect          = false,
        bonusTP                 = wsParams.bonusTP or 0,
        bonusfTP                = gorgetBeltFTP or 0,
        bonusAcc                = (gorgetBeltAcc or 0) + attacker:getMod(xi.mod.WSACC),
        bonusWSmods             = wsParams.bonusWSmods or 0
    }
    calcParams.hitRate = getRangedHitRate(attacker, target, false, calcParams.bonusAcc)

    -- Send our params off to calculate our raw WS damage, hits landed, and shadows absorbed
    calcParams = xi.weaponskills.calculateRawWSDmg(attacker, target, wsID, tp, action, wsParams, calcParams)
    local finaldmg = calcParams.finalDmg

    -- Delete statuses that may have been spent by the WS
    attacker:delStatusEffectsByFlag(xi.effectFlag.DETECTABLE)

    -- Calculate reductions
    finaldmg = target:rangedDmgTaken(finaldmg)
    finaldmg = finaldmg * target:getMod(xi.mod.PIERCE_SDT) / 1000

    finaldmg            = finaldmg * xi.settings.main.WEAPON_SKILL_POWER -- Add server bonus
    calcParams.finalDmg = finaldmg

    finaldmg = xi.weaponskills.takeWeaponskillDamage(target, attacker, wsParams, primaryMsg, attack, calcParams, action)

    return finaldmg, calcParams.criticalHit, calcParams.tpHitsLanded, calcParams.extraHitsLanded, calcParams.shadowsAbsorbed
end

-- params: ftp100, ftp200, ftp300, wsc_str, wsc_dex, wsc_vit, wsc_agi, wsc_int, wsc_mnd, wsc_chr,
--         ele (xi.element.FIRE), skill (xi.skill.STAFF)

xi.weaponskills.doMagicWeaponskill = function(attacker, target, wsID, wsParams, tp, action, primaryMsg)
    -- Set up conditions and wsParams used for calculating weaponskill damage
    local attack =
    {
        ['type']       = xi.attackType.MAGICAL,
        ['slot']       = xi.slot.MAIN,
        ['weaponType'] = attacker:getWeaponSkillType(xi.slot.MAIN),
        ['damageType'] = xi.damageType.ELEMENTAL + wsParams.ele
    }

    local calcParams =
    {
        ['shadowsAbsorbed'] = 0,
        ['tpHitsLanded']    = 1,
        ['extraHitsLanded'] = 0,
        ['bonusTP']         = wsParams.bonusTP or 0,
        ['wsID']            = wsID
    }

    local bonusfTP, bonusacc = xi.weaponskills.handleWSGorgetBelt(attacker)
    bonusacc                 = bonusacc + attacker:getMod(xi.mod.WSACC)

    local fint = utils.clamp(8 + attacker:getStat(xi.mod.INT) - target:getStat(xi.mod.INT), -32, 32)
    local dmg  = 0
    local baseMagicDamageBonus = attacker:getMod(xi.mod.MAGIC_DAMAGE)

    -- Magic-based WSes never miss, so we don't need to worry about calculating a miss, only if a shadow absorbed it.
    if not shadowAbsorb(target) then

        -- Begin Checks for bonus wsc bonuses. See the following for details:
        -- https://www.bg-wiki.com/bg/Utu_Grip
        -- https://www.bluegartr.com/threads/108199-Random-Facts-Thread-Other?p=6826618&viewfull=1#post6826618

        for modId, parameterName in pairs(modParameters) do
            if attacker:getMod(modId) > 0 then
                wsParams[parameterName] = wsParams[parameterName] + attacker:getMod(modId) / 100
            end
        end

        dmg = attacker:getMainLvl() + 2  + baseMagicDamageBonus + fint +
            attacker:getStat(xi.mod.STR) * wsParams.str_wsc +
            attacker:getStat(xi.mod.DEX) * wsParams.dex_wsc +
            attacker:getStat(xi.mod.VIT) * wsParams.vit_wsc +
            attacker:getStat(xi.mod.AGI) * wsParams.agi_wsc +
            attacker:getStat(xi.mod.INT) * wsParams.int_wsc +
            attacker:getStat(xi.mod.MND) * wsParams.mnd_wsc +
            attacker:getStat(xi.mod.CHR) * wsParams.chr_wsc

        -- Applying fTP multiplier
        local ftp = xi.weaponskills.fTP(tp, wsParams.ftp100, wsParams.ftp200, wsParams.ftp300) + bonusfTP

        dmg = dmg * ftp

        -- Apply Consume Mana and Scarlet Delirium
        -- TODO: dmg = (dmg + consumeManaBonus(attacker)) * scarletDeliriumBonus(attacker)
        dmg = dmg * scarletDeliriumBonus(attacker)

        -- Factor in "all hits" bonus damage mods
        local bonusdmg = attacker:getMod(xi.mod.ALL_WSDMG_ALL_HITS) -- For any WS
        if
            attacker:getMod(xi.mod.WEAPONSKILL_DAMAGE_BASE + wsID) > 0 and
            not attacker:isPet()
        then
            -- For specific WS
            bonusdmg = bonusdmg + attacker:getMod(xi.mod.WEAPONSKILL_DAMAGE_BASE + wsID)
        end

        -- Add in bonusdmg
        dmg = dmg * (100 + bonusdmg) / 100 -- Apply our "all hits" WS dmg bonuses
        dmg = dmg + dmg * attacker:getMod(xi.mod.ALL_WSDMG_FIRST_HIT) / 100 -- Add in our "first hit" WS dmg bonus

        -- Calculate magical bonuses and reductions
        dmg = addBonusesAbility(attacker, wsParams.ele, target, dmg, wsParams)
        dmg = dmg * applyResistanceAbility(attacker, target, wsParams.ele, wsParams.skill, bonusacc)
        dmg = target:magicDmgTaken(dmg, wsParams.ele)

        if dmg < 0 then
            calcParams.finalDmg = dmg

            dmg = xi.weaponskills.takeWeaponskillDamage(target, attacker, wsParams, primaryMsg, attack, calcParams, action)
            return dmg
        end

        dmg = adjustForTarget(target, dmg, wsParams.ele)

        if dmg > 0 then
            dmg = dmg - target:getMod(xi.mod.PHALANX)
            dmg = utils.clamp(dmg, 0, 99999)
        end

        dmg = utils.oneforall(target, dmg)
        dmg = utils.stoneskin(target, dmg)

        dmg = dmg * xi.settings.main.WEAPON_SKILL_POWER -- Add server bonus
    else
        calcParams.shadowsAbsorbed = 1
    end

    calcParams.finalDmg = dmg

    if dmg > 0 then
        attacker:trySkillUp(attack.weaponType, target:getMainLvl())
    end

    dmg = xi.weaponskills.takeWeaponskillDamage(target, attacker, wsParams, primaryMsg, attack, calcParams, action)

    return dmg, calcParams.criticalHit, calcParams.tpHitsLanded, calcParams.extraHitsLanded, calcParams.shadowsAbsorbed
end

-- After WS damage is calculated and damage reduction has been taken into account by the calling function,
-- handles displaying the appropriate action/message, delivering the damage to the mob, and any enmity from it
xi.weaponskills.takeWeaponskillDamage = function(defender, attacker, wsParams, primaryMsg, attack, wsResults, action)
    local finaldmg = wsResults.finalDmg

    if wsResults.tpHitsLanded + wsResults.extraHitsLanded > 0 then
        if finaldmg >= 0 then
            if primaryMsg then
                action:messageID(defender:getID(), xi.msg.basic.DAMAGE)
            else
                action:messageID(defender:getID(), xi.msg.basic.DAMAGE_SECONDARY)
            end

            if finaldmg > 0 then
                action:reaction(defender:getID(), xi.reaction.HIT)
                action:speceffect(defender:getID(), xi.specEffect.RECOIL)
            end
        else
            if primaryMsg then
                action:messageID(defender:getID(), xi.msg.basic.SELF_HEAL)
            else
                action:messageID(defender:getID(), xi.msg.basic.SELF_HEAL_SECONDARY)
            end
        end

        action:param(defender:getID(), math.abs(finaldmg))
    elseif wsResults.shadowsAbsorbed > 0 then
        action:messageID(defender:getID(), xi.msg.basic.SHADOW_ABSORB)
        action:param(defender:getID(), wsResults.shadowsAbsorbed)
    else
        if primaryMsg then
            action:messageID(defender:getID(), xi.msg.basic.SKILL_MISS)
        else
            action:messageID(defender:getID(), xi.msg.basic.EVADES)
        end

        action:reaction(defender:getID(), xi.reaction.EVADE)
    end

    local targetTPMult   = wsParams.targetTPMult or 1
    local attackerTPMult = wsParams.attackerTPMult or 1
    local isJump         = wsParams.isJump or false

    -- DA/TA/QA/OaT/Oa2-3 etc give full TP return per hit on Jumps
    if isJump then
        -- Don't feed TP and don't gain TP from takeWeaponskillDamage
        attackerTPMult            = 0
        wsResults.extraHitsLanded = 0
    end

    finaldmg = defender:takeWeaponskillDamage(attacker, finaldmg, attack.type, attack.damageType, attack.slot, primaryMsg, wsResults.tpHitsLanded * attackerTPMult, (wsResults.extraHitsLanded * 10) + wsResults.bonusTP, targetTPMult)

    if wsResults.tpHitsLanded + wsResults.extraHitsLanded > 0 then
        if finaldmg >= 0 then
            action:param(defender:getID(), math.abs(finaldmg))
        end
    end

    local enmityEntity = wsResults.taChar or attacker

    if wsParams.overrideCE and wsParams.overrideVE then
        defender:addEnmity(enmityEntity, wsParams.overrideCE, wsParams.overrideVE)
    else
        local enmityMult = wsParams.enmityMult or 1
        defender:updateEnmityFromDamage(enmityEntity, finaldmg * enmityMult)
    end

    if finaldmg > 0 then
        -- Pack the weaponskill ID in the top 8 bits of this variable which is utilized
        -- in OnMobDeath in luautils.  Max WSID is 255.
        defender:setLocalVar('weaponskillHit', bit.lshift(wsResults.wsID, 24) + finaldmg)
    end

    return finaldmg
end

-- Helper function to get Main damage depending on weapon type
xi.weaponskills.getMeleeDmg = function(attacker, weaponType, kick)
    local mainhandDamage = attacker:getWeaponDmg()
    local offhandDamage  = attacker:getOffhandDmg()

    if weaponType == xi.skill.HAND_TO_HAND or weaponType == xi.skill.NONE then
        local h2hSkill = attacker:getSkillLevel(xi.skill.HAND_TO_HAND) * 0.11 + 3

        if kick and attacker:hasStatusEffect(xi.effect.FOOTWORK) then
            mainhandDamage = attacker:getMod(xi.mod.KICK_DMG) -- Use Kick damage if footwork is on
        end

        mainhandDamage = mainhandDamage + h2hSkill
        offhandDamage  = mainhandDamage
    end

    return { mainhandDamage, offhandDamage }
end

xi.weaponskills.getHitRate = function(attacker, target, capHitRate, bonus)
    local flourishEffect = attacker:getStatusEffect(xi.effect.BUILDING_FLOURISH)

    if flourishEffect ~= nil and flourishEffect:getPower() >= 1 then -- 1 or more Finishing moves used.
        attacker:addMod(xi.mod.ACC, 40 + flourishEffect:getSubPower() * 2)
    end

    local acc = attacker:getACC()
    local eva = target:getEVA()

    if flourishEffect ~= nil and flourishEffect:getPower() >= 1 then -- 1 or more Finishing moves used.
        attacker:delMod(xi.mod.ACC, 40 + flourishEffect:getSubPower() * 2)
    end

    if bonus == nil then
        bonus = 0
    end

    if
        attacker:hasStatusEffect(xi.effect.INNIN) and
        attacker:isBehind(target, 23)
    then
        -- Innin acc boost if attacker is behind target
        bonus = bonus + attacker:getStatusEffect(xi.effect.INNIN):getPower()
    end

    if
        target:hasStatusEffect(xi.effect.YONIN) and
        attacker:isFacing(target, 23)
    then
        -- Yonin evasion boost if attacker is facing target
        bonus = bonus - target:getStatusEffect(xi.effect.YONIN):getPower()
    end

    if attacker:hasTrait(76) and attacker:isBehind(target, 23) then --TRAIT_AMBUSH
        bonus = bonus + attacker:getMerit(xi.merit.AMBUSH)
    end

    acc = acc + bonus

    -- Accuracy Bonus
    if attacker:getMainLvl() > target:getMainLvl() then
        acc = acc + (attacker:getMainLvl() - target:getMainLvl()) * 4

    -- Accuracy Penalty
    elseif attacker:getMainLvl() < target:getMainLvl() then
        acc = acc - (target:getMainLvl() - attacker:getMainLvl()) * 4
    end

    local hitdiff = 0
    local hitrate = 75

    hitdiff = (acc - eva) / 2
    hitrate = hitrate + hitdiff
    hitrate = hitrate / 100

    -- Applying hitrate caps
    if capHitRate then -- this isn't capped for when acc varies with tp, as more penalties are due
        if hitrate > 1 then
            hitrate = 1
        end
    end

    if hitrate < 0.2 then
        hitrate = 0.2
    end

    return hitrate
end

xi.weaponskills.fTP = function(tp, ftp1, ftp2, ftp3)
    if tp >= 2000 then
        return ftp2 + (tp - 2000) * (ftp3 - ftp2) / 1000
    elseif tp >= 1000 then
        return ftp1 + (tp - 1000) * (ftp2 - ftp1) / 1000
    end

    return 1 -- no ftp mod
end

xi.weaponskills.calculatedIgnoredDef = function(tp, def, ignore1, ignore2, ignore3)
    if tp >= 2000 then
        return (ignore2 + (tp - 2000) * (ignore3 - ignore2) / 1000) * def
    elseif tp >= 1000 then
        return (ignore1 + (tp - 1000) * (ignore2 - ignore1) / 1000) * def
    end

    return 1 -- no def ignore mod
end

-- Given the raw ratio value (atk/def) and levels, returns the cRatio (min then max)
xi.weaponskills.cMeleeRatio = function(attacker, defender, params, ignoredDef, tp)
    local flourishEffect = attacker:getStatusEffect(xi.effect.BUILDING_FLOURISH)

    if flourishEffect ~= nil and flourishEffect:getPower() >= 2 then -- 2 or more Finishing Moves used.
        attacker:addMod(xi.mod.ATTP, 25 + flourishEffect:getSubPower())
    end

    local atkmulti = xi.weaponskills.fTP(tp, params.atk100, params.atk200, params.atk300)
    local cratio   = attacker:getStat(xi.mod.ATT) * atkmulti / (defender:getStat(xi.mod.DEF) - ignoredDef)

    cratio = utils.clamp(cratio, 0, 2.25)

    if flourishEffect ~= nil and flourishEffect:getPower() >= 2 then -- 2 or more Finishing Moves used.
        attacker:delMod(xi.mod.ATTP, 25 + flourishEffect:getSubPower())
    end

    local levelCorrection = 0

    if attacker:getMainLvl() < defender:getMainLvl() then
        levelCorrection = 0.05 * (defender:getMainLvl() - attacker:getMainLvl())
    end

    cratio = cratio - levelCorrection

    if cratio < 0 then
        cratio = 0
    end

    -- max
    local pdifmax = 3
    if cratio < 0.5 then
        pdifmax = cratio + 0.5
    elseif cratio < 0.7 then
        pdifmax = 1
    elseif cratio < 1.2 then
        pdifmax = cratio + 0.3
    elseif cratio < 1.5 then
        pdifmax = cratio * 0.25 + cratio
    elseif cratio < 2.625 then
        pdifmax = cratio + 0.375
    end

    -- min
    local pdifmin = cratio - 0.375
    if cratio < 0.38 then
        pdifmin = 0
    elseif cratio < 1.25 then
        pdifmin = cratio * 1176 / 1024 - 448 / 1024
    elseif cratio < 1.51 then
        pdifmin = 1
    elseif cratio < 2.44 then
        pdifmin = cratio * 1176 / 1024 - 775 / 1024
    end

    local pdif = {}
    pdif[1]    = pdifmin
    pdif[2]    = pdifmax

    local pdifcrit = {}
    cratio         = cratio + 1
    cratio         = utils.clamp(cratio, 0, 3)

    if cratio < 0.5 then
        pdifmax = cratio + 0.5
    elseif cratio < 0.7 then
        pdifmax = 1
    elseif cratio < 1.2 then
        pdifmax = cratio + 0.3
    elseif cratio < 1.5 then
        pdifmax = cratio * 0.25 + cratio
    elseif cratio < 2.625 then
        pdifmax = cratio + 0.375
    else
        pdifmax = 3
    end

    -- min
    if cratio < 0.38 then
        pdifmin = 0
    elseif cratio < 1.25 then
        pdifmin = cratio * 1176 / 1024 - 448 / 1024
    elseif cratio < 1.51 then
        pdifmin = 1
    elseif cratio < 2.44 then
        pdifmin = cratio * 1176 / 1024 - 775 / 1024
    else
        pdifmin = cratio - 0.375
    end

    local critbonus = attacker:getMod(xi.mod.CRIT_DMG_INCREASE) - defender:getMod(xi.mod.CRIT_DEF_BONUS)
    critbonus       = utils.clamp(critbonus, 0, 100)
    pdifcrit[1]     = pdifmin * (100 + critbonus) / 100
    pdifcrit[2]     = pdifmax * (100 + critbonus) / 100

    return pdif, pdifcrit
end

-- Given the attacker's str and the mob's vit, fSTR is calculated (for melee WS)
xi.weaponskills.fSTR = function(atkStr, defVit, weaponRank)
    local dSTR = atkStr - defVit
    local fSTR = calculateRawFstr(dSTR, 4)

    -- Apply fSTR caps.
    local lowerCap = weaponRank * -1
    if weaponRank == 0 then
        lowerCap = -1
    end

    fSTR = utils.clamp(fSTR, lowerCap, weaponRank + 8)

    return fSTR
end

xi.weaponskills.generatePdif = function(cratiomin, cratiomax, melee)
    local pdif = math.random(cratiomin * 1000, cratiomax * 1000) / 1000

    if melee then
        pdif = pdif * (math.random(100, 105) / 100)
    end

    return pdif
end

xi.weaponskills.handleWSGorgetBelt = function(attacker)
    local ftpBonus = 0
    local accBonus = 0

    if attacker:getObjType() == xi.objType.PC then
        local elementalGorget = -- Ordered by element correctly. TODO: mods/latents instead of items
        {
            xi.item.FLAME_GORGET,
            xi.item.SNOW_GORGET,
            xi.item.BREEZE_GORGET,
            xi.item.SOIL_GORGET,
            xi.item.THUNDER_GORGET,
            xi.item.AQUA_GORGET,
            xi.item.LIGHT_GORGET,
            xi.item.SHADOW_GORGET
        }

        local elementalBelt = -- Ordered by element correctly. TODO: mods/latents instead of items
        {
            xi.item.FLAME_BELT,
            xi.item.SNOW_BELT,
            xi.item.BREEZE_BELT,
            xi.item.SOIL_BELT,
            xi.item.THUNDER_BELT,
            xi.item.AQUA_BELT,
            xi.item.LIGHT_BELT,
            xi.item.SHADOW_BELT
        }

        local neck                      = attacker:getEquipID(xi.slot.NECK)
        local belt                      = attacker:getEquipID(xi.slot.WAIST)
        local scProp1, scProp2, scProp3 = attacker:getWSSkillchainProp()

        for i, v in ipairs(elementalGorget) do
            if neck == v then
                if
                    xi.magicburst.doesElementMatchWeaponskill(i, scProp1) or
                    xi.magicburst.doesElementMatchWeaponskill(i, scProp2) or
                    xi.magicburst.doesElementMatchWeaponskill(i, scProp3)
                then
                    accBonus = accBonus + 10
                    ftpBonus = ftpBonus + 0.1
                end

                break
            end
        end

        if neck == xi.item.FOTIA_GORGET then -- Fotia Gorget
            accBonus = accBonus + 10
            ftpBonus = ftpBonus + 0.1
        end

        for i, v in ipairs(elementalBelt) do
            if belt == v then
                if
                    xi.magicburst.doesElementMatchWeaponskill(i, scProp1) or
                    xi.magicburst.doesElementMatchWeaponskill(i, scProp2) or
                    xi.magicburst.doesElementMatchWeaponskill(i, scProp3)
                then
                    accBonus = accBonus + 10
                    ftpBonus = ftpBonus + 0.1
                end

                break
            end
        end

        if belt == xi.item.FOTIA_BELT then -- Fotia Belt
            accBonus = accBonus + 10
            ftpBonus = ftpBonus + 0.1
        end
    end

    return ftpBonus, accBonus
end
