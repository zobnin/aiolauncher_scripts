-- name = "Actions"

function on_resume()
    actions_names = { "Drawer", "Search" }
    actions = { "apps_menu", "search" }

    ui:show_buttons(actions_names)
end

function on_click(idx)
    aio:do_action(actions[idx])
end
