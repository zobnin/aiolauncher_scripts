-- name = "Drawer Sample #2"
-- type = "drawer"
-- testing = "true"

local list = {
    "abc",
    "launch_count",
    "launch_time",
    "install_time",
    "appbox",
    "categories",
    "close",
}

function on_drawer_open()
    drawer:show_list(list)
end

function on_click(idx)
    if list[idx] == "close" then
        drawer:close()
    else
        drawer:change_view(list[idx])
    end
end
