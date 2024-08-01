-----------------------------------
-- PET: Automaton
-----------------------------------
xi = xi or {}
xi.pets = xi.pets or {}
xi.pets.automaton = {}

xi.pets.automaton.onMobSpawn = function(mob)
    mob:setLocalVar('MANEUVER_DURATION', 3000)
    mob:addListener('EFFECTS_TICK', 'MANEUVER_DURATION', function(automaton)
        if automaton:getTarget() then
            local dur = automaton:getLocalVar('MANEUVER_DURATION')
            automaton:setLocalVar('MANEUVER_DURATION', math.min(dur + 3, 3600))
        end
    end)
end

xi.pets.automaton.onMobDeath = function(mob)
    mob:removeListener('MANEUVER_DURATION')
end
