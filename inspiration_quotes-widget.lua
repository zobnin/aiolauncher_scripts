-- name = "Inspiration quotes"
-- description = "inspiration.goprogram.ai"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function onAlarm()
    net:getText("https://inspiration.goprogram.ai/")
end

function onNetworkResult(result)
    local quote = json:getValue(result, "object string:quote")
    local author = json:getValue(result, "object string:author")

    ui:showLines({ quote }, { author })
end
