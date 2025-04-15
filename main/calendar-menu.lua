-- name = "Calendar menu"
-- name_id = "calendar"
-- description = "Shows events from system calendar"
-- type = "drawer"
-- aio_version = "4.7.99"
-- author = "Evgeny Zobnin"
-- version = "1.1"

local fmt = require "fmt"

local have_permission = false
local events = {}
local calendars = {}

function on_drawer_open()
    events = calendar:events()
    calendars = calendar:calendars()

    if events == "permission_error" then
        calendar:request_permission()
        return
    end

    have_permission = true

    add_cal_colors(events, calendars)

    if #events == #drawer:items() then
        return
    end

    lines = map(function(it)
        local date = fmt.colored(format_date(it.begin), it.calendar_color)
        return date..fmt.space(4)..it.title
    end, events)

    drawer:show_ext_list(lines)
end

function add_cal_colors(events, cals)
    for i, event in ipairs(events) do
        for _, cal in ipairs(cals) do
            if event.calendar_id == cal.id then
                event.calendar_color = cal.color
                break
            end
        end
    end
end

function format_date(date)
    if system.format_date_localized then
        return system:format_date_localized("dd.MM", date)
    else
        return os.date("%d.%m", date)
    end
end

function on_click(idx)
    if not have_permission then return end

    calendar:show_event_dialog(events[idx].id)
end

function on_long_click(idx)
    if not have_permission then return end

    calendar:open_event(events[idx].id)
end

