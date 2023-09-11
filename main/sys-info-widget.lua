-- name = "System info"
-- description = "Device information in real time"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_tick(ticks)
    if ticks % 10 ~= 0 then
        return
    end

    local info = system:system_info()
    local strings = stringify_table(info)

    ui:show_lines(strings)
end

function stringify_table(tab)
    local new_tab = {}

    for k,v in pairs(tab) do
        table.insert(new_tab, capitalize(k):replace("_", " ")..": "..tostring(v))
    end

    table.sort(new_tab)

    return new_tab
end

function capitalize(string)
    return string:gsub("^%l", string.upper)
end
