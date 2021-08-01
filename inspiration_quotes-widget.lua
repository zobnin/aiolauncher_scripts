-- name = "Inspiration quotes"
-- description = "inspiration.goprogram.ai"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_alarm()
    net:get_text("https://inspiration.goprogram.ai/")
end

function on_network_result(result)
    local quote = ajson:get_value(result, "object string:quote")
    local author = ajson:get_value(result, "object string:author")

    ui:show_lines({ quote }, { author })
end
