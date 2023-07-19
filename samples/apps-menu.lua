-- name = "Apps menu"
-- type = "drawer"
-- testing = "true"

function on_drawer_open()
    apps_tab = apps:list()
    debug:toast("called")

    -- Do not update if the list of the apps is not changed
    if #apps_tab ~= #drawer:items() then
        update()
    end
end

function update()
    names_tab = map(function(it) return apps:name(it) end, apps_tab)
    apps:request_icons(apps_tab)
end

function on_icons_ready(icons_tab)
    drawer:show_list(names_tab, icons_tab, nil, true)
end

function on_click(idx)
    apps:launch(apps_tab[idx])
end
