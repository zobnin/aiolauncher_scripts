-- name = "News"
-- description = "Simple RSS news widget"
-- data_source = "https://rss-to-json-serverless-api.vercel.app/"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"

-- settings
local feed = "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"
local lines_num = 5

local api_url = "https://rss-to-json-serverless-api.vercel.app/api?feedURL="
local titles = {}
local descs = {}
local urls = {}
local times = {}
local url = ""

local json = require "json"

function on_resume()
    ui:show_lines(titles)
end

function on_alarm()
    http:get(api_url..feed)
end

function on_network_result(result)
    local t = json.decode(result)
    local n = math.min(lines_num, #t.items)
    for i = 1, n, 1 do
        titles[i] = t.items[i].title
        descs[i] = t.items[i].description
        urls[i] = t.items[i].url
        times[i] = os.date("%d.%m.%Y, %H:%M",t.items[i].created/1000)
    end
    ui:show_lines(titles)
end

function on_click(i)
    url = urls[i]
    ui:show_dialog(titles[i].." | "..times[i], descs[i], "open in browser")
end

function on_dialog_action(i)
    if i == 1 then
        system:open_browser(url)
    end
end
