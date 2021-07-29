function onAlarm()
    net:getText("https://api.ipify.org") 
end

function onNetworkResult(result)
    ui:showText(result)
end
