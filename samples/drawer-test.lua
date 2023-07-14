-- name = "Drawer test"
-- type = "drawer"
-- testing = "true"

function on_drawer_open()
    drawer:show_list{ "Empty" }
    debug:toast("on_drawer_open() called!")
end
