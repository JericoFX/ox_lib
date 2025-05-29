-- Cargar todos los enums disponibles
local enums = {
    tasks = require('api.enums.tasks'),
    animations = require('api.enums.animations'),
    vehicles = require('api.enums.vehicles'),
    flags = require('api.enums.flags'),
    notifications = require('api.enums.notifications'),
    jobs = require('api.enums.jobs')
}

lib.enums = enums

return enums
