-- name = "HTTP headers test"
-- description = "Test http:get headers API"
-- author = "test"
-- type = "widget"
-- version = "1.0"

local TEST_ID = "headers_test"
local URL = "https://httpbin.org/get"

local function show_loading()
    ui:show_text("<b>HTTP headers test</b><br/>Requesting:<br/>" .. URL)
end

function on_resume()
    show_loading()
    http:set_headers({ "X-Test: AIO-Launcher" })
    http:get(URL, TEST_ID)
end

function on_click()
    on_resume()
end

function on_network_result_headers_test(body, code, headers)
    local ct   = (headers and headers["content-type"]) or "nil"
    local date = (headers and headers["date"]) or "nil"

    local lines = {}
    if headers then
        for k, v in pairs(headers) do
            table.insert(lines, k .. ": " .. v)
        end
        table.sort(lines)
    end

    local all_headers = #lines > 0 and table.concat(lines, "<br/>") or "no headers"

    local text = string.format(
        "<b>HTTP headers test</b><br/>" ..
        "URL: %s<br/>" ..
        "Code: <b>%d</b><br/>" ..
        "Content-Type: %s<br/>" ..
        "Date: %s<br/><br/>" ..
        "<b>All headers:</b><br/>%s",
        URL,
        code or -1,
        ct,
        date,
        all_headers
    )

    ui:show_text(text)
end

function on_network_error_headers_test(error)
    ui:show_text(
        "<b>HTTP headers test</b><br/>" ..
        "<font color='red'>Error:</font> " .. tostring(error)
    )
end

