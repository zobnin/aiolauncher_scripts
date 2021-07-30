-- name = "Цитаты великих"
-- description = "Рандомные цитаты на русском (forismatic.com)"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function onAlarm()
    net:getText("http://api.forismatic.com/api/1.0/?method=getQuote&format=json&lang=ru")
end

function onNetworkResult(result)
    local quote = json:getValue(result, "object string:quoteText")
    local author = json:getValue(result, "object string:quoteAuthor")

    ui:showLinesWithAuthors({ quote }, { author })
end
