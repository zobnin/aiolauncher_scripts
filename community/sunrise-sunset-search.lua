-- name = "Sun Info"
-- description = "Shows Sunrise Sunset at your location"
-- data_source = "https://api.sunrise-sunset.org/"
-- type = "search"
-- author = "Sriram S V"
-- version = "1.0"
-- prefix = "sun"
-- foldable = "false"

local json = require "json"
local date = require "date"
md_colors = require("md_colors")

function on_search(input)
    local location=system:location()
    get_sun_info(location)
end

function on_network_result(result)
    local t = json.decode(result)
    local sunrise = date(t.results.sunrise):tolocal():fmt("%r")
    local sunset = date(t.results.sunset):tolocal():fmt("%r")

    local lines = {"Sunrise: "..sunrise, "Sunset: "..sunset}
    local colors = { md_colors.orange_400, md_colors.orange_800 }
    search:show_lines(lines,colors)
end

function get_sun_info(location)
    url="https://api.sunrise-sunset.org/json?lat="..location[1].."&lng="..location[2].."&date=today&formatted=1"
    http:get(url)
end