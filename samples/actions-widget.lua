-- name = "Actions"
-- description = "Launcher actions widget"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

md_colors = require "md_colors"

function on_resume()
    actions_names = { "Drawer", "Search", "Notify", "Menu" }
    actions_colors = { md_colors.purple_800, md_colors.purple_600, md_colors.purple_400, md_colors.purple_300 }
    actions = { "apps_menu", "search", "notify", "quick_menu" }

    ui:show_buttons(actions_names, actions_colors)
end

function on_click(idx)
    aio:do_action(actions[idx])
end
