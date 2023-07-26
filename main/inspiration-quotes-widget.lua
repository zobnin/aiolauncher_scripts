-- name = "Inspiration quotes"
-- description = "ZenQuotes.io"
-- data_source = "https://zenquotes.io/"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "2.0"
-- foldable = "false"

local json = require "json"

function on_alarm()
    http:get("https://zenquotes.io/api/random")
end

function on_network_result(result, code)
    if code >= 200 and code < 299 then
        res = json.decode(result)
        ui:show_lines({ res[1].q }, { res[1].a })
    end
end

function on_click()
    if res ~= nil then
        system:to_clipboard(res[1].q.." - "..res[1].a)
    end
end

