-- name = "Android widgets sample (The Weather Channel)"
-- uses_app = "com.weather.Weather"

local prefs = require "prefs"

local curr_temp = ""
local w_bridge = nil

function on_resume()
    if not widgets:bound(prefs.wid) then
        setup_app_widget()
    end

    widgets:request_updates(prefs.wid)
end

function on_app_widget_updated(bridge)
    local tab = bridge:dump_table()

    current_temp = tab.relative_layout_1.relative_layout_2.text_1
    location = tab.relative_layout_1.relative_layout_2.text_2
    w_bridge = bridge

    if location ~= nil and current_temp ~= nil then
        ui:show_text(location..": "..current_temp)
    else
        ui:show_text("Empty")
    end
end

function on_app_widget_updated_alt(bridge)
    local strings = bridge:dump_strings().values

    location = strings[2]
    current_temp = strings[1]
    w_bridge = bridge

    if location ~= nil and current_temp ~= nil then
        ui:show_text(location..": "..current_temp)
    else
        ui:show_text("Empty")
    end
end

function on_click(idx)
    w_bridge:click(current_temp)
end

function setup_app_widget()
    local id = widgets:setup("com.weather.Weather/com.weather.Weather.widgets.WeatherWidgetProvider2x2")
    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_text("Can't add widget")
    end
end
