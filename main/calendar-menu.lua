-- name = "Calendar menu"
-- name_id = "calendar"
-- description = "Shows events from system calendar"
-- type = "drawer"
-- aio_version = "4.7.99"
-- author = "Evgeny Zobnin"
-- version = "1.0"

local fmt = require "fmt"

local have_permission = false
local events = {}

function on_drawer_open()
    events = calendar:events()

    if events == "permission_error" then
        calendar:request_permission()
        return
    end

    have_permission = true

    if #events == #drawer:items() then
        return
    end

    lines = map(events, function(it)
        local date = fmt.colored(format_date(it.begin), it.color)
        return date..fmt.space(4)..it.title
    end)

    drawer:show_ext_list(lines)
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

function map(tbl, f)
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = f(v)
    end
    return ret
end

