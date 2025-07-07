--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class DuiProperties
---@field url string
---@field width number
---@field height number
---@field debug? boolean

---@class Dui : OxClass
---@field private private { id: string, debug: boolean, hasFocus: boolean, mouseX: number, mouseY: number, callbacks: table, replacedTextures: table }
---@field url string
---@field duiObject number
---@field duiHandle string
---@field runtimeTxd number
---@field txdObject number
---@field dictName string
---@field txtName string
---@field width number
---@field height number
lib.dui = lib.class('Dui')

---@type table<string, Dui>
local duis = {}

local currentId = 0

---@param data DuiProperties
function lib.dui:constructor(data)
	local time = GetGameTimer()
	local id = ("%s_%s_%s"):format(cache.resource, time, currentId)
	currentId = currentId + 1
	local dictName = ('ox_lib_dui_dict_%s'):format(id)
	local txtName = ('ox_lib_dui_txt_%s'):format(id)
	local duiObject = CreateDui(data.url, data.width, data.height)
	local duiHandle = GetDuiHandle(duiObject)
	local runtimeTxd = CreateRuntimeTxd(dictName)
	local txdObject = CreateRuntimeTextureFromDuiHandle(runtimeTxd, txtName, duiHandle)
	self.private.id = id
	self.private.debug = data.debug or false
	self.private.hasFocus = false
	self.private.mouseX = 0
	self.private.mouseY = 0
	self.private.callbacks = {}
	self.private.replacedTextures = {}
	self.url = data.url
	self.duiObject = duiObject
	self.duiHandle = duiHandle
	self.runtimeTxd = runtimeTxd
	self.txdObject = txdObject
	self.dictName = dictName
	self.txtName = txtName
	self.width = data.width
	self.height = data.height
	duis[id] = self

	if self.private.debug then
		print(('Dui %s created'):format(id))
	end
end

function lib.dui:remove()
	self:removeAllTextureReplacements()
	SetDuiUrl(self.duiObject, 'about:blank')
	DestroyDui(self.duiObject)
	duis[self.private.id] = nil

	if self.private.debug then
		print(('Dui %s removed'):format(self.private.id))
	end
end

---@param url string
function lib.dui:setUrl(url)
	self.url = url
	SetDuiUrl(self.duiObject, url)

	if self.private.debug then
		print(('Dui %s url set to %s'):format(self.private.id, url))
	end
end

---@param message table
function lib.dui:sendMessage(message)
	SendDuiMessage(self.duiObject, json.encode(message))

	if self.private.debug then
		print(('Dui %s message sent with data :'):format(self.private.id), json.encode(message, { indent = true }))
	end
end

---@return boolean
function lib.dui:isAvailable()
	return IsDuiAvailable(self.duiObject)
end

---@param x number
---@param y number
---@param button number
function lib.dui:sendMouseDown(x, y, button)
	button = button or 0
	self.private.mouseX = x
	self.private.mouseY = y
	SendDuiMouseDown(self.duiObject, x, y, button)

	if self.private.debug then
		print(('Dui %s mouse down at %d,%d button %d'):format(self.private.id, x, y, button))
	end
end

---@param x number
---@param y number
---@param button number
function lib.dui:sendMouseUp(x, y, button)
	button = button or 0
	self.private.mouseX = x
	self.private.mouseY = y
	SendDuiMouseUp(self.duiObject, x, y, button)

	if self.private.debug then
		print(('Dui %s mouse up at %d,%d button %d'):format(self.private.id, x, y, button))
	end
end

---@param x number
---@param y number
function lib.dui:sendMouseMove(x, y)
	self.private.mouseX = x
	self.private.mouseY = y
	SendDuiMouseMove(self.duiObject, x, y)

	if self.private.debug then
		print(('Dui %s mouse move to %d,%d'):format(self.private.id, x, y))
	end
end

---@param x number
---@param y number
---@param deltaX number
---@param deltaY number
function lib.dui:sendMouseWheel(x, y, deltaX, deltaY)
	deltaX = deltaX or 0
	deltaY = deltaY or 0
	self.private.mouseX = x
	self.private.mouseY = y
	SendDuiMouseWheel(self.duiObject, x, y, deltaX, deltaY)

	if self.private.debug then
		print(('Dui %s mouse wheel at %d,%d delta %d,%d'):format(self.private.id, x, y, deltaX, deltaY))
	end
end

---@return table
function lib.dui:getDimensions()
	return { width = self.width, height = self.height }
end

---@param width number
---@param height number
function lib.dui:setDimensions(width, height)
	if width and height then
		self.width = width
		self.height = height

		if self.private.debug then
			print(('Dui %s dimensions changed to %dx%d'):format(self.private.id, width, height))
		end
	end
end

---@param hasFocus boolean
function lib.dui:setFocus(hasFocus)
	self.private.hasFocus = hasFocus

	if self.private.debug then
		print(('Dui %s focus set to %s'):format(self.private.id, tostring(hasFocus)))
	end
end

---@return boolean
function lib.dui:hasFocus()
	return self.private.hasFocus
end

---@return table
function lib.dui:getMousePosition()
	return { x = self.private.mouseX, y = self.private.mouseY }
end

---@param eventName string
---@param callback function
function lib.dui:onCallback(eventName, callback)
	self.private.callbacks[eventName] = callback

	if self.private.debug then
		print(('Dui %s callback registered for event %s'):format(self.private.id, eventName))
	end
end

---@param eventName string
---@param data table
function lib.dui:triggerCallback(eventName, data)
	local callback = self.private.callbacks[eventName]
	if callback and type(callback) == 'function' then
		callback(data)

		if self.private.debug then
			print(('Dui %s callback triggered for event %s'):format(self.private.id, eventName))
		end
	end
end

---@return boolean
function lib.dui:isValid()
	return self.duiObject and self:isAvailable()
end

---@param origTxd string
---@param origTxn string
function lib.dui:replaceTexture(origTxd, origTxn)
	local replacementKey = ('%s_%s'):format(origTxd, origTxn)

	if self.private.replacedTextures[replacementKey] then
		if self.private.debug then
			print(('Dui %s texture %s:%s already replaced'):format(self.private.id, origTxd, origTxn))
		end
		return
	end

	AddReplaceTexture(origTxd, origTxn, self.dictName, self.txtName)
	self.private.replacedTextures[replacementKey] = true

	if self.private.debug then
		print(('Dui %s replaced texture %s:%s with %s:%s'):format(self.private.id, origTxd, origTxn, self.dictName, self.txtName))
	end
end

---@param origTxd string
---@param origTxn string
function lib.dui:removeTextureReplacement(origTxd, origTxn)
	local replacementKey = ('%s_%s'):format(origTxd, origTxn)

	if not self.private.replacedTextures[replacementKey] then
		if self.private.debug then
			print(('Dui %s texture %s:%s not replaced'):format(self.private.id, origTxd, origTxn))
		end
		return
	end

	RemoveReplaceTexture(origTxd, origTxn)
	self.private.replacedTextures[replacementKey] = nil

	if self.private.debug then
		print(('Dui %s removed texture replacement %s:%s'):format(self.private.id, origTxd, origTxn))
	end
end

function lib.dui:removeAllTextureReplacements()
	for replacementKey, _ in pairs(self.private.replacedTextures) do
		local origTxd, origTxn = replacementKey:match('(.+)_(.+)')
		if origTxd and origTxn then
			RemoveReplaceTexture(origTxd, origTxn)
		end
	end
	self.private.replacedTextures = {}

	if self.private.debug then
		print(('Dui %s removed all texture replacements'):format(self.private.id))
	end
end

---@return table
function lib.dui:getReplacedTextures()
	local replacements = {}
	for replacementKey, _ in pairs(self.private.replacedTextures) do
		local origTxd, origTxn = replacementKey:match('(.+)_(.+)')
		if origTxd and origTxn then
			table.insert(replacements, { txd = origTxd, txn = origTxn })
		end
	end
	return replacements
end

AddEventHandler('onResourceStop', function(resourceName)
	if cache.resource ~= resourceName then return end

	for _, dui in pairs(duis) do
		dui:remove()
	end
end)

return lib.dui
