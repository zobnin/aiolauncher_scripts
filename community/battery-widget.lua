-- name = "Battery info"

ticks = -1

function on_tick()
    -- Update one time per 10 seconds
    ticks = ticks + 1
    if ticks % 10 ~= 0 then
        return
    end

    ticks = 0

    local batt_info = system:get_battery_info()
    local batt_strings = stringify_table(batt_info)
    ui:show_lines(batt_strings)
end

function stringify_table(tab)
    local new_tab = {}

    for k,v in pairs(tab) do
        table.insert(new_tab, capitalize(k)..": "..tostring(v))
    end

    return new_tab
end

function capitalize(string)
    return string:gsub("^%l", string.upper)
end
