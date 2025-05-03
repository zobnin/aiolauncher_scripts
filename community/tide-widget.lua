-- name = "Tide Time"
-- description = "Widget shows high and low tide times for today."
-- data_source = "https://open-meteo.com/en/docs/marine-weather-api"
-- type = "widget"
-- author = "AI Assistant"
-- version = "1.0"

local json = require "json"
local color = require "md_colors"
local text_color = aio:colors().secondary_text

-- variables
local tide_data = nil
local tide_times = {}

function on_alarm()
    get_tide_data()
end

function get_tide_data()
    local today = os.date("%Y-%m-%d")
    local location = system:location()
    local url = string.format(
        "https://marine-api.open-meteo.com/v1/marine?latitude=%f&longitude=%f&hourly=sea_level_height_msl&timezone=auto&start_date=%s&end_date=%s",
        location[1], location[2], today, today
    )
    http:get(url)
end

function on_network_result(result)
    local data = json.decode(result)
    if not data or not data.hourly then
        ui:show_toast("Error getting data: " .. (result or "no response"))
        return
    end

    tide_data = data
    process_tide_data()
    display_tide_times()
end

function process_tide_data()
    tide_times = {}
    local times = tide_data.hourly.time
    local heights = tide_data.hourly.sea_level_height_msl
    
    if not times or not heights then
        ui:show_text("Invalid data format")
        return
    end
    
    -- Find local maxima and minima
    for i = 2, #heights - 1 do
        if heights[i] > heights[i-1] and heights[i] > heights[i+1] then
            table.insert(tide_times, {
                time = times[i],
                height = heights[i],
                type = "high tide"
            })
        elseif heights[i] < heights[i-1] and heights[i] < heights[i+1] then
            table.insert(tide_times, {
                time = times[i],
                height = heights[i],
                type = "low tide"
            })
        end
    end
end

function display_tide_times()
    if #tide_times == 0 then
        ui:show_text("No tide data available")
        return
    end

    local tab = {}
    for _, tide in ipairs(tide_times) do
        local time = tide.time:match("T(%d+:%d+)")
        local height = string.format("%.2f", tide.height)
        local type = tide.type
        local color = type == "high tide" and color.blue_500 or color.blue_900
        
        table.insert(tab, {
            string.format("<font color=\"%s\">%s</font>", color, type),
            time,
            height .. " m"
        })
    end
    
    ui:show_table(tab, 3)
    ui:set_title(ui:default_title() .. " (" .. os.date("%d.%m.%Y") .. ")")
end

function on_long_click(idx)
    ui:show_context_menu({
        {"redo", "Refresh"},
        {"copy", "Copy data"}
    })
end

function on_context_menu_click(menu_idx)
    if menu_idx == 1 then
        get_tide_data()
        ui:show_toast("Updating data...")
    elseif menu_idx == 2 then
        local text = "Tide times for " .. os.date("%d.%m.%Y") .. ":\n"
        for _, tide in ipairs(tide_times) do
            local time = tide.time:match("T(%d+:%d+)")
            text = text .. string.format("%s: %s (%.2f m)\n", tide.type, time, tide.height)
        end
        system:copy_to_clipboard(text)
        ui:show_toast("Data copied")
    end
end 