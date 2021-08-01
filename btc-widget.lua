-- name = "Bitcoin price"
-- description = "Current Bitcoin price (blockchain.info)"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

equals = "<font color=\""..ui:get_secondary_text_color().."\"> = </font>"

function on_alarm()
    net:get_text("https://api.blockchain.info/ticker") 
end

function on_network_result(result)
    local price = ajson:get_value(result, "object object:USD string:last")
    ui:show_text("BTC"..equals..price.." USD")
end
