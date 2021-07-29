function onAlarm()
    net:getText("https://api.blockchain.info/ticker") 
end

function onNetworkResult(result)
    local price = json:getValue(result, "object object:USD string:last")
    aio:showText("BTC = "..price.." USD")
end
