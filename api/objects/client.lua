---@meta

---@class ObjectOptions
---@field heading? number Object heading/rotation
---@field frozen? boolean Whether to freeze the object
---@field collision? boolean Whether object has collision (default: true)
---@field visible? boolean Whether object is visible (default: true)
---@field networked? boolean Whether object should be networked (default: false on client)
---@field dynamic? boolean Whether object is dynamic
---@field door? boolean Whether object is a door
---@field placeOnGround? boolean Whether to place object on ground automatically
---@field invincible? boolean Whether object cannot be damaged

---@class AttachmentOptions
---@field bone? number Bone index to attach to
---@field offset? vector3 Position offset
---@field rotation? vector3 Rotation offset
---@field softPinning? boolean Use soft pinning
---@field collision? boolean Maintain collision during attachment
---@field isPed? boolean Whether target is a ped
---@field vertex? number Vertex index for vertex attachment
---@field fixedRot? boolean Fixed rotation attachment

---@class ObjectInfo
---@field entity number Object entity handle
---@field model number Model hash
---@field coords vector3 Object coordinates
---@field heading number Object heading
---@field networked boolean Whether object is networked
---@field attached boolean Whether object is attached to something
---@field attachedTo number|nil Entity it's attached to

---@class lib.objects : OxClass
---@field private activeObjects table<number, ObjectInfo> Active objects managed by this instance
---@field private modelCache table<number, number> Cache of loaded models
---@field private attachments table<number, table> Attachment relationships
local Objects = lib.class('Objects')

---Objects API Class - Client Side
---Simplified object creation, management, and attachment system
---Handles model loading, cleanup, and network coordination automatically
function Objects:constructor()
    self.private.activeObjects = {}
    self.private.modelCache = {}
    self.private.attachments = {}

    self:_startCleanupThread()
end

-- =====================================
-- OBJECT CREATION
-- =====================================

---Create an object with automatic model loading and cleanup
---@param model string|number Model name or hash
---@param coords vector3 Spawn coordinates
---@param options? ObjectOptions Creation options
---@return number|nil object Object entity handle or nil if failed
function Objects:create(model, coords, options)
    options = options or {}

    -- Get model hash
    local modelHash = type(model) == 'string' and GetHashKey(model) or model

    -- Load model with timeout
    if not lib.requestModel(modelHash, 5000) then
        lib.logger:error('objects', 'Failed to load model: %s', model)
        return nil
    end

    -- Create object
    local object = CreateObject(
        modelHash,
        coords.x, coords.y, coords.z,
        options.networked or false,
        options.dynamic or false,
        options.door or false
    )

    if not DoesEntityExist(object) then
        lib.logger:error('objects', 'Failed to create object: %s', model)
        SetModelAsNoLongerNeeded(modelHash)
        return nil
    end

    -- Apply object properties
    if options.heading then
        SetEntityHeading(object, options.heading)
    end

    if options.frozen then
        FreezeEntityPosition(object, true)
    end

    if options.collision == false then
        SetEntityCollision(object, false, false)
    end

    if options.visible == false then
        SetEntityVisible(object, false, false)
    end

    if options.invincible then
        SetEntityInvincible(object, true)
    end

    if options.placeOnGround then
        PlaceObjectOnGroundProperly(object)
    end

    -- Store object info
    self.private.activeObjects[object] = {
        entity = object,
        model = modelHash,
        coords = GetEntityCoords(object),
        heading = GetEntityHeading(object),
        networked = options.networked or false,
        attached = false,
        attachedTo = nil
    }

    -- Cleanup model
    SetModelAsNoLongerNeeded(modelHash)

    lib.logger:debug('objects', 'Created object: %s (model: %s)', object, model)
    return object
end

---Create multiple objects efficiently
---@param objects table<number, {model: string|number, coords: vector3, options?: ObjectOptions}> Objects to create
---@return table<number, number|nil> objects Array of created object handles
function Objects:createMultiple(objects)
    local results = {}
    local modelsToLoad = {}

    -- Collect unique models
    for i, objData in ipairs(objects) do
        local modelHash = type(objData.model) == 'string' and GetHashKey(objData.model) or objData.model
        modelsToLoad[modelHash] = true
    end

    -- Load all models
    for modelHash, _ in pairs(modelsToLoad) do
        lib.requestModel(modelHash, 5000)
    end

    -- Create objects
    for i, objData in ipairs(objects) do
        results[i] = self:create(objData.model, objData.coords, objData.options)
    end

    -- Cleanup models
    for modelHash, _ in pairs(modelsToLoad) do
        SetModelAsNoLongerNeeded(modelHash)
    end

    return results
end

-- =====================================
-- OBJECT ATTACHMENT
-- =====================================

---Attach object to entity
---@param object number Object to attach
---@param target number Target entity (vehicle, ped, object)
---@param options? AttachmentOptions Attachment options
---@return boolean success Whether attachment was successful
function Objects:attach(object, target, options)
    if not DoesEntityExist(object) or not DoesEntityExist(target) then
        lib.logger:warn('objects', 'Cannot attach - invalid object or target: %s -> %s', object, target)
        return false
    end

    options = options or {}
    local bone = options.bone or -1
    local offset = options.offset or vector3(0, 0, 0)
    local rotation = options.rotation or vector3(0, 0, 0)

    -- Perform attachment
    AttachEntityToEntity(
        object, target, bone,
        offset.x, offset.y, offset.z,
        rotation.x, rotation.y, rotation.z,
        false, -- p9
        options.softPinning or false,
        options.collision or false,
        options.isPed or false,
        options.vertex or 2,
        options.fixedRot or true
    )

    -- Update object info
    local objectInfo = self.private.activeObjects[object]
    if objectInfo then
        objectInfo.attached = true
        objectInfo.attachedTo = target
    end

    -- Store attachment relationship
    self.private.attachments[object] = {
        target = target,
        options = options
    }

    lib.logger:debug('objects', 'Attached object %s to entity %s', object, target)
    return true
end

---Detach object from entity
---@param object number Object to detach
---@param resetPhysics? boolean Whether to reset physics (default: true)
---@return boolean success Whether detachment was successful
function Objects:detach(object, resetPhysics)
    if not DoesEntityExist(object) then return false end

    resetPhysics = resetPhysics ~= false

    DetachEntity(object, resetPhysics, resetPhysics)

    -- Update object info
    local objectInfo = self.private.activeObjects[object]
    if objectInfo then
        objectInfo.attached = false
        objectInfo.attachedTo = nil
    end

    -- Remove attachment relationship
    self.private.attachments[object] = nil

    lib.logger:debug('objects', 'Detached object: %s', object)
    return true
end

---Get attachment info for object
---@param object number Object entity
---@return table|nil attachment Attachment information or nil if not attached
function Objects:getAttachment(object)
    return self.private.attachments[object]
end

-- =====================================
-- OBJECT MANIPULATION
-- =====================================

---Move object to new position
---@param object number Object entity
---@param coords vector3 New coordinates
---@param heading? number New heading
---@return boolean success Whether move was successful
function Objects:moveTo(object, coords, heading)
    if not DoesEntityExist(object) then return false end

    SetEntityCoords(object, coords.x, coords.y, coords.z, false, false, false, true)

    if heading then
        SetEntityHeading(object, heading)
    end

    -- Update stored info
    local objectInfo = self.private.activeObjects[object]
    if objectInfo then
        objectInfo.coords = coords
        if heading then
            objectInfo.heading = heading
        end
    end

    return true
end

---Set object visibility
---@param object number Object entity
---@param visible boolean Whether object should be visible
---@return boolean success Whether visibility was set
function Objects:setVisible(object, visible)
    if not DoesEntityExist(object) then return false end

    SetEntityVisible(object, visible, false)
    return true
end

---Set object collision
---@param object number Object entity
---@param collision boolean Whether object should have collision
---@return boolean success Whether collision was set
function Objects:setCollision(object, collision)
    if not DoesEntityExist(object) then return false end

    SetEntityCollision(object, collision, collision)
    return true
end

---Freeze/unfreeze object
---@param object number Object entity
---@param frozen boolean Whether object should be frozen
---@return boolean success Whether freeze state was set
function Objects:setFrozen(object, frozen)
    if not DoesEntityExist(object) then return false end

    FreezeEntityPosition(object, frozen)
    return true
end

-- =====================================
-- OBJECT INFORMATION
-- =====================================

---Get object information
---@param object number Object entity
---@return ObjectInfo|nil info Object information or nil if not found
function Objects:getInfo(object)
    return self.private.activeObjects[object]
end

---Get all managed objects
---@return table<number, ObjectInfo> objects All active objects
function Objects:getAllObjects()
    return self.private.activeObjects
end

---Check if object is managed by this instance
---@param object number Object entity
---@return boolean managed Whether object is managed
function Objects:isManaged(object)
    return self.private.activeObjects[object] ~= nil
end

---Get object model
---@param object number Object entity
---@return number|nil model Model hash or nil if object doesn't exist
function Objects:getModel(object)
    if not DoesEntityExist(object) then return nil end
    return GetEntityModel(object)
end

-- =====================================
-- OBJECT CLEANUP
-- =====================================

---Delete object and cleanup
---@param object number Object entity
---@return boolean success Whether object was deleted
function Objects:delete(object)
    if not DoesEntityExist(object) then return false end

    -- Detach if attached
    if self.private.attachments[object] then
        self:detach(object)
    end

    -- Remove from tracking
    self.private.activeObjects[object] = nil
    self.private.attachments[object] = nil

    -- Delete entity
    DeleteObject(object)

    lib.logger:debug('objects', 'Deleted object: %s', object)
    return true
end

---Delete all managed objects
---@return number deleted Number of objects deleted
function Objects:deleteAll()
    local count = 0

    for object, _ in pairs(self.private.activeObjects) do
        if self:delete(object) then
            count = count + 1
        end
    end

    lib.logger:info('objects', 'Deleted %s objects', count)
    return count
end

-- =====================================
-- PRIVATE FUNCTIONS
-- =====================================

---Clean up deleted objects from tracking
---@private
function Objects:_cleanupDeleted()
    for object, _ in pairs(self.private.activeObjects) do
        if not DoesEntityExist(object) then
            self.private.activeObjects[object] = nil
            self.private.attachments[object] = nil
        end
    end
end

---Start cleanup thread
---@private
function Objects:_startCleanupThread()
    CreateThread(function()
        while true do
            Wait(30000)
            self:_cleanupDeleted()
        end
    end)
end

-- Global instance
lib.objects = Objects:new()
