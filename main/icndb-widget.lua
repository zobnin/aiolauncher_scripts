-- name = "Chuck Norris jokes"
-- description = "icndb.com"
-- data_source = "icndb.com"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_alarm()
    http:get("http://api.icndb.com/jokes/random") 
end

function on_network_result(result)
    joke = ajson:get_value(result, "object object:value string:joke")
    ui:show_text(joke)
end

function on_click()
    if joke ~= nil then
        system:copy_to_clipboard(joke)
    end
end
