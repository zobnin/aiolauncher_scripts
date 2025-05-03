-- name = "Random facts"
-- description = "Random useless facts"
-- data_source = "https://uselessfacts.jsph.pl/"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
-- foldable = "false"

function on_alarm()
    http:get("https://uselessfacts.jsph.pl/random.json?language=en")
end

function on_network_result(result, code)
    if code >= 200 and code < 299 then
        text = ajson:read(result, "object string:text")
        ui:show_lines{ text }
    end
end

function on_click()
    if text ~= nil then
        system:to_clipboard(text)
    end
end
