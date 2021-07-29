function onAlarm()
    net:getText("https://api.ipify.org") 
end

function onNetworkResult(result)
    aio:showText(result)
end
