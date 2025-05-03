-- name = "Dad jokes"
-- description = "icanhazdadjoke.com"
-- type = "widget"
-- author = "me"
-- version = "1.0"

function on_resume()
    http:get("http://icanhasdadjoke.com/slack")
end

function on_network_result(result)
    joke = ajson:read(result, "object array:attachments object:0 string:text")
    ui:show_text(joke)
end

function on_click()
    if joke ~= nil then
        system:to_clipboard(joke)
    end
end
