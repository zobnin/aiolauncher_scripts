-- name = "Search Engine Selector"
-- type = "search"

local lastQuery = ""

function on_search(query)
    lastQuery = query
    local results = {}
    if #query > 0 then
        table.insert(results, "Search Google for: " .. query)
        table.insert(results, "Search Bing for: " .. query)
    end
    search:show_lines(results)
end

function on_click(index)
    if index == 1 then
        system:open_browser("https://www.google.com/search?q=" .. lastQuery)
        return true
    elseif index == 2 then
        system:open_browser("https://www.bing.com/search?q=" .. lastQuery)
        return true
    end
    return false
end
