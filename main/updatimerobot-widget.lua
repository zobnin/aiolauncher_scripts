-- name = "Uptimerobot"
-- description = "Shows uptime information from uptimerobot.com. Needs api key."
-- data_source = "https://uptimerobot.com"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)
-- version = "1.0"
-- arguments_help = "Enter your API key"

local json = require "json"
local md_colors = require "md_colors"

-- constants
local api_url = "https://api.uptimerobot.com/v2/"
local media_type = "application/x-www-form-urlencoded"

function on_alarm()
    if (next(aio:get_args()) == nil) then
        ui:show_text("Enter API key in the settings")
        return
    end

    local key = aio:get_args()[1]
	local body = "api_key="..key.."&format=json"

	http:post(api_url.."getMonitors", body, media_type)
end

function on_network_result(result)
	local parsed = json.decode(result)

    if (parsed.stat ~= "ok") then
        ui:show_text("Error: "..parsed.error.message)
        return
    end

    local strings_tab = {}
    
    for k,v in ipairs(parsed.monitors) do
        strings_tab[k] = v.friendly_name..": "..format_status(v.status)
    end

    ui:show_lines(strings_tab)
end

-- utils

function format_status(status)
    local statuses = { "down", "up" }
    local status_colors = { "red_500", "green_500" }

    return "<font color=\""..md_colors[status_colors[status]].."\">"..statuses[status].."</font>"
end

