-- name = "Battery info"
-- description = "Simple battery info widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"

ticks = -1

function on_tick()
    -- Update one time per 10 seconds
    ticks = ticks + 1
    if ticks % 10 ~= 0 then
        return
    end

    ticks = 0

    local batt_info = system:battery_info()
    local batt_strings = stringify_table(batt_info)
    local folded_str = "Battery: "..batt_info.percent.."% | "..batt_info.temp.."° | "..batt_info.voltage.." mV"

    ui:show_lines(batt_strings, nil, folded_str)
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
