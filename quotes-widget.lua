function onAlarm()
    net:getText("https://api.quotable.io/random")
end

function onNetworkResult(result)
    local quote = json:getValue(result, "object string:content")
    local author = json:getValue(result, "object string:author")

    ui:showLinesWithAuthors({ quote }, { author })
end
