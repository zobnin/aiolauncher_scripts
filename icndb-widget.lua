-- name = "Chuck Norris jokes"
-- description = "icndb.com"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function onAlarm()
    net:getText("http://api.icndb.com/jokes/random") 
end

function onNetworkResult(result)
    local joke = json:getValue(result, "object object:value string:joke")
    ui:showText(joke)
end
