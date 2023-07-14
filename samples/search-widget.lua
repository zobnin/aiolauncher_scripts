-- name = "Search"
-- description = "Simple widget to open search screen"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_resume()
    ui:show_text("Open search")
end

function on_click(idx)
    aio:do_action("search")
end
