-- name = "Public IP"
-- description = "Shows your public IP (ipify.org)"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function onAlarm()
    net:getText("https://api.ipify.org") 
end

function onNetworkResult(result)
    ui:showText(result)
end
