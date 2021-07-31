-- name = "Random quotes"
-- description = "quotable.io"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function onAlarm()
    net:getText("https://api.quotable.io/random")
end

function onNetworkResult(result)
    local quote = json:getValue(result, "object string:content")
    local author = json:getValue(result, "object string:author")

    ui:showLines({ quote }, { author })
end
