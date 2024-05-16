-- name = "Network file"
-- description = "Shows the contents of any file on the Internet"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_resume()
    local args = settings:get()

    if next(args) == nil then
        ui:show_text("Tap to enter text file URL")
    else
        http:get(args[1])
    end
end

function on_click()
    settings:show_dialog()
end

function on_network_result(result)
    ui:show_text(result)
end

function on_settings()
    settings:show_dialog()
end

