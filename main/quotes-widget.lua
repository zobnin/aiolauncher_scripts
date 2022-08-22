-- name = "Random quotes"
-- description = "quotable.io"
-- data_source = "quotable.io"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
-- foldable = "false"

function on_alarm()
    http:get("https://api.quotable.io/random")
end

function on_network_result(result)
    quote = ajson:get_value(result, "object string:content")
    author = ajson:get_value(result, "object string:author")

    ui:show_lines({ quote }, { author })
end

function on_click()
    if quote ~= nil then
        system:copy_to_clipboard(quote)
    end
end
