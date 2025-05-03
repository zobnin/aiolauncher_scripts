-- name = "Clipboard"
-- description = "Shows current Clipboard contents"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_resume()
    local clipboard = system:clipboard()
    ui:show_text(clipboard)
end
