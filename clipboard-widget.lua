-- name = "Clipboard"
-- description = "Shows current Clipboard contents"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_resume()
    ui:show_text(system:get_from_clipboard())
end
