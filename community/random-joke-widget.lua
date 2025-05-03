-- name = "Random jokes"
-- description = "official-joke-api.appspot.com"
-- data_source = "official-joke-api.appspot.com"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_alarm()
    http:get("https://official-joke-api.appspot.com/random_joke")
end

function on_network_result(result)
    setup = ajson:read(result, "object string:setup")
    punchline = ajson:read(result, "object string:punchline")

    ui:show_lines({setup, punchline})
end

function on_click()
    if setup ~= nil then
        system:to_clipboard(setup.."\n"..punchline)
    end
end
