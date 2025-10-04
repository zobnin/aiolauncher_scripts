-- name = "Uptimerobot V2"
-- description = "Shows uptime information from uptimerobot.com. Needs API key. Button-based Version."
-- data_source = "uptimerobot.com"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com), Will Hall (hello@willhall.uk)"
-- version = "1.0"
-- arguments_help = "Enter your API key"

local json = require "json"
local md_colors = require "md_colors"

-- constants
local api_url = "https://api.uptimerobot.com/v2/"
local base_click_url = "https://uptimerobot.com/dashboard#"
local media_type = "application/x-www-form-urlencoded"
local status_colors = { "grey_500", "green_500", "red_500", "red_500", "red_500", "red_500", "red_500", "orange_500", "red_500" }

-- monitors
local monitor_ids = {}

function on_alarm()
    if (next(settings:get()) == nil) then
        ui:show_text("Tap to enter API key")
        return
    end

    local key = settings:get()[1]
    local body = "api_key="..key.."&format=json"

    http:post(api_url.."getMonitors", body, media_type)
end

function on_click(i)
    if (next(settings:get()) == nil) then
        settings:show_dialog()
    else
        if(monitor_ids[i] ~= nil) then
            system:open_browser(base_click_url..monitor_ids[i])
        else
            system:open_browser(base_click_url.."mainDashboard")
        end
    end
end

function on_network_result(result, code)
    if (code >= 400) then
        ui:show_text("Error: "..code)
        return
    end

    local parsed = json.decode(result)

    if (parsed.stat ~= "ok") then
        if (parsed.stat) then
            ui:show_text("Error: "..parsed.error.message)
        else
            ui:show_text("Error: invalid data")
        end
        return
    end

    local names = {}
    local colours = {}

    for k,v in pairs(parsed.monitors) do
        monitor_ids[k] = v.id
        names[k] = v.friendly_name
        colours[k] = md_colors[status_colors[v.status]] or md_colors["grey_500"]
    end

    ui:show_buttons(names, colours)
end

function on_settings()
    settings:show_dialog()
end

