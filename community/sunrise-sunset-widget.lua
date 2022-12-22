-- name = "Sunrise/Sunset"
-- description = "Shows Sunrise Sunset at your location"
-- data_source = "https://api.sunrise-sunset.org/"
-- type = "widget"
-- author = "Sriram S V"
-- version = "1.0"
-- foldable = "false"

local json = require "json"
local date = require "date"
function on_alarm()
    local location=system:location()
    url="https://api.sunrise-sunset.org/json?lat="..location[1].."&lng="..location[2].."&date=today&formatted=1"
    http:get(url)
end


function on_network_result(result)
    local t = json.decode(result)
    local table = {
             { "sunrise:", date(t.results.sunrise):tolocal():fmt("%r") },
             { "sunset:", date(t.results.sunset):tolocal():fmt("%r") },
         }
    ui:show_table(table, 2)
end