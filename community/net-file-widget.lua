-- name = "Network file"
-- description = "Shows the contents of any file on the Internet"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.2"
-- aio_version = "5.5.2"

prefs = require "prefs"

function on_resume()
    prefs._dialog_order = "url,headers"
    prefs.url = prefs.url or ""
    prefs.headers = prefs.headers or ""
    
    if not prefs.url or prefs.url == "" then
        ui:show_text("Tap to enter file URL and optional headers")
        return
    end

    -- Set headers if provided
    if prefs.headers and prefs.headers ~= "" then
        local headers = {}
        for header in string.gmatch(prefs.headers, "[^\n]+") do
            local trimmed = header:match("^%s*(.-)%s*$")
            if trimmed ~= "" then
                table.insert(headers, trimmed)
            end
        end
        if #headers > 0 then
            http:set_headers(headers)
        end
    end

    http:get(prefs.url)
end

function on_click()
    prefs:show_dialog()
end

function on_network_result(result, code)
    ui:show_text(result)
end

function on_settings()
    prefs:show_dialog()
end


