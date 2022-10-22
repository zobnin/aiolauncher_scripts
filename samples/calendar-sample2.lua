--[[
Keep in mind: there can be a delay of up to several minutes
between adding an event and its appearance
in the calendar and in the AIO widget.
--]]

cals = {}

function on_resume()
    local names = {}

    cals = slice(calendar:calendars(), 1, 10)

    for k,v in ipairs(cals) do
        names[k] = v.name
    end

    ui:show_lines(names)
end

function on_click(idx)
    local cal_id = cals[idx].id

    local success = calendar:add_event{
        calendar_id = cal_id,
        title = "test",
        description = "test",
        begin = os.time(),
        ["end"] = os.time() + 3600,
        allDay = false,
    }

    if success then
        ui:show_toast("Test event added")
    else
        ui:show_toast("Error")
    end
end
