---@meta

---@class lib.enums
---@field tasks table Task-related enumerations
---@field animations table Animation-related enumerations
---@field vehicles table Vehicle-related enumerations
---@field flags table Flag-related enumerations
---@field notifications table Notification-related enumerations
---@field jobs table Job-related enumerations
---@field audio table Audio-related enumerations
---@field camera table Camera-related enumerations
---@field weapons table Weapons-related enumerations
---@field statebags table StateBag-related enumerations
---@field damage table Damage-related enumerations

-- Cargar todos los enums disponibles
local enums = {
    tasks = require('api.enums.tasks'),
    animations = require('api.enums.animations'),
    vehicles = require('api.enums.vehicles'),
    flags = require('api.enums.flags'),
    notifications = require('api.enums.notifications'),
    jobs = require('api.enums.jobs'),
    audio = require('api.enums.audio'),
    camera = require('api.enums.camera'),
    weapons = require('api.enums.weapons'),
    statebags = require('api.enums.statebags'),
    damage = require('api.enums.damage')
}

lib.enums = enums

return enums
