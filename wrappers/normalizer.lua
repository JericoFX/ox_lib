-- normalizer.lua - centralised framework-agnostic core

--- Internal helpers ----------------------------------------------------------

local function _dig(src, path)
    for key in string.gmatch(path, '[^%.]+') do
        src = src and src[key]
    end
    return src
end

local function _pick(data, selector)
    if not selector then return nil end
    local t = type(selector)
    if t == 'function' then
        return selector(data)
    elseif t == 'string' then
        return _dig(data, selector)
    end
    return selector
end

--- Cache object --------------------------------------------------------------

---@class Normalizer_Cache
local Cache = {}
local _store = {}

---@generic T
---@param key string
---@param fetch fun():T
---@return T
function Cache:get(key, fetch)
    local value = _store[key]
    if value ~= nil then
        _store[key] = nil -- invalidate immediately after the first read
        return value
    end
    return fetch()
end

---@param key string
---@param value any
function Cache:set(key, value)
    _store[key] = value
end

--- Stub generator ------------------------------------------------------------

local function _stub(area, fn)
    return function()
        error(('Normalizer.%s.%s not implemented'):format(area, fn), 2)
    end
end

--- Interface definitions ----------------------------------------------------

---@class Normalizer_Inventory
---@field getItem fun(source:number, item:string, metadata?:table, strict?:boolean):table|nil
---@field addItem fun(source:number, item:string, count:number, metadata?:table):boolean
---@field removeItem fun(source:number, item:string, count:number, metadata?:table, slot?:number):boolean

---@class Normalizer_Dispatch
---@field sendAlert fun(data:table)
---@field sendPoliceAlert fun(data:table)
---@field sendEMSAlert fun(data:table)
---@field sendFireAlert fun(data:table)
---@field sendMechanicAlert fun(data:table)
---@field sendCustomAlert fun(data:table)

---@class Normalizer_Fuel
---@field getFuel fun(vehicle:any):number
---@field setFuel fun(vehicle:any, fuel:number):boolean
---@field addFuel fun(vehicle:any, amount:number):boolean

---@class Normalizer_Voice
---@field setPlayerRadio fun(frequency:number)
---@field setPlayerPhone fun(callId:number)
---@field setProximityRange fun(range:number)
---@field mutePlayer fun(player:number, muted:boolean)

---@class Normalizer_Banking
---@field addMoney fun(source:number, amount:number, account?:string):boolean
---@field removeMoney fun(source:number, amount:number, account?:string):boolean
---@field getMoney fun(source:number, account?:string):number
---@field transferMoney fun(fromSource:number, toSource:number, amount:number, fromAccount?:string, toAccount?:string):boolean
---@field createAccount fun(source:number, accountName:string, accountType?:string):boolean
---@field addTransaction fun(source:number, account:string, amount:number, reason:string, type?:string):boolean

---@class Normalizer_Targeting
---@field addEntity fun(entity:any, options:table):boolean
---@field removeEntity fun(entity:any):boolean
---@field addZone fun(name:string, coords:vector3, options:table):boolean
---@field removeZone fun(name:string):boolean

---@class Normalizer_Housing
---@field enterHouse fun(source:number, houseId:string|number):boolean
---@field exitHouse fun(source:number):boolean
---@field createHouse fun(coords:vector3, price:number, owner:string, houseType?:string):boolean|number
---@field buyHouse fun(source:number, houseId:string|number):boolean
---@field getPlayerHouses fun(source:number):table[]
---@field isPlayerInsideHouse fun(source:number):boolean
---@field getHouseInfo fun(houseId:string|number):table|nil

---@class Normalizer_Phone
---@field sendMessage fun(number:string|number, message:string):boolean
---@field addContact fun(name:string, number:string|number, avatar?:string):boolean
---@field removeContact fun(number:string|number):boolean
---@field notification fun(title:string, text:string, icon?:string, color?:string, timeout?:number):boolean
---@field open fun():boolean
---@field close fun():boolean
---@field isOpen fun():boolean
---@field makeCall fun(number:string|number):boolean
---@field answerCall fun():boolean
---@field declineCall fun():boolean
---@field endCall fun():boolean
---@field isInCall fun():boolean
---@field takePhoto fun():boolean
---@field openGallery fun():boolean
---@field openApp fun(appName:string):boolean
---@field closeApp fun(appName:string):boolean
---@field getPhoneNumber fun():string?
---@field getContacts fun():table?
---@field updateContact fun(id:any, data:table):boolean
---@field deletePhoto fun(photoId:any):boolean
---@field sharePhoto fun(photoId:any, contacts:table):boolean
---@field installApp fun(appId:string):boolean
---@field uninstallApp fun(appId:string):boolean
---@field getInstalledApps fun():table

---@class Normalizer_Shops
---@field createShop fun(shopData:table):boolean
---@field openShop fun(shopName:string, playerSource?:number):boolean
---@field addShopItem fun(shopName:string, itemData:table):boolean
---@field removeShopItem fun(shopName:string, itemName:string, amount?:number):boolean
---@field updateShopItem fun(shopName:string, itemName:string, updateData:table):boolean
---@field getShop fun(shopName:string):table?
---@field deleteShop fun(shopName:string):boolean
---@field getAllShops fun():table
---@field buyItem fun(shopName:string, itemName:string, amount?:number):boolean
---@field shopExists fun(shopName:string):boolean
---@field createQuickShop fun(name:string, label:string, coords:vector3, items?:table):boolean
---@field getShopItems fun(shopName:string):table
---@field clearShop fun(shopName:string):boolean
---@field populateShop fun(shopName:string, items:table):boolean

---@class Normalizer_Garage
---@field openMenu fun(data:table):boolean
---@field getVehicles fun(callback:function, index?:string, gtype?:string, category?:string):boolean
---@field spawnVehicle fun(plate:string, coords:vector3, heading:number, callback?:function):boolean
---@field storeVehicle fun(plate:string, fuel?:number, engine?:number, body?:number):boolean

---@class Normalizer_Clothing
---@field openClothing fun():boolean
---@field openOutfits fun():boolean
---@field saveOutfit fun(name:string, outfit?:table):boolean
---@field loadOutfit fun(name:string):boolean
---@field getPlayerClothing fun():table
---@field setPlayerClothing fun(clothing:table):boolean
---@field openShop fun(shopType:string):boolean
---@field openPedMenu fun():boolean

--- Core object ---------------------------------------------------------------

---@class Normalizer
---@field cache Normalizer_Cache
---@field capabilities table<string, boolean>
---@field inventory Normalizer_Inventory
---@field dispatch Normalizer_Dispatch
---@field fuel Normalizer_Fuel
---@field voice Normalizer_Voice
---@field banking Normalizer_Banking
---@field targeting Normalizer_Targeting
---@field housing Normalizer_Housing
---@field phone Normalizer_Phone
---@field shops Normalizer_Shops
---@field garage Normalizer_Garage
---@field clothing Normalizer_Clothing
local M = {
    cache        = Cache,
    capabilities = {
        inventory = false,
        dispatch  = false,
        fuel      = false,
        garage    = false,
        housing   = false,
        phone     = false,
        shops     = false,
        targeting = false,
        voice     = false,
        banking   = false,
        clothing  = false,
    },
    inventory    = {
        getItem    = _stub('inventory', 'getItem'),
        addItem    = _stub('inventory', 'addItem'),
        removeItem = _stub('inventory', 'removeItem'),
    },
    dispatch     = {
        sendAlert         = _stub('dispatch', 'sendAlert'),
        sendPoliceAlert   = _stub('dispatch', 'sendPoliceAlert'),
        sendEMSAlert      = _stub('dispatch', 'sendEMSAlert'),
        sendFireAlert     = _stub('dispatch', 'sendFireAlert'),
        sendMechanicAlert = _stub('dispatch', 'sendMechanicAlert'),
        sendCustomAlert   = _stub('dispatch', 'sendCustomAlert'),
    },
    fuel         = {
        getFuel = _stub('fuel', 'getFuel'),
        setFuel = _stub('fuel', 'setFuel'),
        addFuel = _stub('fuel', 'addFuel'),
    },
    voice        = {
        setPlayerRadio    = _stub('voice', 'setPlayerRadio'),
        setPlayerPhone    = _stub('voice', 'setPlayerPhone'),
        setProximityRange = _stub('voice', 'setProximityRange'),
        mutePlayer        = _stub('voice', 'mutePlayer'),
    },
    banking      = {
        addMoney       = _stub('banking', 'addMoney'),
        removeMoney    = _stub('banking', 'removeMoney'),
        getMoney       = _stub('banking', 'getMoney'),
        transferMoney  = _stub('banking', 'transferMoney'),
        createAccount  = _stub('banking', 'createAccount'),
        addTransaction = _stub('banking', 'addTransaction'),
    },
    targeting    = {
        addEntity    = _stub('targeting', 'addEntity'),
        removeEntity = _stub('targeting', 'removeEntity'),
        addZone      = _stub('targeting', 'addZone'),
        removeZone   = _stub('targeting', 'removeZone'),
    },
    garage       = {
        openMenu     = _stub('garage', 'openMenu'),
        getVehicles  = _stub('garage', 'getVehicles'),
        spawnVehicle = _stub('garage', 'spawnVehicle'),
        storeVehicle = _stub('garage', 'storeVehicle'),
    },
    housing      = {
        enterHouse           = _stub('housing', 'enterHouse'),
        exitHouse            = _stub('housing', 'exitHouse'),
        createHouse          = _stub('housing', 'createHouse'),
        buyHouse             = _stub('housing', 'buyHouse'),
        getPlayerHouses      = _stub('housing', 'getPlayerHouses'),
        isPlayerInsideHouse  = _stub('housing', 'isPlayerInsideHouse'),
        getHouseInfo         = _stub('housing', 'getHouseInfo'),
    },
    phone        = {
        sendMessage      = _stub('phone', 'sendMessage'),
        addContact       = _stub('phone', 'addContact'),
        removeContact    = _stub('phone', 'removeContact'),
        notification     = _stub('phone', 'notification'),
        open             = _stub('phone', 'open'),
        close            = _stub('phone', 'close'),
        isOpen           = _stub('phone', 'isOpen'),
        makeCall         = _stub('phone', 'makeCall'),
        answerCall       = _stub('phone', 'answerCall'),
        declineCall      = _stub('phone', 'declineCall'),
        endCall          = _stub('phone', 'endCall'),
        isInCall         = _stub('phone', 'isInCall'),
        takePhoto        = _stub('phone', 'takePhoto'),
        openGallery      = _stub('phone', 'openGallery'),
        openApp          = _stub('phone', 'openApp'),
        closeApp         = _stub('phone', 'closeApp'),
        getPhoneNumber   = _stub('phone', 'getPhoneNumber'),
        getContacts      = _stub('phone', 'getContacts'),
        updateContact    = _stub('phone', 'updateContact'),
        deletePhoto      = _stub('phone', 'deletePhoto'),
        sharePhoto       = _stub('phone', 'sharePhoto'),
        installApp       = _stub('phone', 'installApp'),
        uninstallApp     = _stub('phone', 'uninstallApp'),
        getInstalledApps = _stub('phone', 'getInstalledApps'),
    },
    shops        = {
        createShop      = _stub('shops', 'createShop'),
        openShop        = _stub('shops', 'openShop'),
        addShopItem     = _stub('shops', 'addShopItem'),
        removeShopItem  = _stub('shops', 'removeShopItem'),
        updateShopItem  = _stub('shops', 'updateShopItem'),
        getShop         = _stub('shops', 'getShop'),
        deleteShop      = _stub('shops', 'deleteShop'),
        getAllShops     = _stub('shops', 'getAllShops'),
        buyItem         = _stub('shops', 'buyItem'),
        shopExists      = _stub('shops', 'shopExists'),
        createQuickShop = _stub('shops', 'createQuickShop'),
        getShopItems    = _stub('shops', 'getShopItems'),
        clearShop       = _stub('shops', 'clearShop'),
        populateShop    = _stub('shops', 'populateShop'),
    },
    clothing     = {
        openClothing       = _stub('clothing', 'openClothing'),
        openOutfits        = _stub('clothing', 'openOutfits'),
        saveOutfit         = _stub('clothing', 'saveOutfit'),
        loadOutfit         = _stub('clothing', 'loadOutfit'),
        getPlayerClothing  = _stub('clothing', 'getPlayerClothing'),
        setPlayerClothing  = _stub('clothing', 'setPlayerClothing'),
        openShop           = _stub('clothing', 'openShop'),
        openPedMenu        = _stub('clothing', 'openPedMenu'),
    },
}

--- Player data normalisation -------------------------------------------------

---Normalises a raw framework player object into a common structure.
---@param data table
---@param map table<string, any>
---@param post fun(raw:table, normalised:table)? -- optional post-processor
---@return table|nil
function M.player(data, map, post)
    if not data then return nil end

    local n = {
        id         = _pick(data, map.id),
        identifier = _pick(data, map.identifier) or _pick(data, map.id),
        name       = _pick(data, map.name) or 'Unknown',

        job        = _pick(data, map.job) or {},
        gang       = _pick(data, map.gang) or { name = 'none', label = 'None', grade = 0 },
        money      = _pick(data, map.money) or {},
        metadata   = _pick(data, map.metadata) or {},

        charinfo   = _pick(data, map.charinfo),

        _original  = data
    }

    if post then post(data, n) end
    return n
end

-- Add __call metamethod for backward compatibility
setmetatable(M, {
    __call = function(_, ...)
        return M.player(...)
    end
})

return M
