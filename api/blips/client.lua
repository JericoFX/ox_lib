---@meta

---@class BlipCreateOptions
---@field sprite? number Blip sprite ID (default: 1)
---@field color? number Blip color ID (default: 0)
---@field scale? number Blip scale (default: 1.0)
---@field shortRange? boolean Whether blip only shows when close (default: false)
---@field label? string Blip text label
---@field category? number Blip category (default: 0)
---@field alpha? number Blip transparency (0-255, default: 255)
---@field route? boolean Whether to show route to blip (default: false)
---@field routeColor? number Route color (default: 0)

---@class BlipUpdateData
---@field sprite? number New sprite ID
---@field color? number New color ID
---@field scale? number New scale
---@field label? string New label
---@field alpha? number New transparency
---@field coords? vector3 New coordinates
---@field route? boolean Route visibility
---@field routeColor? number Route color

---@class lib.blips
---@field blip number? The blip handle this instance controls
lib.blips = lib.class("blips")

---Blip API Class - Client Only
---@param blip? number If passed, it's for that specific blip
---@return lib.blips
function lib.blips:constructor(blip)
    if blip and DoesBlipExist(blip) then
        self.blip = blip
    else
        self.blip = nil
    end
end

---Check if the blip instance is valid
---@return boolean valid True if blip exists and is valid
function lib.blips:isValid()
    return self.blip and self.blip ~= 0 and DoesBlipExist(self.blip)
end

---Get the blip handle
---@return number? blip The blip handle or nil if invalid
function lib.blips:getHandle()
    if self:isValid() then
        return self.blip
    end
    return nil
end

---Set a new blip handle for this instance
---@param blip number The new blip handle
---@return boolean success True if the blip was set successfully
function lib.blips:setBlip(blip)
    if blip and DoesBlipExist(blip) then
        self.blip = blip
        return true
    end
    return false
end

---Static function to create an instance from any blip handle
---@param blip number Blip handle
---@return lib.blips? instance Blip instance or nil if invalid
function lib.blips.fromHandle(blip)
    if blip and DoesBlipExist(blip) then
        return lib.blips:new(blip)
    end
    return nil
end

---Static function to create a blip at coordinates
---@param coords vector3|table Blip coordinates
---@param options? table Blip creation options
---@return lib.blips? instance Blip instance or nil if failed
function lib.blips.createAtCoords(coords, options)
    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
        return nil
    end

    local blipCoords = coords
    if type(coords) == 'table' then
        blipCoords = vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    end

    local blip = AddBlipForCoord(blipCoords.x, blipCoords.y, blipCoords.z)
    if not blip or blip == 0 then
        return nil
    end

    local instance = lib.blips:new(blip)

    if options then
        instance:applyOptions(options)
    end

    return instance
end

---Static function to create a blip for an entity
---@param entity number Entity handle
---@param options? table Blip creation options
---@return lib.blips? instance Blip instance or nil if failed
function lib.blips.createForEntity(entity, options)
    if not entity or not DoesEntityExist(entity) then
        return nil
    end

    local blip = AddBlipForEntity(entity)
    if not blip or blip == 0 then
        return nil
    end

    local instance = lib.blips:new(blip)

    if options then
        instance:applyOptions(options)
    end

    return instance
end

---Static function to create a blip for a pickup
---@param pickup number Pickup handle
---@param options? BlipCreateOptions Blip creation options
---@return lib.blips? instance Blip instance or nil if failed
function lib.blips.createForPickup(pickup, options)
    if not pickup then
        return nil
    end

    local blip = AddBlipForPickup(pickup)
    if not blip or blip == 0 then
        return nil
    end

    local instance = lib.blips:new(blip)

    if options then
        instance:applyOptions(options)
    end

    return instance
end

---Static function to create a radius blip
---@param coords vector3|table Center coordinates
---@param radius number Radius size
---@param options? table Blip creation options
---@return lib.blips? instance Blip instance or nil if failed
function lib.blips.createRadius(coords, radius, options)
    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
        return nil
    end

    if type(radius) ~= 'number' or radius <= 0 then
        return nil
    end

    local blipCoords = coords
    if type(coords) == 'table' then
        blipCoords = vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    end

    local blip = AddBlipForRadius(blipCoords.x, blipCoords.y, blipCoords.z, radius)
    if not blip or blip == 0 then
        return nil
    end

    local instance = lib.blips:new(blip)

    if options then
        instance:applyOptions(options)
    end

    return instance
end

---Static function to create a blip for an area
---@param coords vector3|table Center coordinates
---@param width number Area width
---@param height number Area height
---@param options? BlipCreateOptions Blip creation options
---@return lib.blips? instance Blip instance or nil if failed
function lib.blips.createArea(coords, width, height, options)
    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
        return nil
    end

    if type(width) ~= 'number' or width <= 0 or type(height) ~= 'number' or height <= 0 then
        return nil
    end

    local blipCoords = coords
    if type(coords) == 'table' then
        blipCoords = vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    end

    local blip = AddBlipForArea(blipCoords.x, blipCoords.y, blipCoords.z, width, height)
    if not blip or blip == 0 then
        return nil
    end

    local instance = lib.blips:new(blip)

    if options then
        instance:applyOptions(options)
    end

    return instance
end

---Apply options to the blip
---@param options table Options to apply
---@return boolean success
function lib.blips:applyOptions(options)
    if not self:isValid() or not options then
        return false
    end

    if options.sprite then
        SetBlipSprite(self.blip, options.sprite)
    end

    if options.color then
        SetBlipColour(self.blip, options.color)
    end

    if options.scale then
        SetBlipScale(self.blip, options.scale)
    end

    if options.label then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(options.label)
        EndTextCommandSetBlipName(self.blip)
    end

    if options.shortRange ~= nil then
        SetBlipAsShortRange(self.blip, options.shortRange)
    end

    if options.category then
        SetBlipCategory(self.blip, options.category)
    end

    if options.alpha then
        SetBlipAlpha(self.blip, options.alpha)
    end

    if options.route ~= nil then
        SetBlipRoute(self.blip, options.route)
    end

    if options.routeColor then
        SetBlipRouteColour(self.blip, options.routeColor)
    end

    return true
end

---Set blip sprite
---@param sprite number Sprite ID
---@return boolean success
function lib.blips:setSprite(sprite)
    if not self:isValid() or type(sprite) ~= 'number' then
        return false
    end

    SetBlipSprite(self.blip, sprite)
    return true
end

---Set blip color
---@param color number Color ID
---@return boolean success
function lib.blips:setColor(color)
    if not self:isValid() or type(color) ~= 'number' then
        return false
    end

    SetBlipColour(self.blip, color)
    return true
end

---Set blip scale
---@param scale number Scale value (default: 1.0)
---@return boolean success True if scale was set successfully
function lib.blips:setScale(scale)
    if not self:isValid() or type(scale) ~= 'number' then
        return false
    end

    SetBlipScale(self.blip, scale)
    return true
end

---Set blip label
---@param label string Label text
---@return boolean success
function lib.blips:setLabel(label)
    if not self:isValid() or type(label) ~= 'string' then
        return false
    end

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(self.blip)
    return true
end

---Set blip transparency
---@param alpha number Alpha value (0-255)
---@return boolean success True if alpha was set successfully
function lib.blips:setAlpha(alpha)
    if not self:isValid() or type(alpha) ~= 'number' then
        return false
    end

    SetBlipAlpha(self.blip, alpha)
    return true
end

---Set blip category
---@param category number Category ID
---@return boolean success True if category was set successfully
function lib.blips:setCategory(category)
    if not self:isValid() or type(category) ~= 'number' then
        return false
    end

    SetBlipCategory(self.blip, category)
    return true
end

---Set blip as short range
---@param shortRange boolean Whether blip should be short range
---@return boolean success True if short range was set successfully
function lib.blips:setShortRange(shortRange)
    if not self:isValid() then
        return false
    end

    SetBlipAsShortRange(self.blip, shortRange)
    return true
end

---Set blip route
---@param enabled boolean Whether to show route
---@param color? number Route color (optional)
---@return boolean success
function lib.blips:setRoute(enabled, color)
    if not self:isValid() then
        return false
    end

    SetBlipRoute(self.blip, enabled)

    if color then
        SetBlipRouteColour(self.blip, color)
    end

    return true
end

---Set blip as mission creator
---@param enabled boolean Whether blip is mission creator
---@return boolean success True if mission creator was set successfully
function lib.blips:setAsMissionCreator(enabled)
    if not self:isValid() then
        return false
    end

    SetBlipAsMissionCreatorBlip(self.blip, enabled)
    return true
end

---Set blip priority
---@param priority number Priority level
---@return boolean success True if priority was set successfully
function lib.blips:setPriority(priority)
    if not self:isValid() or type(priority) ~= 'number' then
        return false
    end

    SetBlipPriority(self.blip, priority)
    return true
end

---Get blip coordinates
---@return vector3? coords Blip coordinates or nil if invalid
function lib.blips:getCoords()
    if not self:isValid() then
        return nil
    end

    return GetBlipInfoIdCoord(self.blip)
end

---Get blip sprite
---@return number? sprite Blip sprite ID or nil if invalid
function lib.blips:getSprite()
    if not self:isValid() then
        return nil
    end

    return GetBlipSprite(self.blip)
end

---Get blip color
---@return number? color Blip color ID or nil if invalid
function lib.blips:getColor()
    if not self:isValid() then
        return nil
    end

    return GetBlipColour(self.blip)
end

---Get blip alpha
---@return number? alpha Blip alpha value or nil if invalid
function lib.blips:getAlpha()
    if not self:isValid() then
        return nil
    end

    return GetBlipAlpha(self.blip)
end

---Check if blip is on minimap
---@return boolean? onMinimap True if on minimap, nil if invalid
function lib.blips:isOnMinimap()
    if not self:isValid() then
        return nil
    end

    return IsBlipOnMinimap(self.blip)
end

---Check if blip is short range
---@return boolean? shortRange True if short range, nil if invalid
function lib.blips:isShortRange()
    if not self:isValid() then
        return nil
    end

    return IsBlipShortRange(self.blip)
end

---Update blip with multiple properties
---@param data BlipUpdateData Properties to update
---@return boolean success True if blip was updated successfully
function lib.blips:update(data)
    if not self:isValid() or not data then
        return false
    end

    if data.sprite then self:setSprite(data.sprite) end
    if data.color then self:setColor(data.color) end
    if data.scale then self:setScale(data.scale) end
    if data.label then self:setLabel(data.label) end
    if data.alpha then self:setAlpha(data.alpha) end
    if data.route ~= nil then self:setRoute(data.route, data.routeColor) end

    if data.coords then
        if not self:setCoords(data.coords) then
            return false
        end
    end

    return true
end

---Set blip coordinates
---@param coords vector3|table New coordinates
---@return boolean success
function lib.blips:setCoords(coords)
    if not self:isValid() then
        return false
    end

    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
        return false
    end

    local blipCoords = coords
    if type(coords) == 'table' then
        blipCoords = vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    end

    SetBlipCoords(self.blip, blipCoords.x, blipCoords.y, blipCoords.z)
    return true
end

---Show blip height on legend
---@param enabled boolean Whether to show height
---@return boolean success True if height display was set successfully
function lib.blips:showHeightOnLegend(enabled)
    if not self:isValid() then
        return false
    end

    SetBlipShowCone(self.blip, enabled)
    return true
end

---Pulse the blip
---@return boolean success
function lib.blips:pulse()
    if not self:isValid() then
        return false
    end

    PulseBlip(self.blip)
    return true
end

---Remove/delete the blip
---@return boolean success
function lib.blips:remove()
    if not self:isValid() then
        return false
    end

    RemoveBlip(self.blip)
    self.blip = nil
    return true
end

---Static function to get all blips of a specific sprite
---@param sprite number Sprite ID to search for
---@return lib.blips[] blips Array of blip instances
function lib.blips.getAllOfSprite(sprite)
    local blips = {}
    local blip = GetFirstBlipInfoId(sprite)

    while DoesBlipExist(blip) do
        local instance = lib.blips:new(blip)
        if instance then
            blips[#blips + 1] = instance
        end
        blip = GetNextBlipInfoId(sprite)
    end

    return blips
end

---Static function to get closest blip of specific sprite to coordinates
---@param sprite number Sprite ID to search for
---@param coords vector3|table Reference coordinates
---@return lib.blips? instance Closest blip instance or nil if none found
---@return number? distance Distance to closest blip
function lib.blips.getClosestOfSprite(sprite, coords)
    local allBlips = lib.blips.getAllOfSprite(sprite)
    if #allBlips == 0 then
        return nil, nil
    end

    local refCoords = coords
    if type(coords) == 'table' then
        refCoords = vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    end

    local closest = nil
    local closestDistance = math.huge

    for i = 1, #allBlips do
        local blipCoords = allBlips[i]:getCoords()
        if blipCoords then
            local distance = #(refCoords - blipCoords)
            if distance < closestDistance then
                closestDistance = distance
                closest = allBlips[i]
            end
        end
    end

    return closest, closestDistance
end

return lib.blips
