-- name = "Birthdays"
-- name_id = "birthday"
-- description = "Shows upcoming birthdays from the contacts"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.2"

local prefs = require "prefs"
local fmt = require "fmt"

local months = {
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
}

function on_resume()
    if not prefs.count then
        prefs.count = 10
    end
    phone:request_permission()
end

function on_permission_granted()
    contacts = calendar:contacts_events()
    redraw()
end

function on_contacts_loaded()
    redraw()
end

function redraw()
    table.sort(contacts,function(a,b) return a.begin < b.begin end)
    events = {}
    local lines = {}
    local lines_exp = {}
    prev_begin = contacts[1].begin
    for i,v in ipairs(contacts) do
	    local fmt_out = fmt_line(v)
	    local insert = 0
	    if #lines == 0 then
	        insert = 1
	    elseif not (fmt_out == lines[#lines]) then
	        insert = 1
	    end
	    if insert == 1 then
	        if #lines_exp >= prefs.count and prev_begin ~= v.begin then
	            break
	        end
            table.insert(events, v)
            if #lines < prefs.count then
                table.insert(lines, fmt_out)
            end
            table.insert(lines_exp, fmt_out)
            prev_begin = v.begin
        end
    end
    if ui.set_expandable then
        if #lines_exp == #lines then
            ui:set_expandable(false)
        else
            ui:set_expandable(true)
        end
    end
    if ui.is_expanded and ui:is_expanded() then
        ui:show_lines(lines_exp)
    else
        ui:show_lines(lines)
    end
end

function fmt_line(event)
    local line = event.title
    if os.date("%y%m%d",event.begin) == os.date("%y%m%d") then
        line = fmt.bold(fmt.colored(line, aio:colors().accent))
    end
    return line .. fmt.secondary(" - ") .. fmt_date(event.begin)
end

function fmt_date(date)
    local d = ""
    if os.date("%y%m%d",date) == os.date("%y%m%d") then
        d = "Today"
    elseif os.date("%y%m%d",date-86400) == os.date("%y%m%d") then
        d = "Tomorrow"
    else
        d = months[tonumber(os.date("%m", date))] .. ", " .. tostring(tonumber(os.date("%d", date)))
    end
    return fmt.secondary(d)
end

function on_click(idx)
    calendar:show_event_dialog(events[idx])
end

function on_settings()
    ui:show_radio_dialog("Number of events", {1,2,3,4,5,6,7,8,9,10}, prefs.count)
end

function on_dialog_action(idx)
    if idx == -1 then
        return
    end
    prefs.count = idx
    redraw()
end
