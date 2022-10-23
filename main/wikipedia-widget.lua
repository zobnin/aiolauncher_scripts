-- name = "Wikipedia"
-- description = "Random article from wikipedia"
-- data_source = "wikipedia.org"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
-- foldable = "false"

json = require "json"
url = require "url"

function on_alarm()
    lang = system:lang()
    random_url = "https://"..lang..".wikipedia.org/w/api.php?action=query&format=json&list=random&rnnamespace=0&rnlimit=1"
    summary_url = "https://"..lang..".wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1"
    article_url = "https://"..lang..".wikipedia.org/wiki/"

    http:get(random_url)
end

function on_network_result(result)
    local parsed = json.decode(result)
    title = parsed.query.random[1].title

    http:get(summary_url.."&titles="..url.quote(title), "summary")
end

function on_network_result_summary(result)
    local parsed = json.decode(result)
    local extract = get_extract(parsed)

    ui:show_lines({ smart_sub(extract, 200) }, { title })
end

function on_click()
    system:open_browser(article_url..url.quote(title))
end

-- utils --

function smart_sub(string, max)
    local pos1, pos2 = string:find("%.", max-50)

    if pos1 ~= nil and pos1 < max+50 then
        return string:sub(1, pos1+1)
    else
        return string:sub(1, max)
    end
end

function get_extract(parsed)
    for k,v in pairs(parsed.query.pages) do
        for k, v in pairs(v) do
            if (k == "extract") then
                return v
            end
        end
    end
end
