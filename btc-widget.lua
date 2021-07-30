-- name = "Bitcoin price"
-- description = "Current Bitcoin price (blockchain.info)"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function onAlarm()
    net:getText("https://api.blockchain.info/ticker") 
end

function onNetworkResult(result)
    local price = json:getValue(result, "object object:USD string:last")
    ui:showText("BTC = "..price.." USD")
end
