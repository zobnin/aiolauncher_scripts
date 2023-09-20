-- name = "Sunrise/Sunset"
-- description = "Shows Sunrise Sunset at your location"
-- data_source = "https://api.sunrise-sunset.org/"
-- type = "widget"
-- author = "Sriram S V"
-- version = "1.0"
-- foldable = "false"

local json = require "json"
local date = require "date"
local fmt = require "fmt"

function on_alarm()
    local location=system:location()
    local url="https://api.sunrise-sunset.org/json?lat="..location[1].."&lng="..location[2].."&date=today&formatted=1"

    http:get(url)
end


function on_network_result(result)
    local t = json.decode(result)

    local sunrise_time = date(t.results.sunrise):tolocal():fmt("%H:%M")
    local sunset_time = date(t.results.sunset):tolocal():fmt("%H:%M")

    ui:show_text(
        aio:res_string("today", "Today")..":"..
        fmt.space(4).."⬆"..fmt.space(2)..sunrise_time..
        fmt.space(4).."⬇"..fmt.space(2)..sunset_time
    )
end
