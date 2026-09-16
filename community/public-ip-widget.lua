-- name = "Public IP"
-- description = "Shows your public IP"
-- data_source = "ipify.org"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.1"
-- foldable = "false"

local public_ip

function on_alarm()
    http:get("https://api.ipify.org")
end

function on_network_result(result, code)
    if code >= 200 and code < 299 then
        public_ip = result
        ui:show_text(public_ip)
    end
end

function on_click()
    on_alarm()
end

function on_long_click()
    if public_ip ~= nil then
        system:to_clipboard(public_ip)
    end
end
