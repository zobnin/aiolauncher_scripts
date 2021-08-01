-- name = "Chuck Norris jokes"
-- description = "icndb.com"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_alarm()
    net:get_text("http://api.icndb.com/jokes/random") 
end

function on_network_result(result)
    local joke = ajson:get_value(result, "object object:value string:joke")
    ui:show_text(joke)
end
