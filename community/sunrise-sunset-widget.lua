-- name = "Sunrise/Sunset"
-- description = "Shows Sunrise Sunset at your location"
-- data_source = "https://api.sunrise-sunset.org/"
-- type = "widget"
-- author = "Sriram S V"
-- version = "1.0"
-- foldable = "false"

local json = require "json"
local date = require "date"

l1 = {}
l2 = {}
function on_resume()
    l2=settings:get_kv()
    if next(l2) == nil then
        ui:show_text("Tap to request location")
    else
        get_sunrise_sunset(l2)
    end
end

function on_click()
    system:request_location()
    ui:show_text("Loading...")
end

function on_location_result(location)
    if location ~= nil then
        l1.lat = location[1]
        l1.long = location[2]
        settings:set_kv(l1)
        get_sunrise_sunset(l1)
    else
        ui:show_text("Error")
    end
end

function get_sunrise_sunset(location)
    if location~=nil then
        url="https://api.sunrise-sunset.org/json?lat="..location.lat.."&lng="..location.long.."&date=today&formatted=1"
        http:get(url)
    else 
        ui:show_text("Location Empty")
    end
end

function on_network_result(result)
    local t = json.decode(result)
    local table = {
             { "sunrise:", date(t.results.sunrise):tolocal():fmt("%r") },
             { "sunset:", date(t.results.sunset):tolocal():fmt("%r") },
         }
    ui:show_table(table, 2)
end