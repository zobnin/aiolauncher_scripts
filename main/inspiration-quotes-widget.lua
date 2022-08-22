-- name = "Inspiration quotes"
-- description = "inspiration.goprogram.ai"
-- data_source = "inspiration.goprogram.ai"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
-- foldable = "false"

function on_alarm()
    http:get("https://inspiration.goprogram.ai/")
end

function on_network_result(result)
    quote = ajson:get_value(result, "object string:quote")
    author = ajson:get_value(result, "object string:author")

    ui:show_lines({ quote }, { author })
end

function on_click()
    if quote ~= nil then
        system:copy_to_clipboard(quote)
    end
end
