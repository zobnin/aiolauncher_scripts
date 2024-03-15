-- name = "Android widgets sample (Google Tasks)"

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

    curr_tab = tab
    w_bridge = bridge

    ui:show_lines(tab)
end

function on_click(idx)
    --w_bridge:click(curr_tab[idx])
    w_bridge:click("text_2")
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
