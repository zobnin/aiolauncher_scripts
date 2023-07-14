-- name = "Contacts menu"
-- name_id = "contacts"
-- description = "Shows phone contacts in the side menu"
-- type = "drawer"
-- aio_version = "4.7.99"
-- author = "Evgeny Zobnin"
-- version = "1.0"

function on_drawer_open()
    contacts = distinct_by_name(
        sort_by_name(phone:contacts())
    )

    names = map(contacts, function(it) return it.name end)
    keys = map(contacts, function(it) return it.lookup_key end)

    phone:request_icons(keys)
end

function on_icons_ready(icons)
    drawer:show_list(names, icons, nil, true)
end

function on_click(idx)
    phone:show_contact_dialog(contacts[idx].lookup_key)
end

function map(tbl, f)
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = f(v)
    end
    return ret
end

function sort_by_name(tbl)
    table.sort(tbl, function(a,b) return a.name:lower() < b.name:lower() end)
    return tbl
end

function distinct_by_name(tbl)
    local ret = {}
    local names = {}
    for _, contact in ipairs(tbl) do
        if not names[contact.name] then
            table.insert(ret, contact)
        end
        names[contact.name] = true
    end
    return ret
end
