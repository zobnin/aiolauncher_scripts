-- name = "Android widgets sample (Gmail)"

local prefs = require "prefs"

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

    -- Removing redunant elements like widget title
    tab = skip(tab, 4)

    -- Each mail consists of 4 text elements:
    -- 1. from, 2. time, 3. subject, 4. text
    tab = take(tab, max_mails * 4)

    -- Concatenate "from" and "time"
    tab = concat(tab, {1, 2}, ", ")

    curr_tab = tab
    w_bridge = bridge

    ui:show_lines(tab)
end

function on_click(idx)
    w_bridge:click(curr_tab[idx])
end

function setup_app_widget()
    local id = widgets:setup("com.google.android.gm/com.google.android.gm.widget.GmailWidgetProvider")
    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_text("Can't add widget")
        return
    end
end

-- Utils

function concat(tbl, indicesToConcatenate, delimiter)
    local resultTable = {}

    if #indicesToConcatenate > 0 then
        local concatenatedString = {}
        for _, index in ipairs(indicesToConcatenate) do
            table.insert(concatenatedString, tbl[index])
        end
        table.insert(resultTable, table.concat(concatenatedString, delimiter))
    end

    for i = 1, #tbl do
        if not contains(indicesToConcatenate, i) then
            table.insert(resultTable, tbl[i])
        end
    end
    return resultTable
end
