local Hud = lib.class('Hud')

function Hud:constructor()
    self.system = 'ps-hud'
end

function Hud:updateHealth(health)
    TriggerEvent('ps-hud:update:health', health)
end

function Hud:updateArmor(armor)
    TriggerEvent('ps-hud:update:armor', armor)
end

function Hud:updateHunger(hunger)
    TriggerEvent('ps-hud:update:hunger', hunger)
end

function Hud:updateThirst(thirst)
    TriggerEvent('ps-hud:update:thirst', thirst)
end

function Hud:showHud(show)
    TriggerEvent('ps-hud:toggle', show)
end

return Hud
