-- name = "Chuck Norris jokes (sync)"
-- description = "icndb.com"
-- data_source = "icndb.com"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_alarm()
    local response = shttp:get("http://api.icndb.com/jokes/random")

    if response.error ~= nil then
        ui:show_text(response.error)
        return
    end

    if response.code >= 200 and response.code < 300 then
        joke = ajson:read(response.body, "object object:value string:joke")
        ui:show_text(joke)
    end
end

function on_click()
    if joke ~= nil then
        system:to_clipboard(joke)
    end
end
