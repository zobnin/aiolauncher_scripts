-- name = "Network state test"
-- description = "Test system:network_state()"
-- type = "widget"
-- version = "1.0"

local function bool_to_str(b)
    return b and "true" or "false"
end

local function show_state()
    local s = system:network_state() or {}

    local connected = s.connected
    local type_     = s.type or "none"
    local class     = s.class or ""
    local ssid      = s.ssid or ""
    local operator  = s.operator or ""
    local metered   = s.metered
    local roaming   = s.roaming

    local lines = {}

    table.insert(lines, "<b>Network state test</b>")
    table.insert(lines, "connected: " .. bool_to_str(connected))
    table.insert(lines, "type: " .. type_)
    table.insert(lines, "class: " .. class)

    if ssid ~= "" then
        table.insert(lines, "ssid: " .. ssid)
    end

    if operator ~= "" then
        table.insert(lines, "operator: " .. operator)
    end

    table.insert(lines, "metered: " .. bool_to_str(metered))
    table.insert(lines, "roaming: " .. bool_to_str(roaming))
    table.insert(lines, "")
    table.insert(lines, "Tap to refresh")

    ui:show_text(table.concat(lines, "<br/>"))
end

function on_resume()
    show_state()
end

function on_click()
    show_state()
end

