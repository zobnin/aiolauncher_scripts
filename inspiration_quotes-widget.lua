function onAlarm()
    net:getText("https://inspiration.goprogram.ai/")
end

function onNetworkResult(result)
    local quote = json:getValue(result, "object string:quote")
    local author = json:getValue(result, "object string:author")

    ui:showLinesWithAuthors({ quote }, { author })
end
