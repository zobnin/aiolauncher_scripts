-- name = "Network file"
-- description = "Shows the contents of any file on the Internet"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.1"
-- aio_version = "5.5.2"

prefs = require "prefs"

function on_resume()
    if not prefs.url or prefs.url == "" then
        ui:show_text("Tap to enter file URL and optional headers")
        return
    end

    -- Set headers if provided
    if prefs.headers and prefs.headers ~= "" then
        local headers = {}
        -- Split by newlines, pipes, semicolons, or commas
        for header in string.gmatch(prefs.headers, "[^
|,;]+") do
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
    prefs:show_dialog{
        url = {
            title = "File URL",
            text = "Enter the URL of the file to fetch",
            value = prefs.url or "",
        },
        headers = {
            title = "Custom HTTP headers (optional)",
            text = "One per line, e.g.\nAuthorization: Bearer TOKEN",
            value = prefs.headers or "",
            multiline = true,
        }
    }
end

function on_network_result(result, code)
    if code and code ~= 200 then
        ui:show_text("Error: "..(code or "").."\n"..(result or ""))
    else
        ui:show_text(result)
    end
end

function on_settings()
    on_click()
end
