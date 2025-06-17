---@diagnostic disable: undefined-global, duplicate-set-field, lowercase-global
---@meta
--  ox_lib complete stub types for Lua language servers (sumneko/LuaLS)
--  This file is NOT executed.  It only provides type information.
--  Generated from the current ox_lib resource structure.

----------------------------------------
--  Basic aliases & helpers
----------------------------------------

---@alias vector3 table  -- { x: number, y: number, z: number }
---@alias vector4 table  -- { x: number, y: number, z: number, w: number }

----------------------------------------
--  Global singletons provided by ox_lib
----------------------------------------

---@class lib  : table
lib = lib or {}  ---@diagnostic disable-line: duplicate-set-field

---@class cache : table
cache = cache or {} ---@diagnostic disable-line: duplicate-set-field

---@class FiveMExports : table<string, any>
exports = exports or {} ---@diagnostic disable-line: duplicate-set-field

----------------------------------------
--  Global helper functions
----------------------------------------

---Creates/replaces an interval.
---@param callback  (fun(...:any))|number  Either a new callback or an existing ID to update.
---@param interval? number  Interval in milliseconds (default 0)
---@vararg any  Arguments forwarded to the callback.
---@return number id  Interval identifier.
function SetInterval(callback, interval, ...) end

---Stops an existing interval.
---@param id number
function ClearInterval(id) end

---Cache the result of a function for an optional duration.
---@generic T
---@param key     string
---@param func    fun(...:any):T
---@param timeout? number  Time in ms before cache invalidates.
---@return T
function cache(key, func, timeout) end

---Subscribe to cache updates for a specific key.
---@param key string
---@param cb  fun(new:any, old:any)
function lib.onCache(key, cb) end

----------------------------------------
--  Primary lib utility namespaces
----------------------------------------

---@class lib.print : table
lib.print = lib.print or {}
function lib.print.info(...) end
function lib.print.warn(...) end
function lib.print.error(...) end

---@class lib.callback : table
lib.callback = lib.callback or {}
function lib.callback.await(name, timeout, ...) end
function lib.callback.register(name, fn) end

---@class lib.promise : table
lib.promise = lib.promise or {}
function lib.promise.new() end

----------------------------------------
--  Modules automatically lazy-required via lib.<module>()
--  Only high-level placeholders are declared here –
--  LuaLS will still parse each module file for detailed APIs.
----------------------------------------

---@class lib.audio : table
lib.audio = lib.audio or {}

---@class lib.blips : table
lib.blips = lib.blips or {}

---@class lib.camera : table
lib.camera = lib.camera or {}

---@class lib.damage : table
lib.damage = lib.damage or {}

---@class lib.database : table
lib.database = lib.database or {}

---@class lib.discord : table
lib.discord = lib.discord or {}

---@class lib.events : table
lib.events = lib.events or {}

---@class lib.network : table
lib.network = lib.network or {}

---@class lib.npc : table
lib.npc = lib.npc or {}

---@class lib.objects : table
lib.objects = lib.objects or {}

---@class lib.player : table
lib.player = lib.player or {}

---@class lib.statebags : table
lib.statebags = lib.statebags or {}

---@class lib.task : table
lib.task = lib.task or {}

---@class lib.tickets : table
lib.tickets = lib.tickets or {}

---@class lib.vehicle : table
lib.vehicle = lib.vehicle or {}

---@class lib.weapons : table
lib.weapons = lib.weapons or {}

----------------------------------------
--  Enumerations (lazy-loaded via lib.enums)
----------------------------------------

---@class lib.enums : table
lib.enums = lib.enums or {}

---@class lib.enums.animations : table
---@class lib.enums.audio       : table
---@class lib.enums.camera      : table
---@class lib.enums.damage      : table
---@class lib.enums.flags       : table
---@class lib.enums.jobs        : table
---@class lib.enums.notifications : table
---@class lib.enums.npc         : table
---@class lib.enums.statebags   : table
---@class lib.enums.tasks       : table
---@class lib.enums.vehicles    : table
---@class lib.enums.weapons     : table

----------------------------------------
--  Net / UI helpers exposed to other resources
----------------------------------------

---Server-side: send a notification to a player.
---@overload fun(playerId:number, data:table)
function lib.notify(playerId, data) end

----------------------------------------
--  Import helper modules (imports/)
----------------------------------------

---@class lib.array              : table
lib.array = lib.array or {}
---@class lib.callback           : table  -- already declared but keep for completeness
---@class lib.class              : table
lib.class = lib.class or {}
---@class lib.cron               : table
lib.cron = lib.cron or {}
---@class lib.disableControls    : table
lib.disableControls = lib.disableControls or {}
---@class lib.dui                : table
lib.dui = lib.dui or {}
---@class lib.getClosestObject   : table
lib.getClosestObject = lib.getClosestObject or {}
---@class lib.getClosestPed      : table
lib.getClosestPed = lib.getClosestPed or {}
---@class lib.getClosestPlayer   : table
lib.getClosestPlayer = lib.getClosestPlayer or {}
---@class lib.getClosestVehicle  : table
lib.getClosestVehicle = lib.getClosestVehicle or {}
---@class lib.getFilesInDirectory: table
lib.getFilesInDirectory = lib.getFilesInDirectory or {}
---@class lib.getNearbyObjects   : table
lib.getNearbyObjects = lib.getNearbyObjects or {}
---@class lib.getNearbyPeds      : table
lib.getNearbyPeds = lib.getNearbyPeds or {}
---@class lib.getNearbyPlayers   : table
lib.getNearbyPlayers = lib.getNearbyPlayers or {}
---@class lib.getNearbyVehicles  : table
lib.getNearbyVehicles = lib.getNearbyVehicles or {}
---@class lib.getRelativeCoords  : table
lib.getRelativeCoords = lib.getRelativeCoords or {}
---@class lib.grid               : table
lib.grid = lib.grid or {}
---@class lib.locale             : table
lib.locale = lib.locale or {}
---@class lib.logger             : table
lib.logger = lib.logger or {}
---@class lib.marker             : table
lib.marker = lib.marker or {}
---@class lib.math               : table  -- math helper overrides standard Lua math when imported via lib
lib.math = lib.math or {}
---@class lib.networkScenes      : table
lib.networkScenes = lib.networkScenes or {}
---@class lib.playAnim           : table
lib.playAnim = lib.playAnim or {}
---@class lib.playAnimAdvanced   : table
lib.playAnimAdvanced = lib.playAnimAdvanced or {}
---@class lib.points             : table
lib.points = lib.points or {}
---@class lib.print              : table  -- already declared
---@class lib.raycast            : table
lib.raycast = lib.raycast or {}
---@class lib.requestAnimDict    : table
lib.requestAnimDict = lib.requestAnimDict or {}
---@class lib.requestAnimSet     : table
lib.requestAnimSet = lib.requestAnimSet or {}
---@class lib.requestAudioBank   : table
lib.requestAudioBank = lib.requestAudioBank or {}
---@class lib.requestModel       : table
lib.requestModel = lib.requestModel or {}
---@class lib.requestNamedPtfxAsset : table
lib.requestNamedPtfxAsset = lib.requestNamedPtfxAsset or {}
---@class lib.requestScaleformMovie : table
lib.requestScaleformMovie = lib.requestScaleformMovie or {}
---@class lib.requestStreamedTextureDict : table
lib.requestStreamedTextureDict = lib.requestStreamedTextureDict or {}
---@class lib.requestWeaponAsset : table
lib.requestWeaponAsset = lib.requestWeaponAsset or {}
---@class lib.require            : table
lib.require = lib.require or {}
---@class lib.scaleform          : table
lib.scaleform = lib.scaleform or {}
---@class lib.string             : table
lib.string = lib.string or {}
---@class lib.streamingRequest   : table
lib.streamingRequest = lib.streamingRequest or {}
---@class lib.table              : table  -- table helper
lib.table = lib.table or {}
---@class lib.timer              : table
lib.timer = lib.timer or {}
---@class lib.triggerClientEvent : table
lib.triggerClientEvent = lib.triggerClientEvent or {}
---@class lib.waitFor            : table
lib.waitFor = lib.waitFor or {}
---@class lib.zones              : table
lib.zones = lib.zones or {}
---@class lib.stats              : table
lib.stats = lib.stats or {}
---@class lib.achievements       : table
lib.achievements = lib.achievements or {}
---@class lib.addCommand         : table
lib.addCommand = lib.addCommand or {}
---@class lib.__addCommand       : table
lib.__addCommand = lib.__addCommand or {}
---@class lib.addKeybind         : table
lib.addKeybind = lib.addKeybind or {}
---@class lib.hooks              : table
lib.hooks = lib.hooks or {}

----------------------------------------
--  Wrapper modules (wrappers/)
----------------------------------------

---@class lib.banking   : table
lib.banking = lib.banking or {}
---@class lib.clothing  : table
lib.clothing = lib.clothing or {}
---@class lib.core      : table
lib.core = lib.core or {}
---@class lib.dispatch  : table
lib.dispatch = lib.dispatch or {}
---@class lib.fuel      : table
lib.fuel = lib.fuel or {}
---@class lib.garage    : table
lib.garage = lib.garage or {}
---@class lib.housing   : table
lib.housing = lib.housing or {}
---@class lib.hud       : table
lib.hud = lib.hud or {}
---@class lib.inventory : table
lib.inventory = lib.inventory or {}
---@class lib.job       : table
lib.job = lib.job or {}
---@class lib.medical   : table
lib.medical = lib.medical or {}
---@class lib.phone     : table
lib.phone = lib.phone or {}
---@class lib.shops     : table
lib.shops = lib.shops or {}
---@class lib.targeting : table
lib.targeting = lib.targeting or {}
---@class lib.voice     : table
lib.voice = lib.voice or {}

----------------------------------------
--  Resource-side helper namespaces (resource/)
----------------------------------------

---@class lib.acl               : table
lib.acl = lib.acl or {}
---@class lib.cacheModule       : table
lib.cacheModule = lib.cacheModule or {}
---@class lib.callbacks         : table
lib.callbacks = lib.callbacks or {}
---@class lib.interface         : table
lib.interface = lib.interface or {}
---@class lib.localeResource    : table
lib.localeResource = lib.localeResource or {}
---@class lib.vehicleProperties : table
lib.vehicleProperties = lib.vehicleProperties or {}
---@class lib.version           : table
lib.version = lib.version or {}
---@class lib.zoneCreator       : table
lib.zoneCreator = lib.zoneCreator or {}
---@class lib.settings          : table
lib.settings = lib.settings or {}

----------------------------------------
--  Return to satisfy `require` when used directly.
----------------------------------------
return lib 