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
        ok, res = pcall(json.decode, result)

        if not ok or type(res) ~= "table" then
            ui:show_text("Invalid data: "..result)
            return
        end

        if res and res[1] and res[1].q and res[1].a then
            ui:show_lines({ res[1].q }, { res[1].a })
        else
            ui:show_text("%%txt%% Got incorrect data:\n"..serialize(res))
        end
    end
end

function on_click()
    if res ~= nil then
        system:to_clipboard(res[1].q.." - "..res[1].a)
    end
end

