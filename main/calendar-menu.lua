-- name = "Calendar menu"
-- name_id = "calendar"
-- description = "Shows events from system calendar"
-- type = "drawer"
-- aio_version = "4.7.99"
-- author = "Evgeny Zobnin"
-- version = "1.0"

local fmt = require "fmt"

local events = {}

function on_drawer_open()
    events = calendar:events()

    lines = map(events, function(it)
        local date = fmt.colored(os.date("%d.%m", it.begin), it.color)
        return date..fmt.space(4)..it.title
    end)

    drawer:show_ext_list(lines)
end

function on_click(idx)
    calendar:show_event_dialog(events[idx].id)
end

function on_long_click(idx)
    calendar:open_event(events[idx].id)
end

function map(tbl, f)
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = f(v)
    end
    return ret
end

