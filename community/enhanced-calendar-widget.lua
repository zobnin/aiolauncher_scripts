-- name = "Enhanced Calendar"
-- description = "Monthly calendar with system calendar events"
-- type = "widget"
-- author = "Evon Smith with code from Andrey Gavrilov's Calendar widget"
-- version = "1.4"

local tab = {}
local line = " "
local selected_day = nil
local selected_day_events = {}
local display_mode = "calendar" -- "calendar" or "events"

local year = os.date("%Y"):gsub("^0","")
local month = os.date("%m"):gsub("^0","")
local day = os.date("%d"):gsub("^0","")

-- Initialize preferences module for settings
prefs = require "prefs"

function on_resume()
    if calendar:events(0,0) == "permission_error" then
        ui:show_text("<font size=\"18\">Click to grant calendar permission</font>")
        return
    end
    
    -- Initialize calendar selection if not set
    if not prefs.selected_calendars then
        local all_cals = get_all_cals()
        prefs.selected_calendars = all_cals[2] -- Select all calendars by default
    end
    
    -- Always show today's events initially
    if not selected_day then
        selected_day = day
    end
    
    if display_mode == "calendar" then
        show_calendar()
    else
        show_events_list()
    end
end

function show_calendar()
    tab = get_cal(year,month)
    line = get_line()
    
    ui:show_table(table_to_tables(tab,8),0, true, line)
    ui:set_title(ui:default_title().." ("..get_date(month,year)..")" .. (selected_day and (" - Day "..selected_day) or ""))
    display_mode = "calendar"
end

function show_events_list()
    if not selected_day then
        show_calendar()
        return
    end
    
    selected_day_events = get_my_events(year,month,selected_day)
    local color = aio:colors()
    local lines = {}
    
    -- Header
    table.insert(lines, "<font size=\"16\"><b>Events for Day " .. selected_day .. "</b></font>")
    
    if #selected_day_events == 0 then
        table.insert(lines, "<font size=\"14\" color=\""..color.secondary_text.."\">No events on this day</font>")
    else
        -- Add events
        for i, event in ipairs(selected_day_events) do
            local time_str = ""
            if event.all_day then
                time_str = "All day"
            else
                time_str = os.date("%H:%M", event.begin) .. " - " .. os.date("%H:%M", event["end"])
            end
            
            -- Get calendar color
            local cal_color = event.calendar_color or color.primary_text
            
            -- Event with title and time on separate lines
            table.insert(lines, "<font size=\"14\"><font color=\""..cal_color.."\">●</font> " .. (event.title or "Untitled") .. "</font>")
            table.insert(lines, "<font size=\"12\" color=\""..color.secondary_text.."\">" .. time_str .. "</font>")
        end
    end
    
    -- Navigation options
    table.insert(lines, "")
    table.insert(lines, "<font size=\"14\" color=\""..color.accent.."\"><b>← Back to Calendar</b></font>")
    table.insert(lines, "<font size=\"14\" color=\""..color.accent.."\"><b>Select Different Day</b></font>")
    
    ui:show_lines(lines) -- Remove the second parameter to enable HTML formatting
    ui:set_title(ui:default_title() .. " - Day " .. selected_day .. " Events")
    display_mode = "events"
end

function on_settings()
    local all_cals = get_all_cals()
    dialogs:show_checkbox_dialog("Select Calendars to Display", all_cals[3], cal_id_to_id(prefs.selected_calendars or {}))
end

function on_click(i)
    if display_mode == "calendar" then
        -- Calendar mode clicks
        if i == 1 then
            -- Previous month
            system:vibrate(10)
            local time = os.time{year=year,month=month,day=1}-24*60*60
            year,month = os.date("%Y-%m",time):match("(%d+)-(%d+)")
            year,month = year:gsub("^0",""),month:gsub("^0","")
            selected_day = nil
            on_resume()
        elseif i == 8 then
            -- Next month
            system:vibrate(10)
            local time = os.time{year=year,month=month,day=1}+31*24*60*60
            year,month = os.date("%Y-%m",time):match("(%d+)-(%d+)")
            year,month = year:gsub("^0",""),month:gsub("^0","")
            selected_day = nil
            on_resume()
        elseif i > 1 and i < 8 then
            -- Month/year header clicked
            dialogs:show_edit_dialog("Enter month and year", "Format - 12.2020. Empty value - current month", string.format("%02d.%04d", month, year))
            return
        elseif (i-1)%8 ~= 0 and i <= #tab then
            -- Clicked on a day
            local clicked_day = tab[i] and tab[i]:match(">(%d+)<")
            if clicked_day then
                clicked_day = clicked_day:gsub("^0","")
                selected_day = clicked_day
                system:vibrate(10)
                show_events_list()
            end
        end
    elseif display_mode == "events" then
        -- Events mode clicks
        local total_events = #selected_day_events
        local event_lines = total_events * 2 -- Each event has title and time lines
        local back_button_index = 2 + event_lines + 1 -- header + events + spacer + back
        local select_day_index = back_button_index + 1
        
        if i > 1 and i <= 1 + event_lines then
            -- Clicked on an event (check if it's a title line, not a time line)
            local event_line_index = i - 1
            if event_line_index % 2 == 1 then -- Title lines are at odd positions (1, 3, 5...)
                local event_index = math.ceil(event_line_index / 2)
                if selected_day_events[event_index] then
                    calendar:open_event(selected_day_events[event_index])
                end
            end
        elseif i == back_button_index then
            -- Back to calendar
            system:vibrate(10)
            show_calendar()
        elseif i == select_day_index then
            -- Select different day
            system:vibrate(10)
            show_calendar()
        end
    end
end

function on_long_click(i)
    if display_mode == "calendar" then
        -- Long click in calendar area
        if (i-1)%8 ~= 0 and i > 8 and i <= #tab and tab[i] ~= " " then
            local clicked_day = tab[i]:match(">(%d+)<")
            if clicked_day then
                clicked_day = clicked_day:gsub("^0","")
                -- Long press on day - open calendar to add new event
                local event_start = os.time{year=year, month=month, day=clicked_day, hour=12, min=0, sec=0}
                local event_end = event_start + 3600 -- 1 hour duration
                calendar:open_new_event(event_start, event_end)
            end
        end
    elseif display_mode == "events" then
        -- Long click in events area - show event dialog
        local total_events = #selected_day_events
        local event_lines = total_events * 2
        if i > 1 and i <= 1 + event_lines then
            local event_line_index = i - 1
            if event_line_index % 2 == 1 then -- Title lines are at odd positions
                local event_index = math.ceil(event_line_index / 2)
                if selected_day_events[event_index] and selected_day_events[event_index].id then
                    calendar:show_event_dialog(selected_day_events[event_index].id)
                end
            end
        end
    end
end

function on_permission_granted()
    on_resume()
end

function on_dialog_action(data)
    if data == -1 then
        return
    end
    
    -- Check if it's a date dialog
    if type(data) == "string" then
        -- Date dialog
        if data == "" then
            local date = os.date("*t")
            local y,m = os.date("%Y-%m"):match("(%d+)-(%d+)")
            y,m = y:gsub("^0",""),m:gsub("^0","")
            if y==year and m==month then
                return
            end
            year,month = y,m
            selected_day = nil
            on_resume()
            return
        elseif not check_date(data) then
            ui:show_toast("Invalid date format")
            return
        end
        month,year = data:match("(%d+)%.(%d+)")
        month,year = month:gsub("^0",""),year:gsub("^0","")
        selected_day = nil
        on_resume()
    else
        -- Settings dialog (checkbox result)
        prefs.selected_calendars = id_to_cal_id(data)
        selected_day = nil
        on_resume()
    end
end

function get_cal(y,m)
    local color = aio:colors()
    local events = get_my_events(y,m,0)
    local from = os.time{year=y,month=m,day=1}
    local tab = {
                "<font size=\"16\"><b>◄◄</b> <font color=\""..color.secondary_text.."\">#</font></font>",
                "<font size=\"16\" color=\""..color.secondary_text.."\">Mo</font>",
                "<font size=\"16\" color=\""..color.secondary_text.."\">Tu</font>",
                "<font size=\"16\" color=\""..color.secondary_text.."\">We</font>",
                "<font size=\"16\" color=\""..color.secondary_text.."\">Th</font>",
                "<font size=\"16\" color=\""..color.secondary_text.."\">Fr</font>",
                "<font size=\"16\" color=\""..color.secondary_text.."\">Sa</font>",
                "<font size=\"16\" color=\""..color.secondary_text.."\">Su</font> <b>►►</b></font>"
                }
    table.insert(tab,"<font size=\"14\" color=\""..color.secondary_text.."\">"..os.date("%W",from).."</font>")
    for i = 1, os.date("%w",from):gsub("0","7")-1 do
        table.insert(tab," ")
    end
    local to = os.time{year=y,month=m,day=1}+31*24*60*60
    local yy,mm = os.date("%Y-%m",to):match("(%d+)-(%d+)")
    yy,mm = yy:gsub("^0",""),mm:gsub("^0","")
    to = os.time{year=yy,month=mm,day=1}-24*60*60
    for time = from,to,24*60*60 do
        local d = os.date("%d",time):gsub("^0","")
        table.insert(tab, format_day(y,m,d,events))
        if os.date("%w",time):gsub("0","7")=="7" and time ~= to then
            table.insert(tab, "<font size=\"14\" color=\""..color.secondary_text.."\">"..os.date("%W",time+24*60*60).."</font>")
        end
    end
    for i = os.date("%w",to):gsub("0","7")+1,7 do
        table.insert(tab," ")
    end
    return tab
end

function format_day(y,m,d,events)
    local color = aio:colors()
    local from = os.time{year=y,month=m,day=d,hour=0,min=0,sec=0}
    local to = os.time{year=y,month=m,day=d,hour=23,min=59,sec=59}
    local yes = false
    for i=1,#events do
        local v = events[i]
        if v.begin >= from and v["end"] <= to then
            yes = true
            break
        end
    end
    local dd = d
    if yes then
        dd = "<b>"..dd.."</b>"
    end
    
    -- Highlight selected day with background color
    if selected_day and d == selected_day then
        dd = "<u><b>"..dd.."</b></u>"
    end
    
    if year == os.date("%Y"):gsub("^0","") and month == os.date("%m"):gsub("^0","") and d == os.date("%d"):gsub("^0","") then
        dd = "<font size=\"17\" color=\""..color.progress_good.."\">"..dd.."</font>"
    elseif calendar.is_holiday and calendar:is_holiday(os.time{year=y,month=m,day=d}) then
        dd = "<font size=\"17\" color=\""..color.progress_bad.."\">"..dd.."</font>"
    else
        dd = "<font size=\"17\" color=\""..color.primary_text.."\">"..dd.."</font>"
    end
    return dd
end

function check_date(date)
    local m, Y = date:match("(%d+).(%d+)")
    if not m or not Y then return false end
    m, Y = tonumber(m), tonumber(Y)
    if not m or not Y or m < 1 or m > 12 or Y < 1970 or Y > 2099 then
        return false
    end
    return true
end

function table_to_tables(tab, num)
    local out_tab = {}
    local row = {}
    for k,v in ipairs(tab) do
        table.insert(row, v)
        if k % num == 0 then
            table.insert(out_tab, row)
            row = {}
        end
    end
    -- Handle remaining items in incomplete row
    if #row > 0 then
        while #row < num do
            table.insert(row, " ")
        end
        table.insert(out_tab, row)
    end
    return out_tab
end

function get_date(m,y)
    local time = os.time{year=y,month=m,day=1}
    return os.date("%B",time).." "..string.format("%04d", y)
end

function get_my_events(y,m,d)
    local tab = {}
    local from = os.time{year=y,month=m,day=1,hour=0,min=0,sec=0}
    local to = os.date("*t",from + 31*24*60*60)
    to = os.time{year=to.year,month=to.month,day=1,hour=0,min=0,sec=0}-1
    if d ~= 0 then
        from =os.time{year=y,month=m,day=d,hour=0,min=0,sec=0}
        to = os.time{year=y,month=m,day=d,hour=23,min=59,sec=59}
    end
    local events = {}
    if prefs.selected_calendars and next(prefs.selected_calendars) then
        events = calendar:events(from,to,prefs.selected_calendars)
    end
    for i=1,#events do
        local v = events[i]
        if v.begin >= from and v["end"] <= to then
            v["calendar_name"],v["calendar_color"]=get_my_calendar(v.calendar_id)
            table.insert(tab,v)
        end
        if v.begin > to then
            break
        end
    end
    return tab
end

function get_line()
    local line = ""
    local date = os.date("*t")
    local from = os.time{year=date.year,month=date.month,day=date.day,hour=0,min=0,sec=0}
    local to = os.time{year=date.year,month=date.month,day=date.day,hour=23,min=59,sec=59}
    local events = {}
    if prefs.selected_calendars and next(prefs.selected_calendars) then
        events = calendar:events(from,to,prefs.selected_calendars)
    end
    if next(events) == nil then
        line = "No events today"
    else
        line = "There are events today"
    end
    return line
end

function get_my_calendar(id)
    local cals = calendar:calendars()
    for i=1,#cals do
        local v = cals[i]
        if id == v.id then
            return v.name,v.color
        end
    end
    return "Unknown Calendar", "#999999"
end

function get_all_cals()
    local cals = calendar:calendars()
    local idx = {}
    local id = {}
    local name = {}
    local color = {}
    for i,v in ipairs(cals) do
        table.insert(idx,i)
        table.insert(id,v.id)
        table.insert(name,v.name)
        table.insert(color,v.color)
    end
    return {idx,id,name,color}
end

function id_to_cal_id(ids)
    local cals = calendar:calendars()
    local tab = {}
    for i,v in ipairs(ids) do
        if cals[v] then
            table.insert(tab,cals[v].id)
        end
    end
    return tab
end

function cal_id_to_id(cal_ids)
    if not cal_ids then return {} end
    local cals = calendar:calendars()
    local tab = {}
    for i,v in ipairs(cal_ids) do
        for ii,vv in ipairs(cals) do
            if tonumber(v) == tonumber(vv.id) then
                table.insert(tab,ii)
            end
        end
    end
    return tab
end