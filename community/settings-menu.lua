-- name = "Settings menu"
-- name_id = "settings"
-- description = "Side menu with AIO settings"
-- aio_version = "4.7.99"
-- type = "drawer"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_drawer_open()
    settings = aio:settings()
    labels = map(function(it) return it.label end, settings)
    drawer:show_list(labels)
end

function on_click(idx)
    aio:open_settings(settings[idx].name)
end
