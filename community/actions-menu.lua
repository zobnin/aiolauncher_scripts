-- name = "Actions menu"
-- name_id = "actions"
-- description = "Shows aio launcher actions"
-- type = "drawer"
-- aio_version = "4.7.99"
-- author = "Evgeny Zobnin"
-- version = "1.0"

function on_drawer_open()
    actions = aio:actions()
    labels = map(actions, function(it) return it.label end)
    drawer:show_list(labels)
end

function on_click(idx)
    aio:do_action(actions[idx].name)
    drawer:close()
end

function map(tbl, f)
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = f(v)
    end
    return ret
end
