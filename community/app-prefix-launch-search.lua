-- name = "App Prefix"
-- description = "Finds apps by name prefix and auto-launches when there is exactly one match"
-- type = "search"
-- author = "Codex"
-- version = "1.0"

all_apps = {}
shown_apps = {}

local max_results = 3

function on_load()
    all_apps = apps:apps()
end

function on_search(query)
    if all_apps == nil or next(all_apps) == nil then
        all_apps = apps:apps()
    end

    if query == nil or query == "" then
        search:show_lines({})
        return
    end

    local q = string.lower(query)
    local names = {}
    local colors = {}
    shown_apps = {}

    local match_count = 0
    for _, app in ipairs(all_apps) do
        local name = app.name or ""
        if string.sub(string.lower(name), 1, #q) == q then
            match_count = match_count + 1
            if match_count <= max_results then
                table.insert(shown_apps, app)
                table.insert(names, name)
                table.insert(colors, app.color)
            end
        end
    end

    if match_count == 1 then
        apps:launch(shown_apps[1].pkg)
        return
    end

    if match_count == 0 then
        search:show_lines({"No matches"})
        return
    end

    search:show_lines(names, colors)
end

function on_click(idx)
    local app = shown_apps[idx]
    if app ~= nil then
        apps:launch(app.pkg)
        return true
    end
    return false
end
