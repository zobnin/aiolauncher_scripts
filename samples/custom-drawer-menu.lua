-- name = "Custom Drawer Menu"
-- type = "drawer"

function on_drawer_open()
    local menuItems = {"Open Website", "Update list", "Launch App"}
    drawer:show_list(menuItems)
end

function on_click(index)
    if index == 1 then
        system:open_browser("https://www.example.com")
    elseif index == 2 then
        local menuItems = {"Open Website", "List updated", "Launch App"}
        drawer:show_list(menuItems)
    elseif index == 3 then
        apps:launch("com.android.contacts")
    end
    return true
end

