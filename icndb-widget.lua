function onAlarm()
    net:getText("http://api.icndb.com/jokes/random") 
end

function onNetworkResult(result)
    local joke = json:getValue(result, "object object:value string:joke")
    aio:showText(joke)
end
