-- name = "Bitcoin price"
-- description = "Current Bitcoin price (blockchain.info)"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

equals = "<font color=\""..ui:get_colors().secondary_text.."\"> = </font>"

function on_alarm()
    http:get("https://api.blockchain.info/ticker")
end

function on_network_result(result)
    local price = ajson:read(result, "object object:USD string:last")
    ui:show_text("1 BTC"..equals..price.." USD")
end
