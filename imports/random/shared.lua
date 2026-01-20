--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class oxrandom
lib.random = {}

---Chooses a random element from a table.
---@param tbl table
---@return unknown
function lib.random.choice(tbl)
    if #tbl == 0 then return nil end
    local index = math.random(1, #tbl)
    return tbl[index]
end

---Chooses a random element from a weighted table.
---@param tbl table<string|number, number> | {[string|number]: number}
---@return string|number?
function lib.random.weighted(tbl)
    local totalWeight = 0
    for _, weight in pairs(tbl) do
        totalWeight += weight
    end

    if totalWeight == 0 then return nil end

    local randomValue = math.random() * totalWeight
    local cumulativeWeight = 0

    for value, weight in pairs(tbl) do
        cumulativeWeight += weight
        if randomValue <= cumulativeWeight then
            return value
        end
    end

    return next(tbl)
end

---Generates a random UUID v4 string.
---@return string
function lib.random.uuid()
    return string.format('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx',
        string.char(math.random(97, 102)),
        string.char(math.random(97, 122)),
        string.char(math.random(97, 102)),
        string.char(math.random(97, 102)),
        string.char(math.random(97, 102)),
        string.char(math.random(97, 102)),
        string.char(math.random(97, 122)),
        string.char(math.random(97, 102))
    ):gsub('[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

---Returns a random number between min and max (inclusive).
---@param min number
---@param max number
---@return number
function lib.random.between(min, max)
    return math.random(min, max)
end

---Returns a random character (uppercase, lowercase, or digit).
---@param includeDigits? boolean
---@param includeLower? boolean
---@return string
function lib.random.char(includeDigits, includeLower)
    includeDigits = includeDigits ~= false
    includeLower = includeLower ~= false

    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

    if includeLower then
        chars = chars .. 'abcdefghijklmnopqrstuvwxyz'
    end

    if includeDigits then
        chars = chars .. '0123456789'
    end

    local index = math.random(1, #chars)
    return string.sub(chars, index, index)
end

---Returns a random boolean based on chance.
---@param chance? number (0-1, default 0.5)
---@return boolean
function lib.random.bool(chance)
    chance = chance or 0.5
    return math.random() < chance
end

return lib.random
