-- name = "Цитаты великих"
-- description = "Рандомные цитаты на русском (forismatic.com)"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_alarm()
    net:get_text("http://api.forismatic.com/api/1.0/?method=getQuote&format=json&lang=ru")
end

function on_network_result(result)
    local quote = ajson:get_value(result, "object string:quoteText")
    local author = ajson:get_value(result, "object string:quoteAuthor")

    ui:show_lines({ quote }, { author })
end
