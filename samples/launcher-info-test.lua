-- name = "Launcher info test"
-- type = "widget"
-- version = "1.0"

local function show()
    local info = aio:launcher_info() or {}

    local lines = {
        "<b>Launcher info</b>",
        "package: " .. tostring(info.package),
        "version: " .. tostring(info.version),
        "code: " .. tostring(info.code),
        "build_type: " .. tostring(info.build_type),
        "beta: " .. tostring(info.beta),
        "",
        "Tap to refresh",
    }

    ui:show_text(table.concat(lines, "<br/>"))
end

function on_resume()
    show()
end

function on_click()
    show()
end

