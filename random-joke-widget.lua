function onAlarm()
    net:getText("https://official-joke-api.appspot.com/random_joke") 
end

function onNetworkResult(result)
    local setup = json:getValue(result, "object string:setup")
    local punchline = json:getValue(result, "object string:punchline")
    ui:showLines({setup, punchline})
end
