-- name = "StartPage"
-- description = "StarPage search engine suggestions script"
-- data_source = "www.startpage.com"
-- type = "search"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

local json = require "json"
local url = require "url"

local suggests_uri = "https://www.startpage.com/suggestions?q="
local open_uri = "https://www.startpage.com/do/search?q="

local results = {}

function on_search(input)
    local quoted = url.quote(input)
    http:get(suggests_uri..quoted.."&segment=")
end

function on_network_result(result, code)
    if code >= 200 and code < 300 then
        show(result)
    end
end

function show(result)
	local t = json.decode(result)

    results = {}

    for k,v in pairs(t.suggestions) do
        table.insert(results, v.text)
    end

    search:show_top(results)
end

function on_click(idx)
    system:open_browser(open_uri..results[idx])
end
