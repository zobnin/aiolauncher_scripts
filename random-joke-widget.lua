-- name = "Random jokes"
-- description = "official-joke-api.appspot.com"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function onAlarm()
    net:getText("https://official-joke-api.appspot.com/random_joke") 
end

function onNetworkResult(result)
    local setup = json:getValue(result, "object string:setup")
    local punchline = json:getValue(result, "object string:punchline")
    ui:showLines({setup, punchline})
end
