-- name = "What to do?"
-- description = "Let's find you something to do"
-- data_source = "https://bored.api.lewagon.com/"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
-- foldable = "false"

function on_resume()
    ui:show_text("Tell me what to do?")
end

function on_click()
    system:vibrate(100)
    http:get("https://bored.api.lewagon.com/api/activity/")
end

function on_network_result(result)
    text = ajson:get_value(result, "object string:activity")
    ui:show_text(text)
end
