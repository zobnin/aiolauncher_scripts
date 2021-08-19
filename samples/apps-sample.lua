-- global vars
all_apps = {}

function on_resume()
    all_apps = apps:get_list("launch_count")

    if (next(all_apps) == nil) then
        ui:show_text("The list of apps is not ready yet")
        return
    end

    local apps_names = {}
    for k,v in ipairs(all_apps) do
        apps_names[k] = get_formatted_name(v)
    end

    ui:show_table(slice(apps_names, 1, 9), 3)
end

function on_click(idx)
    apps:launch(all_apps[idx])
end

-- utils

function get_formatted_name(pkg)
    return "<font color=\""..apps:get_color(pkg).."\">"..apps:get_name(pkg).."</color>"
end
