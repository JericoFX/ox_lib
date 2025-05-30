---@meta

---@class WeaponOptions
---@field ammo? number Ammo count (default: 250)
---@field visible? boolean Whether weapon is visible (default: true)
---@field equipNow? boolean Whether to equip immediately (default: false)
---@field attachments? table List of attachments to add

---@class WeaponAttachment
---@field name string Attachment name from enums
---@field hash number Attachment hash

---@class lib.weapons
---@field private weaponCache table
---@field private attachmentCache table
local Weapons = lib.class('Weapons')

---Weapons API Class - Client Side
---Complete weapon system with attachments, custom weapons, and modifications
---@param options? table Weapons system options
function Weapons:constructor(options)
    options = options or {}

    -- Initialize private properties
    self.private.weaponCache = {}
    self.private.attachmentCache = {}

    -- Setup weapon tracking
    self:_setupWeaponTracking()
end

-- =====================================
-- CORE WEAPON FUNCTIONS
-- =====================================

---Give weapon to player
---@param ped? number Ped handle (default: PlayerPedId())
---@param weaponName string Weapon name from enums
---@param options? WeaponOptions Weapon options
---@return boolean success True if weapon was given successfully
function Weapons:giveWeapon(ped, weaponName, options)
    ped = ped or PlayerPedId()
    options = options or {}

    local weaponHash = GetHashKey(weaponName)
    local ammo = options.ammo or 250
    local visible = options.visible ~= false
    local equipNow = options.equipNow or false

    -- Give the weapon
    GiveWeaponToPed(ped, weaponHash, ammo, false, equipNow)

    -- Set visibility
    if not visible then
        SetPedWeaponTintIndex(ped, weaponHash, 0) -- This might need adjustment
    end

    -- Add attachments if specified
    if options.attachments then
        for _, attachment in ipairs(options.attachments) do
            self:addAttachment(ped, weaponName, attachment.name or attachment)
        end
    end

    -- Cache weapon info
    self.private.weaponCache[weaponName] = {
        hash = weaponHash,
        ammo = ammo,
        attachments = options.attachments or {},
        visible = visible,
        ped = ped
    }

    return HasPedGotWeapon(ped, weaponHash, false)
end

---Remove weapon from player
---@param ped? number Ped handle (default: PlayerPedId())
---@param weaponName string Weapon name from enums
---@return boolean success True if weapon was removed successfully
function Weapons:removeWeapon(ped, weaponName)
    ped = ped or PlayerPedId()

    local weaponHash = GetHashKey(weaponName)

    -- Remove the weapon
    RemoveWeaponFromPed(ped, weaponHash)

    -- Clear from cache
    self.private.weaponCache[weaponName] = nil

    return not HasPedGotWeapon(ped, weaponHash, false)
end

---Check if player has weapon
---@param ped? number Ped handle (default: PlayerPedId())
---@param weaponName string Weapon name from enums
---@return boolean hasWeapon True if ped has the weapon
function Weapons:hasWeapon(ped, weaponName)
    ped = ped or PlayerPedId()

    local weaponHash = GetHashKey(weaponName)
    return HasPedGotWeapon(ped, weaponHash, false)
end

---Get current weapon
---@param ped? number Ped handle (default: PlayerPedId())
---@return string? weaponName Current weapon name or nil
function Weapons:getCurrentWeapon(ped)
    ped = ped or PlayerPedId()

    local weaponHash = GetSelectedPedWeapon(ped)

    -- Find weapon name from hash
    for weaponName, data in pairs(lib.enums.weapons.WEAPONS) do
        if GetHashKey(weaponName) == weaponHash then
            return weaponName
        end
    end

    return nil
end

-- =====================================
-- WEAPON MODIFICATION FUNCTIONS
-- =====================================

---Set weapon ammo
---@param ped? number Ped handle (default: PlayerPedId())
---@param weaponName string Weapon name from enums
---@param ammo number Ammo count
function Weapons:setAmmo(ped, weaponName, ammo)
    ped = ped or PlayerPedId()

    local weaponHash = GetHashKey(weaponName)

    if HasPedGotWeapon(ped, weaponHash, false) then
        SetPedAmmo(ped, weaponHash, ammo)

        -- Update cache
        if self.private.weaponCache[weaponName] then
            self.private.weaponCache[weaponName].ammo = ammo
        end
    end
end

---Get weapon ammo
---@param ped? number Ped handle (default: PlayerPedId())
---@param weaponName string Weapon name from enums
---@return number ammo Current ammo count
function Weapons:getAmmo(ped, weaponName)
    ped = ped or PlayerPedId()

    local weaponHash = GetHashKey(weaponName)
    return GetAmmoInPedWeapon(ped, weaponHash)
end

---Add weapon attachment
---@param ped? number Ped handle (default: PlayerPedId())
---@param weaponName string Weapon name from enums
---@param attachmentName string Attachment name from enums
---@return boolean success True if attachment was added
function Weapons:addAttachment(ped, weaponName, attachmentName)
    ped = ped or PlayerPedId()

    local weaponHash = GetHashKey(weaponName)
    local attachmentHash = GetHashKey(attachmentName)

    if HasPedGotWeapon(ped, weaponHash, false) then
        GiveWeaponComponentToPed(ped, weaponHash, attachmentHash)

        -- Update cache
        if self.private.weaponCache[weaponName] then
            if not self.private.weaponCache[weaponName].attachments then
                self.private.weaponCache[weaponName].attachments = {}
            end
            table.insert(self.private.weaponCache[weaponName].attachments, attachmentName)
        end

        return HasPedGotWeaponComponent(ped, weaponHash, attachmentHash)
    end

    return false
end

---Remove weapon attachment
---@param ped? number Ped handle (default: PlayerPedId())
---@param weaponName string Weapon name from enums
---@param attachmentName string Attachment name from enums
---@return boolean success True if attachment was removed
function Weapons:removeAttachment(ped, weaponName, attachmentName)
    ped = ped or PlayerPedId()

    local weaponHash = GetHashKey(weaponName)
    local attachmentHash = GetHashKey(attachmentName)

    if HasPedGotWeapon(ped, weaponHash, false) then
        RemoveWeaponComponentFromPed(ped, weaponHash, attachmentHash)

        -- Update cache
        if self.private.weaponCache[weaponName] and self.private.weaponCache[weaponName].attachments then
            for i, attachment in ipairs(self.private.weaponCache[weaponName].attachments) do
                if attachment == attachmentName then
                    table.remove(self.private.weaponCache[weaponName].attachments, i)
                    break
                end
            end
        end

        return not HasPedGotWeaponComponent(ped, weaponHash, attachmentHash)
    end

    return false
end

---Set weapon tint
---@param ped? number Ped handle (default: PlayerPedId())
---@param weaponName string Weapon name from enums
---@param tintIndex number Tint index (0-7 typically)
function Weapons:setTint(ped, weaponName, tintIndex)
    ped = ped or PlayerPedId()

    local weaponHash = GetHashKey(weaponName)

    if HasPedGotWeapon(ped, weaponHash, false) then
        SetPedWeaponTintIndex(ped, weaponHash, tintIndex)
    end
end

---Get weapon tint
---@param ped? number Ped handle (default: PlayerPedId())
---@param weaponName string Weapon name from enums
---@return number tintIndex Current tint index
function Weapons:getTint(ped, weaponName)
    ped = ped or PlayerPedId()

    local weaponHash = GetHashKey(weaponName)
    return GetPedWeaponTintIndex(ped, weaponHash)
end

-- =====================================
-- UTILITY FUNCTIONS
-- =====================================

---Get all weapons on ped
---@param ped? number Ped handle (default: PlayerPedId())
---@return table weapons List of weapon names
function Weapons:getAllWeapons(ped)
    ped = ped or PlayerPedId()

    local weapons = {}

    for weaponName, data in pairs(lib.enums.weapons.WEAPONS) do
        local weaponHash = GetHashKey(weaponName)
        if HasPedGotWeapon(ped, weaponHash, false) then
            table.insert(weapons, weaponName)
        end
    end

    return weapons
end

---Get weapon attachments
---@param ped? number Ped handle (default: PlayerPedId())
---@param weaponName string Weapon name from enums
---@return table attachments List of attachment names
function Weapons:getAttachments(ped, weaponName)
    ped = ped or PlayerPedId()

    local weaponHash = GetHashKey(weaponName)
    local attachments = {}

    if HasPedGotWeapon(ped, weaponHash, false) then
        for attachmentName, data in pairs(lib.enums.weapons.ATTACHMENTS) do
            local attachmentHash = GetHashKey(attachmentName)
            if HasPedGotWeaponComponent(ped, weaponHash, attachmentHash) then
                table.insert(attachments, attachmentName)
            end
        end
    end

    return attachments
end

---Get weapon damage
---@param weaponName string Weapon name from enums
---@return number damage Weapon damage value
function Weapons:getWeaponDamage(weaponName)
    local weaponHash = GetHashKey(weaponName)
    return GetWeaponDamage(weaponHash, 0) -- 0 for base damage
end

---Check if weapon is valid
---@param weaponName string Weapon name to check
---@return boolean valid True if weapon is valid
function Weapons:isValidWeapon(weaponName)
    local weaponHash = GetHashKey(weaponName)
    return IsWeaponValid(weaponHash)
end

---Private method to setup weapon tracking
function Weapons:_setupWeaponTracking()
    -- Setup weapon change detection if needed
    CreateThread(function()
        local lastWeapon = nil

        while true do
            local currentWeapon = self:getCurrentWeapon()

            if currentWeapon ~= lastWeapon then
                -- Weapon changed, could trigger events here
                lastWeapon = currentWeapon
            end

            Wait(500)
        end
    end)
end

-- Create default instance
lib.weapons = Weapons:new()
