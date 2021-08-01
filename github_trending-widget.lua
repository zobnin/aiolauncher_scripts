-- name = "GitHub Trending"
-- description = "GitHub trending repositories (trending-github.com)"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_alarm()
    net:get_text("https://api.trending-github.com/github/repositories") 
end

function on_network_result(result)
    local names = {
        ajson:get_value(result, "array object:0 string:name"),
        ajson:get_value(result, "array object:1 string:name"),
        ajson:get_value(result, "array object:2 string:name"),
    }
    
    local descriptions = {
        ajson:get_value(result, "array object:0 string:description"),
        ajson:get_value(result, "array object:1 string:description"),
        ajson:get_value(result, "array object:2 string:description"),
    }
    
    urls = {
        ajson:get_value(result, "array object:0 string:url"),
        ajson:get_value(result, "array object:1 string:url"),
        ajson:get_value(result, "array object:2 string:url"),
    }

    ui:show_lines(names, descriptions)
end

function on_click(idx)
    system:open_browser(urls[idx])
end
