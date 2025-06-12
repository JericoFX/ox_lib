---@meta
---@JericoFX
--[[
    Discord Integration System for ox_lib

    This module provides a comprehensive Discord webhook integration system that allows
    sending rich messages, embeds with colors, player logs, admin logs, and server status
    updates to Discord channels. The system includes:

    - Instance-based webhook management with default configurations
    - Message validation and error handling
    - Rich embed creation with customizable colors, fields, thumbnails, and footers
    - Pre-built log templates for common server events
    - Text formatting utilities for Discord markdown
    - Player identification extraction (license, discord, steam)
    - Automatic timestamp and server information injection

    All functions use Discord's webhook API and support async operations through
    FiveM's PerformHttpRequest with promise-based handling.
--]]

---@class DiscordOptions
---@field username? string Custom username for the webhook
---@field avatar_url? string Custom avatar URL for the webhook
---@field tts? boolean Text-to-speech option
---@field content? string Additional content for embed messages
---@field timestamp? string ISO timestamp string
---@field server_name? string Custom server name for footer
---@field server_icon? string Custom server icon URL for footer
---@field fields? DiscordField[] Array of additional fields to add

---@class DiscordField
---@field name string Field name
---@field value string Field value
---@field inline? boolean Whether field should be inline

---@class DiscordEmbed
---@field title? string Embed title
---@field description? string Embed description
---@field url? string Embed URL
---@field timestamp? string ISO timestamp
---@field color? number|string Color as number or color name
---@field author? DiscordEmbedAuthor Author information
---@field thumbnail? DiscordEmbedMedia Thumbnail information
---@field image? DiscordEmbedMedia Image information
---@field footer? DiscordEmbedFooter Footer information
---@field fields? DiscordField[] Array of embed fields

---@class DiscordEmbedAuthor
---@field name string Author name
---@field url? string Author URL
---@field icon_url? string Author icon URL

---@class DiscordEmbedMedia
---@field url string Media URL

---@class DiscordEmbedFooter
---@field text string Footer text
---@field icon_url? string Footer icon URL

---@class DiscordHttpResponse
---@field status number HTTP status code
---@field body string Response body
---@field headers table Response headers

---@class DiscordInstanceOptions
---@field username? string Default username for this instance
---@field avatar_url? string Default avatar URL for this instance
---@field server_name? string Default server name for footers
---@field server_icon? string Default server icon URL for footers
---@field default_color? string|number Default embed color
---@field validate_webhooks? boolean Whether to validate webhook URLs (default: true)

---@class lib.discord : OxClass
---@field private private { webhook: string, options: DiscordInstanceOptions, colors: table<string, number> }
lib.discord = lib.class('Discord')

---Discord color definitions with their decimal values
---@type table<string, number>
local colors = {
    default = 0,
    white = 16777215,
    aqua = 1752220,
    green = 3066993,
    blue = 3447003,
    yellow = 16776960,
    purple = 10181046,
    luminous_vivid_pink = 15277667,
    gold = 15844367,
    orange = 15105570,
    red = 15158332,
    grey = 9807270,
    navy = 3426654,
    dark_aqua = 1146986,
    dark_green = 2067276,
    dark_blue = 2123412,
    dark_purple = 7419530,
    dark_vivid_pink = 11342935,
    dark_gold = 12745742,
    dark_orange = 11027200,
    dark_red = 10038562,
    dark_grey = 9936031,
    darker_grey = 8359053,
    light_grey = 12370112,
    dark_navy = 2899536,
    blurple = 5793266,
    greyple = 10070709,
    dark_but_not_black = 2895667,
    not_quite_black = 2303786,
    random = math.random(0, 16777215)
}

---Performs an HTTP request to Discord webhook with promise-based handling
---@param url string Webhook URL
---@param data table Request payload
---@param headers? table HTTP headers
---@return DiscordHttpResponse response HTTP response object
local function performHttpRequest(url, data, headers)
    if not url:match('https://discord%.com/') and not url:match('https://discordapp%.com/') then
        return {
            status = 400,
            body = 'Only Discord URLs are allowed',
            headers = {}
        }
    end

    local promise = promise.new()

    PerformHttpRequest(url, function(statusCode, response, responseHeaders)
        promise:resolve({
            status = statusCode,
            body = response,
            headers = responseHeaders
        })
    end, 'POST', json.encode(data), headers or { ['Content-Type'] = 'application/json' })

    return Citizen.Await(promise)
end

---Validates Discord webhook URL format
---@param webhook string Webhook URL to validate
---@return boolean isValid Whether webhook is valid
---@return string? error Error message if validation fails
local function validateWebhook(webhook)
    if not webhook or type(webhook) ~= 'string' then
        return false, 'Webhook URL is required and must be a string'
    end

    if not webhook:match('https://discord%.com/api/webhooks/') and not webhook:match('https://discordapp%.com/api/webhooks/') then
        return false, 'Invalid Discord webhook URL'
    end

    return true
end

---Constructor for Discord instance
---@param webhook string Default webhook URL for this instance
---@param options? DiscordInstanceOptions Instance configuration options
function lib.discord:constructor(webhook, options)
    if not webhook then
        error('Discord webhook URL is required', 2)
    end

    local isValid, error = validateWebhook(webhook)
    if not isValid then
        error('Invalid Discord webhook: ' .. error, 2)
    end

    options = options or {}

    self.private.webhook = webhook
    self.private.options = {
        username = options.username,
        avatar_url = options.avatar_url,
        server_name = options.server_name or GetConvar('sv_hostname', 'FiveM Server'),
        server_icon = options.server_icon,
        default_color = options.default_color or 'blue',
        validate_webhooks = options.validate_webhooks ~= false
    }
    self.private.colors = colors
end

---Sends a simple text message to Discord webhook
---@param message string Message content to send
---@param webhook? string Override webhook URL for this message
---@param options? DiscordOptions Additional options for the message
---@return boolean success Whether the message was sent successfully
function lib.discord:sendMessage(message, webhook, options)
    webhook = webhook or self.private.webhook
    options = options or {}

    if self.private.options.validate_webhooks then
        local isValid, error = validateWebhook(webhook)
        if not isValid then
            print('^1[ox_lib] Discord Error: ' .. error .. '^0')
            return false
        end
    end

    local data = {
        content = message,
        username = options.username or self.private.options.username,
        avatar_url = options.avatar_url or self.private.options.avatar_url,
        tts = options.tts or false
    }

    local response = performHttpRequest(webhook, data)

    if response.status == 204 then
        return true
    else
        print('^1[ox_lib] Discord Error: ' .. (response.body or 'Unknown error') .. '^0')
        return false
    end
end

---Sends one or more embeds to Discord webhook
---@param embeds DiscordEmbed[] Array of embed objects
---@param webhook? string Override webhook URL for this message
---@param options? DiscordOptions Additional options for the message
---@return boolean success Whether the embeds were sent successfully
function lib.discord:sendEmbed(embeds, webhook, options)
    webhook = webhook or self.private.webhook
    options = options or {}

    if self.private.options.validate_webhooks then
        local isValid, error = validateWebhook(webhook)
        if not isValid then
            print('^1[ox_lib] Discord Error: ' .. error .. '^0')
            return false
        end
    end

    if type(embeds) ~= 'table' or #embeds == 0 then
        print('^1[ox_lib] Discord Error: Embeds must be a non-empty table^0')
        return false
    end

    local data = {
        content = options.content,
        username = options.username or self.private.options.username,
        avatar_url = options.avatar_url or self.private.options.avatar_url,
        tts = options.tts or false,
        embeds = embeds
    }

    local response = performHttpRequest(webhook, data)

    if response.status == 204 then
        return true
    else
        print('^1[ox_lib] Discord Error: ' .. (response.body or 'Unknown error') .. '^0')
        return false
    end
end

---Creates a Discord embed object with specified options
---@param options? DiscordEmbed Embed configuration options
---@return DiscordEmbed embed Configured embed object
function lib.discord:createEmbed(options)
    options = options or {}

    local embed = {
        title = options.title,
        description = options.description,
        url = options.url,
        timestamp = options.timestamp,
        color = type(options.color) == 'string' and self.private.colors[options.color] or options.color or self.private.colors[self.private.options.default_color]
    }

    if options.author then
        embed.author = {
            name = options.author.name,
            url = options.author.url,
            icon_url = options.author.icon_url
        }
    end

    if options.thumbnail then
        embed.thumbnail = {
            url = options.thumbnail
        }
    end

    if options.image then
        embed.image = {
            url = options.image
        }
    end

    if options.footer then
        embed.footer = {
            text = options.footer.text,
            icon_url = options.footer.icon_url
        }
    end

    if options.fields and type(options.fields) == 'table' then
        embed.fields = options.fields
    end

    return embed
end

---Adds a field to an existing embed object
---@param embed DiscordEmbed Embed object to modify
---@param name string|number Field name
---@param value string|number Field value
---@param inline? boolean Whether field should be displayed inline
---@return DiscordEmbed embed Modified embed object
function lib.discord:addField(embed, name, value, inline)
    if not embed.fields then
        embed.fields = {}
    end

    embed.fields[#embed.fields + 1] = {
        name = tostring(name),
        value = tostring(value),
        inline = inline or false
    }

    return embed
end

---Sends a generic log message with automatic timestamp and server info
---@param title string Log title
---@param description string Log description
---@param color? string|number Embed color name or decimal value
---@param webhook? string Override webhook URL
---@param options? DiscordOptions Additional options
---@return boolean success Whether the log was sent successfully
function lib.discord:sendLog(title, description, color, webhook, options)
    options = options or {}

    local embed = self:createEmbed({
        title = title,
        description = description,
        color = color or self.private.options.default_color,
        timestamp = options.timestamp or os.date('!%Y-%m-%dT%H:%M:%SZ'),
        footer = options.footer or {
            text = options.server_name or self.private.options.server_name,
            icon_url = options.server_icon or self.private.options.server_icon
        }
    })

    if options.fields then
        for _, field in ipairs(options.fields) do
            self:addField(embed, field.name, field.value, field.inline)
        end
    end

    return self:sendEmbed({ embed }, webhook, {
        username = options.username or self.private.options.username,
        avatar_url = options.avatar_url or self.private.options.avatar_url
    })
end

---Sends a player-specific log with player identifiers
---@param playerId string|number Player server ID
---@param action string Action description
---@param description string Detailed description
---@param webhook? string Override webhook URL
---@param options? DiscordOptions Additional options
---@return boolean success Whether the log was sent successfully
function lib.discord:sendPlayerLog(playerId, action, description, webhook, options)
    options = options or {}

    local playerName = GetPlayerName(playerId) or 'Unknown'
    local playerLicense = 'N/A'
    local playerDiscord = 'N/A'
    local playerSteam = 'N/A'

    for i = 0, GetNumPlayerIdentifiers(playerId) - 1 do
        local identifier = GetPlayerIdentifier(playerId, i)
        if identifier then
            if identifier:match('license:') then
                playerLicense = identifier
            elseif identifier:match('discord:') then
                playerDiscord = '<@' .. identifier:gsub('discord:', '') .. '>'
            elseif identifier:match('steam:') then
                playerSteam = identifier
            end
        end
    end

    local embed = self:createEmbed({
        title = action,
        description = description,
        color = options.color or self.private.options.default_color,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        footer = {
            text = options.server_name or self.private.options.server_name,
            icon_url = options.server_icon or self.private.options.server_icon
        }
    })

    self:addField(embed, 'Player', playerName, true)
    self:addField(embed, 'Server ID', playerId, true)
    self:addField(embed, 'License', playerLicense, false)
    self:addField(embed, 'Discord', playerDiscord, true)
    self:addField(embed, 'Steam', playerSteam, true)

    if options.fields then
        for _, field in ipairs(options.fields) do
            self:addField(embed, field.name, field.value, field.inline)
        end
    end

    return self:sendEmbed({ embed }, webhook, {
        username = options.username or self.private.options.username,
        avatar_url = options.avatar_url or self.private.options.avatar_url
    })
end

---Sends a success log message (green color)
---@param title string Log title
---@param description string Log description
---@param webhook? string Override webhook URL
---@param options? DiscordOptions Additional options
---@return boolean success Whether the log was sent successfully
function lib.discord:sendSuccess(title, description, webhook, options)
    return self:sendLog(title, description, 'green', webhook, options)
end

---Sends an error log message (red color)
---@param title string Log title
---@param description string Log description
---@param webhook? string Override webhook URL
---@param options? DiscordOptions Additional options
---@return boolean success Whether the log was sent successfully
function lib.discord:sendError(title, description, webhook, options)
    return self:sendLog(title, description, 'red', webhook, options)
end

---Sends a warning log message (yellow color)
---@param title string Log title
---@param description string Log description
---@param webhook? string Override webhook URL
---@param options? DiscordOptions Additional options
---@return boolean success Whether the log was sent successfully
function lib.discord:sendWarning(title, description, webhook, options)
    return self:sendLog(title, description, 'yellow', webhook, options)
end

---Sends an info log message (blue color)
---@param title string Log title
---@param description string Log description
---@param webhook? string Override webhook URL
---@param options? DiscordOptions Additional options
---@return boolean success Whether the log was sent successfully
function lib.discord:sendInfo(title, description, webhook, options)
    return self:sendLog(title, description, 'blue', webhook, options)
end

---Returns the available color definitions
---@return table<string, number> colors Color name to decimal value mapping
function lib.discord:getColors()
    return self.private.colors
end

---Gets the current default webhook URL
---@return string webhook Default webhook URL
function lib.discord:getWebhook()
    return self.private.webhook
end

---Sets a new default webhook URL
---@param webhook string New webhook URL
---@return boolean success Whether webhook was set successfully
function lib.discord:setWebhook(webhook)
    if self.private.options.validate_webhooks then
        local isValid, error = validateWebhook(webhook)
        if not isValid then
            print('^1[ox_lib] Discord Error: ' .. error .. '^0')
            return false
        end
    end

    self.private.webhook = webhook
    return true
end

---Gets current instance options
---@return DiscordInstanceOptions options Current instance options
function lib.discord:getOptions()
    return table.clone(self.private.options)
end

---Updates instance options
---@param options DiscordInstanceOptions New options to merge
function lib.discord:setOptions(options)
    for key, value in pairs(options) do
        if self.private.options[key] ~= nil then
            self.private.options[key] = value
        end
    end
end

---Formats text as code block with optional syntax highlighting
---@param text string|number Text to format
---@param language? string Programming language for syntax highlighting
---@return string formatted Formatted code block
function lib.discord:formatCode(text, language)
    language = language or ''
    return '```' .. language .. '\n' .. tostring(text) .. '\n```'
end

---Formats text as bold
---@param text string|number Text to format
---@return string formatted Bold formatted text
function lib.discord:formatBold(text)
    return '**' .. tostring(text) .. '**'
end

---Formats text as italic
---@param text string|number Text to format
---@return string formatted Italic formatted text
function lib.discord:formatItalic(text)
    return '*' .. tostring(text) .. '*'
end

---Formats text as underlined
---@param text string|number Text to format
---@return string formatted Underlined formatted text
function lib.discord:formatUnderline(text)
    return '__' .. tostring(text) .. '__'
end

---Formats text as strikethrough
---@param text string|number Text to format
---@return string formatted Strikethrough formatted text
function lib.discord:formatStrikethrough(text)
    return '~~' .. tostring(text) .. '~~'
end

---Formats text as spoiler (hidden until clicked)
---@param text string|number Text to format
---@return string formatted Spoiler formatted text
function lib.discord:formatSpoiler(text)
    return '||' .. tostring(text) .. '||'
end

---Formats text as quote
---@param text string|number Text to format
---@return string formatted Quote formatted text
function lib.discord:formatQuote(text)
    return '> ' .. tostring(text)
end

---Formats text as block quote
---@param text string|number Text to format
---@return string formatted Block quote formatted text
function lib.discord:formatBlockQuote(text)
    return '>>> ' .. tostring(text)
end

---Sends an admin action log with structured information
---@param admin string Admin name or identifier
---@param action string Action performed
---@param target string Target of the action
---@param reason? string Reason for the action
---@param webhook? string Override webhook URL
---@param options? DiscordOptions Additional options
---@return boolean success Whether the log was sent successfully
function lib.discord:sendAdminLog(admin, action, target, reason, webhook, options)
    options = options or {}

    local embed = self:createEmbed({
        title = 'Admin Action: ' .. action,
        description = reason or 'No reason provided',
        color = 'orange',
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        footer = {
            text = options.server_name or self.private.options.server_name,
            icon_url = options.server_icon or self.private.options.server_icon
        }
    })

    self:addField(embed, 'Admin', admin, true)
    self:addField(embed, 'Target', target, true)
    self:addField(embed, 'Action', action, true)

    if options.fields then
        for _, field in ipairs(options.fields) do
            self:addField(embed, field.name, field.value, field.inline)
        end
    end

    return self:sendEmbed({ embed }, webhook, {
        username = options.username or 'Admin System',
        avatar_url = options.avatar_url or self.private.options.avatar_url
    })
end

---Sends server status update with player count and status information
---@param status string Server status ('online', 'offline', 'restarting', 'maintenance')
---@param message? string Additional status message
---@param webhook? string Override webhook URL
---@param options? DiscordOptions Additional options
---@return boolean success Whether the status was sent successfully
function lib.discord:sendServerStatus(status, message, webhook, options)
    options = options or {}

    local colorMap = {
        online = 'green',
        offline = 'red',
        restarting = 'yellow',
        maintenance = 'orange'
    }

    local embed = self:createEmbed({
        title = 'Server Status: ' .. status:upper(),
        description = message or 'Server status update',
        color = colorMap[status:lower()] or 'grey',
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        footer = {
            text = options.server_name or self.private.options.server_name,
            icon_url = options.server_icon or self.private.options.server_icon
        }
    })

    if status:lower() == 'online' then
        self:addField(embed, 'Players Online', GetNumPlayerIndices(), true)
        self:addField(embed, 'Max Players', GetConvarInt('sv_maxclients', 32), true)
    end

    return self:sendEmbed({ embed }, webhook, {
        username = options.username or 'Server Monitor',
        avatar_url = options.avatar_url or self.private.options.avatar_url
    })
end
