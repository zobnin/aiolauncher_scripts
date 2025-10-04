-- name = "Solar Cycle"
-- description = "Shows Sunrise Sunset at your location"
-- data_source = "https://api.sunrise-sunset.org/"
-- type = "widget"
-- author = "Sriram S V, Will Hall"
-- version = "1.0"
-- foldable = "false"

local json = require "json"
local md_colors = require "md_colors"

function on_alarm()
    local location=system:location()
    url="https://api.sunrise-sunset.org/json?lat="..location[1].."&lng="..location[2].."&formatted=0"
    http:get(url)
end


function on_network_result(result)
    local t = json.decode(result)

    if not t.results then
        ui:show_text("Error: invalid data")
        return
    end

    local times_table = {
        {
            gen_icon("red_900","↦"),
            gen_icon("orange_900", "↗"),
            gen_icon("yellow_900", "☀"),
            gen_icon("orange_900", "↘"),
            gen_icon("red_900", "⇥"),
        },
        {
            time_from_utc(t.results.civil_twilight_begin),
            time_from_utc(t.results.sunrise),
            time_from_utc(t.results.solar_noon),
            time_from_utc(t.results.sunset),
            time_from_utc(t.results.civil_twilight_end),
        }
    }

    ui:show_table(times_table, 0, true)
end

function time_from_utc(utc)
    return utc_to_local(parse_iso8601_datetime(utc))
end

function gen_icon(md_color, icon)
    return "<font color="..md_colors[md_color].."><b>"..icon.."</b></font>"
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
