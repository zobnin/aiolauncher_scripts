-- name = "Drawer sample #4"
-- type = "drawer"
-- testing = "true"

function on_drawer_open()
    pkgs = apps:list()
    apps:request_icons(pkgs)
end

function on_icons_ready(icons)
    names = map(pkgs, function(it) return apps:name(it) end)
    drawer:show_list(names, icons, nil, true)
end

function on_click(idx)
    apps:launch(pkgs[idx])
end

function map(tbl, f)
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = f(v)
    end
    return ret
end

