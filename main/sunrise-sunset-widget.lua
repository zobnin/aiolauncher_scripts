-- name = "Sunrise/Sunset"
-- description = "Shows Sunrise Sunset at your location"
-- data_source = "https://api.sunrise-sunset.org/"
-- type = "widget"
-- author = "Sriram S V"
-- version = "1.1"
-- foldable = "false"

local json = require "json"
local fmt = require "fmt"

function on_alarm()
    local location = system:location()

    if location == nil then
        return
    elseif location == "permission_error" then
        ui:show_text("No location permission")
        return
    end

    local url = "https://api.sunrise-sunset.org/json?lat=" .. location[1] .. "&lng=" .. location[2] .. "&formatted=0"

    http:get(url)
end

function on_network_result(result, code)
    if code < 200 or code > 299 then
        ui:show_text("Network error: "..code)
        return
    end

    ok, t = pcall(json.decode, result)

    if not ok or type(t) ~= "table" then
        ui:show_text("Invalid data: "..result)
        return
    end

    if not t or not t.results or not t.results.sunrise or not t.results.sunset then
        ui:show_text("%%txt%% Got invalid data:\n"..serialize(t))
        return
    end

    local sunrise_time = utc_to_local(parse_iso8601_datetime(t.results.sunrise))
    local sunset_time = utc_to_local(parse_iso8601_datetime(t.results.sunset))

    ui:show_text(
        aio:res_string("today", "Today")..":"..
        fmt.space(4).."⬆"..fmt.space(2)..sunrise_time..
        fmt.space(4).."⬇"..fmt.space(2)..sunset_time
    )
end

function parse_iso8601_datetime(json_date)
    local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%+%-]?)(%d?%d?)%:?(%d?%d?)"
    local year, month, day, hour, minute,
        seconds, offsetsign, offsethour, offsetmin = json_date:match(pattern)
    local timestamp = os.time{year = year, month = month,
        day = day, hour = hour, min = minute, sec = seconds}
    local offset = 0
    if offsetsign ~= '' and offsetsign ~= 'Z' then
      offset = tonumber(offsethour) * 60 + tonumber(offsetmin)
      if xoffset == "-" then offset = offset * -1 end
    end

    return timestamp + offset * 60
end

function utc_to_local(utctime)
    local local_time_str = os.date("%H:%M", utctime)
    local utc_time_str = os.date("!%H:%M", utctime)

    local function time_to_seconds(timestr)
        local hour, minute = timestr:match("(%d+):(%d+)")
        return tonumber(hour) * 3600 + tonumber(minute) * 60
    end

    local local_seconds = time_to_seconds(local_time_str)
    local utc_seconds = time_to_seconds(utc_time_str)
    local delta = local_seconds - utc_seconds

    return os.date("%H:%M", utctime + delta)
end
