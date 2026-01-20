--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class oxvector
lib.vector = {}

---Calculates euclidean distance between two 3D points.
---@param v1 vector3
---@param v2 vector3
---@return number
function lib.vector.distance(v1, v2)
    return #(v1 - v2)
end

---Calculates 2D distance (XY plane) between two points.
---@param v1 vector3
---@param v2 vector3
---@return number
function lib.vector.distance2D(v1, v2)
    return #(vec2(v1.x, v1.y) - vec2(v2.x, v2.y))
end

---Calculates heading (angle) from v1 to v2.
---@param v1 vector3
---@param v2 vector3
---@return number
function lib.vector.heading(v1, v2)
    local dx = v2.x - v1.x
    local dy = v2.y - v1.y
    return GetHeadingFromVector_2d(dx, dy)
end

---Returns a point offset from the given position by heading and distance.
---@param v vector3
---@param heading number
---@param distance number
---@return vector3
function lib.vector.offset(v, heading, distance)
    local rad = math.rad(heading)
    local x = v.x + math.sin(rad) * distance
    local y = v.y + math.cos(rad) * distance
    return vec3(x, y, v.z)
end

---Finds the closest point to the target from an array of points.
---@param target vector3
---@param points vector3[]
---@return vector3?
---@return number?
function lib.vector.closest(target, points)
    if #points == 0 then return nil, nil end

    local closest = points[1]
    local closestDist = lib.vector.distance(target, closest)

    for i = 2, #points do
        local dist = lib.vector.distance(target, points[i])
        if dist < closestDist then
            closest = points[i]
            closestDist = dist
        end
    end

    return closest, closestDist
end

---Checks if two points are within a maximum distance of each other.
---@param v1 vector3
---@param v2 vector3
---@param maxDistance number
---@return boolean
function lib.vector.inRange(v1, v2, maxDistance)
    return #(v1 - v2) <= maxDistance
end

return lib.vector
