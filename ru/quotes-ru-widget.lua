-- name = "Цитаты великих"
-- description = "Рандомные цитаты на русском языке."
-- data_source = "forismatic.com"
-- type = "widget"
-- lang = "ru"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_alarm()
    http:get("http://api.forismatic.com/api/1.0/?method=getQuote&format=json&lang=ru")
end

function on_network_result(result)
    quote = ajson:read(result, "object string:quoteText")
    author = ajson:read(result, "object string:quoteAuthor")

    ui:show_lines({ quote }, { author })
end

function on_click()
    if quote ~= nil then
        system:to_clipboard(quote)
    end
end
