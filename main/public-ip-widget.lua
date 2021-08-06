-- name = "Public IP"
-- description = "Shows your public IP (ipify.org)"
-- data_source = "ipify.org"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_alarm()
    http:get("https://api.ipify.org") 
end

function on_network_result(result)
    ui:show_text(result)
end
