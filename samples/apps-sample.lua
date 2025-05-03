-- global vars
all_apps = {}

function on_resume()
    all_apps = apps:apps("launch_count")

    if (next(all_apps) == nil) then
        ui:show_text("The list of apps is not ready yet")
        return
    end

    local apps_names = {}
    for k,v in ipairs(all_apps) do
        apps_names[k] = get_formatted_name(v)
    end

    ui:show_table(table_to_tables(slice(apps_names, 1, 9), 3))
end

function on_click(idx)
    apps:launch(all_apps[idx].pkg)
end

-- utils

function get_formatted_name(app)
    return "<font color=\""..app.color.."\">"..app.name.."</color>"
end

function table_to_tables(tab, num)
    local out_tab = {}
    local row = {}

    for k,v in ipairs(tab) do
        table.insert(row, v)
        if k % num == 0 then
            table.insert(out_tab, row)
            row = {}
        end
    end

    return out_tab
end
