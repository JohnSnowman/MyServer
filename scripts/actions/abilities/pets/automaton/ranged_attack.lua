-----------------------------------
-- Ranged Attack
-----------------------------------
local abilityObject = {}

abilityObject.onAutomatonAbilityCheck = function(target, automaton, skill)
    return 0
end

abilityObject.onAutomatonAbility = function(target, automaton, skill, master, action)
    local shotcount = 1
    local doubleshotrate = player:getPet():getMod(xi.mod.DOUBLE_SHOT_RATE)
    local tripleshotrate = player:getPet():getMod(xi.mod.TRIPLE_SHOT_RATE)
    if doubleshotrate > 0 then
        if doubleshotrate >= math.random() * 100 then
            --shotcount = 1 + 1
            shotcount + 1
        end
    end
    if tripleshotrate > 0 then
        if tripleshotrate >= math.random() * 100 then
            --shotcount = 1 + 2
            shotcount + 2
        end
    end
    local params =
    {
        numHits = shotcount,
        --numHits = 1,
        atkmulti = 1.5,
        ftp100 = 1.0,
        ftp200 = 1.0,
        ftp300 = 1.0,
        acc100 = 0.0,
        acc200 = 0.0,
        acc300 = 0.0,
        str_wsc = 0.5,
        dex_wsc = 0.25,
        vit_wsc = 0.0,
        agi_wsc = 0.0,
        int_wsc = 0.0,
        mnd_wsc = 0.0,
        chr_wsc = 0.0
    }

    local damage = xi.autows.doAutoRangedWeaponskill(automaton, target, 0, params, 1000, true, skill, action)

    return damage
end

return abilityObject
