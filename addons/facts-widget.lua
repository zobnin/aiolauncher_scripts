-- name = "Random facts"
-- description = "Radom useless facts"
-- data_source = "https://uselessfacts.jsph.pl/"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
-- foldable = "false"

function on_alarm()
    http:get("https://uselessfacts.jsph.pl/random.json?language=en")
end

function on_network_result(result)
    text = ajson:get_value(result, "object string:text")

    ui:show_lines{ text }
end

function on_click()
    if text ~= nil then
        system:copy_to_clipboard(text)
    end
end
