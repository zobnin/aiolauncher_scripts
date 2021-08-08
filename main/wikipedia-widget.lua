-- name = "Wikipedia"
-- description = "Random article from wikipedia"
-- data_source = "https://wikipedia.org"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

json = require "json"
url = require "pl.url"

-- constants
local lang = system:get_lang()
local random_url = "https://"..lang..".wikipedia.org/w/api.php?action=query&format=json&list=random&rnnamespace=0&rnlimit=1"
local summary_url = "https://"..lang..".wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1"
local article_url = "https://"..lang..".wikipedia.org/wiki/"

-- global vars
local title = ""

function on_alarm()
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

    ui:show_lines({ extract:sub(1, 200) }, { title })
end

function on_click()
    system:open_browser(article_url..url.quote(title))
end

-- utils --

local function get_extract(parsed)
    for k,v in pairs(parsed.query.pages) do
        for k, v in pairs(v) do
            if (k == "extract") then
                return v
            end
        end
    end
end
