-- name = "Drawer Sample #1"
-- type = "drawer"
-- testing = "true"

local fmt = require "fmt"
local list = {}
local cur_tab = 1

function on_drawer_open()
    if cur_tab == 1 then
        show_list1()
    else
        show_list2()
    end

    drawer:add_buttons({"fa:circle-1", "fa:circle-2"}, cur_tab)
end

function show_list1()
    list = { "First line", fmt.bold("Second line"), fmt.red("Third line") }
    -- optional
    local icons = { "fa:circle-1", "fa:circle-2", "fa:circle-3" }
    -- optional
    local badges = { "Wow", "New", "11" }

    drawer:show_list(list, icons, badges)
end

function show_list2()
    list = {
        "You can display long text as side-menu items.",
        "This can be used, for example, to display a list of messages.",
        "Even if you don't use this output method, I think it's cool.",
    }

    drawer:show_ext_list(list)
end

function on_click(idx)
    debug:toast(list[idx].." clicked")
end

function on_button_click(idx)
    cur_tab = idx
    on_drawer_open()
end
