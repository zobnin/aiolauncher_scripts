-- name = "Random quotes"
-- description = "quotable.io"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_alarm()
    net:get_text("https://api.quotable.io/random")
end

function on_network_result(result)
    local quote = ajson:get_value(result, "object string:content")
    local author = ajson:get_value(result, "object string:author")

    ui:show_lines({ quote }, { author })
end
