--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@diagnostic disable: param-type-mismatch
lib.marker = {}

---@enum (key) MarkerType
local markerTypes = {
  UpsideDownCone = 0,
  VerticalCylinder = 1,
  ThickChevronUp = 2,
  ThinChevronUp = 3,
  CheckeredFlagRect = 4,
  CheckeredFlagCircle = 5,
  VerticleCircle = 6,
  PlaneModel = 7,
  LostMCTransparent = 8,
  LostMC = 9,
  Number0 = 10,
  Number1 = 11,
  Number2 = 12,
  Number3 = 13,
  Number4 = 14,
  Number5 = 15,
  Number6 = 16,
  Number7 = 17,
  Number8 = 18,
  Number9 = 19,
  ChevronUpx1 = 20,
  ChevronUpx2 = 21,
  ChevronUpx3 = 22,
  HorizontalCircleFat = 23,
  ReplayIcon = 24,
  HorizontalCircleSkinny = 25,
  HorizontalCircleSkinny_Arrow = 26,
  HorizontalSplitArrowCircle = 27,
  DebugSphere = 28,
  DollarSign = 29,
  HorizontalBars = 30,
  WolfHead = 31,
  QuestionMark = 32,
  PlaneSymbol = 33,
  HelicopterSymbol = 34,
  BoatSymbol = 35,
  CarSymbol = 36,
  MotorcycleSymbol = 37,
  BikeSymbol = 38,
  TruckSymbol = 39,
  ParachuteSymbol = 40,
  Unknown41 = 41,
  SawbladeSymbol = 42,
  Unknown43 = 43,
}

---@class MarkerProps
---@field type? MarkerType | integer
---@field coords { x: number, y: number, z: number }
---@field width? number
---@field height? number
---@field color? { r: integer, g: integer, b: integer, a: integer }
---@field rotation? { x: number, y: number, z: number }
---@field direction? { x: number, y: number, z: number }
---@field bobUpAndDown? boolean
---@field faceCamera? boolean
---@field rotate? boolean
---@field textureDict? string
---@field textureName? string
---@field invert? boolean
---@field distance? number
---@field interactionDistance? number
---@field onEnter? fun(self: CMarker)
---@field onExit? fun(self: CMarker)
---@field nearby? fun(self: CMarker)
---@field debug? boolean
---@field [string] any

---@class CMarker : MarkerProps
---@field id number
---@field currentDistance number
---@field inside? boolean
---@field isVisible boolean
---@field remove fun(self: self)
---@field setCoords fun(self: self, coords: vector3)
---@field setColor fun(self: self, color: table)
---@field setType fun(self: self, type: MarkerType | integer)
---@field setRotation fun(self: self, rotation: vector3)
---@field setSize fun(self: self, width: number, height: number)
---@field show fun(self: self)
---@field hide fun(self: self)
---@field pulse fun(self: self, duration?: number)
---@field draw fun(self: self)

local vector3_zero = vector3(0, 0, 0)
local nextMarkerId = 1
local markers = {}
local nearbyMarkers = {}
local nearbyCount = 0
local tick
local pulsingMarkers = {}
local mainThread

local marker_mt = {
  type = 0,
  width = 2.0,
  height = 1.0,
  color = { r = 255, g = 100, b = 0, a = 100 },
  rotation = vector3_zero,
  direction = vector3_zero,
  bobUpAndDown = false,
  faceCamera = false,
  rotate = false,
  invert = false,
  distance = 50.0,
  interactionDistance = 2.0,
  isVisible = true,
  debug = false,
}
marker_mt.__index = marker_mt

local function removeMarker(self)
  lib.grid.removeEntry(self)
  markers[self.id] = nil
  pulsingMarkers[self.id] = nil

  if self.inside and self.onExit then
    self:onExit()
  end

  if next(markers) == nil and mainThread then
    mainThread = nil
  end
end

local function toVector(coords)
  return type(coords) == 'vector3' and coords or vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
end

function marker_mt:draw()
  if not self.isVisible then return end

  local pulseData = pulsingMarkers[self.id]
  local alpha = self.color.a

  if pulseData then
    local elapsed = GetGameTimer() - pulseData.startTime
    local progress = elapsed / pulseData.duration

    if progress >= 1.0 then
      pulsingMarkers[self.id] = nil
    else
      alpha = math.floor(self.color.a * (0.3 + 0.7 * math.abs(math.sin(progress * math.pi * 4))))
    end
  end

  DrawMarker(
    self.type,
    self.coords.x, self.coords.y, self.coords.z,
    self.direction.x, self.direction.y, self.direction.z,
    self.rotation.x, self.rotation.y, self.rotation.z,
    self.width, self.width, self.height,
    self.color.r, self.color.g, self.color.b, alpha,
    self.bobUpAndDown, self.faceCamera, 2, self.rotate,
    self.textureDict, self.textureName, self.invert
  )

  if self.debug then
    DrawMarker(
      28, -- Debug sphere
      self.coords.x, self.coords.y, self.coords.z,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      self.interactionDistance * 2, self.interactionDistance * 2, self.interactionDistance * 2,
      255, 0, 0, 50,
      false, false, 2, false, nil, nil, false
    )
  end
end

function marker_mt:remove()
  removeMarker(self)
end

function marker_mt:setCoords(coords)
  lib.grid.removeEntry(self)
  self.coords = toVector(coords)
  lib.grid.addEntry(self)
end

function marker_mt:setColor(color)
  self.color = {
    r = color.r or self.color.r,
    g = color.g or self.color.g,
    b = color.b or self.color.b,
    a = color.a or self.color.a
  }
end

function marker_mt:setType(markerType)
  self.type = type(markerType) == 'string' and markerTypes[markerType] or markerType
end

function marker_mt:setRotation(rotation)
  self.rotation = toVector(rotation)
end

function marker_mt:setSize(width, height)
  self.width = width or self.width
  self.height = height or self.height
end

function marker_mt:show()
  self.isVisible = true
end

function marker_mt:hide()
  self.isVisible = false
end

function marker_mt:pulse(duration)
  pulsingMarkers[self.id] = {
    startTime = GetGameTimer(),
    duration = duration or 2000
  }
end

local function startMainThread()
  if mainThread then return end

  mainThread = CreateThread(function()
    while next(markers) do
      local coords = cache.coords or GetEntityCoords(cache.ped)
      local newMarkers = lib.grid.getNearbyEntries(coords, function(entry)
        return entry.remove == removeMarker and entry.currentDistance <= entry.distance
      end)

      cache.coords = coords
      nearbyCount = 0

      for i = 1, #newMarkers do
        local marker = newMarkers[i]
        local distance = #(coords - marker.coords)
        marker.currentDistance = distance

        if distance <= marker.distance then
          nearbyCount = nearbyCount + 1
          nearbyMarkers[nearbyCount] = marker

          local wasInside = marker.inside
          local isInside = distance <= marker.interactionDistance

          if isInside and not wasInside then
            marker.inside = true
            if marker.onEnter then marker:onEnter() end
          elseif wasInside and not isInside then
            marker.inside = false
            if marker.onExit then marker:onExit() end
          end

          if isInside and marker.nearby then
            marker:nearby()
          end
        elseif marker.inside then
          marker.inside = false
          if marker.onExit then marker:onExit() end
        end
      end

      if not tick then
        if nearbyCount > 0 then
          tick = SetInterval(function()
            for i = 1, nearbyCount do
              nearbyMarkers[i]:draw()
            end
          end)
        end
      elseif nearbyCount == 0 then
        tick = ClearInterval(tick)
      end

      Wait(300)
    end

    if tick then
      tick = ClearInterval(tick)
    end
    mainThread = nil
  end)
end

---@param options MarkerProps
---@return CMarker
function lib.marker.new(options)
  if not options.coords then
    error('marker requires coords')
  end

  options.coords = toVector(options.coords)
  options.id = nextMarkerId
  options.remove = removeMarker
  nextMarkerId = nextMarkerId + 1

  if options.type then
    options.type = type(options.type) == 'string' and markerTypes[options.type] or options.type
  end

  local self = setmetatable(options, marker_mt)

  self.width = self.width + 0.0
  self.height = self.height + 0.0
  self.radius = math.max(self.width, self.height, self.interactionDistance)

  lib.grid.addEntry(self)
  markers[self.id] = self

  startMainThread()

  return self
end

---@param coords vector3 | table
---@param options? MarkerProps
---@return CMarker
function lib.marker.createAtCoords(coords, options)
  options = options or {}
  options.coords = coords
  return lib.marker.new(options)
end

---@param entity number
---@param options? MarkerProps
---@return CMarker
function lib.marker.createForEntity(entity, options)
  if not DoesEntityExist(entity) then
    error('entity does not exist')
  end

  options = options or {}
  options.coords = GetEntityCoords(entity)
  local marker = lib.marker.new(options)

  CreateThread(function()
    while DoesEntityExist(entity) and markers[marker.id] do
      local coords = GetEntityCoords(entity)
      if marker.coords ~= coords then
        marker:setCoords(coords)
      end
      Wait(500)
    end

    if markers[marker.id] then
      marker:remove()
    end
  end)

  return marker
end

---@param markerType MarkerType | integer
---@param coords vector3 | table
---@param color? table
---@param options? MarkerProps
---@return CMarker
function lib.marker.create(markerType, coords, color, options)
  options = options or {}
  options.type = markerType
  options.coords = coords
  if color then options.color = color end
  return lib.marker.new(options)
end

---@return table<number, CMarker>
function lib.marker.getAllMarkers()
  return markers
end

---@return CMarker[]
function lib.marker.getNearbyMarkers()
  return nearbyMarkers
end

---@param id number
---@return CMarker?
function lib.marker.getMarkerById(id)
  return markers[id]
end

---@param markerType MarkerType | integer
---@return CMarker[]
function lib.marker.getMarkersByType(markerType)
  local result = {}
  local typeId = type(markerType) == 'string' and markerTypes[markerType] or markerType

  for _, marker in pairs(markers) do
    if marker.type == typeId then
      result[#result + 1] = marker
    end
  end

  return result
end

function lib.marker.removeAll()
  for _, marker in pairs(markers) do
    marker:remove()
  end
end

return lib.marker
