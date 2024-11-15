-- name = "Timed message"
-- description = "A message that is displayed at a specific time"
-- type = "widget"
-- foldable = "false"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

local prefs = require "prefs"

function on_load()
    prefs._dialog_order = "message,start_time,end_time"

    if not prefs.message then
        prefs.message = "Sample message"
    end

    if not prefs.start_time then
        prefs.start_time = "00:00"
    end

    if not prefs.end_time then
        prefs.end_time = "23:59"
    end
end

function on_resume()
    ui:show_text(prefs.message)
    hide_or_show()
end

function on_settings()
    prefs:show_dialog()
end

function hide_or_show()
    local start_time = convert_to_unix_time(prefs.start_time)
    local end_time = convert_to_unix_time(prefs.end_time)
    local current_time = os.time()

    if current_time > start_time and current_time < end_time then
        ui:show_widget()
    else
        ui:hide_widget()
    end
end

function convert_to_unix_time(time_str)
    local hour, minute = time_str:match("^(%d%d):(%d%d)$")
    hour, minute = tonumber(hour), tonumber(minute)

    local current_date = os.date("*t")

    current_date.hour = hour
    current_date.min = minute
    current_date.sec = 0

    return os.time(current_date)
end
