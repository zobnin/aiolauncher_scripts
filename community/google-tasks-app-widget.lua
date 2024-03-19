-- name = "Google Tasks"
-- description = "AIO wrapper for the official Google Tasks app widget"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- aio_version = "4.1.99"
-- uses_app = "com.google.android.apps.tasks"

local prefs = require "prefs"
local fmt = require "fmt"

local max_mails = 1
local curr_tab = {}
local w_bridge = nil

function on_resume()
    if not widgets:bound(prefs.wid) then
        setup_app_widget()
    end

    widgets:request_updates(prefs.wid)
end

function on_app_widget_updated(bridge)
    local tab = bridge:dump_strings().values

    -- Bold list name
    tab[1] = fmt.bold(tab[1])

    -- Remove "A fresh start"
    table.remove(tab, #tab-1)

    curr_tab = deep_copy(tab)
    w_bridge = bridge

    -- Change "Anything to add?" string to "Add task"
    tab[#tab] = fmt.secondary("Add task")

    ui:show_lines(tab)
end

function on_click(idx)
    w_bridge:click(curr_tab[idx])
end

function setup_app_widget()
    local id = widgets:setup("com.google.android.apps.tasks/com.google.android.apps.tasks.features.widgetlarge.ListWidgetProvider")
    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_text("Can't add widget")
        return
    end
end

function deep_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deep_copy(orig_key)] = deep_copy(orig_value)
        end
        setmetatable(copy, deep_copy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

