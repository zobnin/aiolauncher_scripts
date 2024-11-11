-- name = "Ask Perplexity AI"
-- description = "search what you want with perplexity"
-- data_source = "internal"
-- type = "search"
-- author = "JohnyWater"
-- version = "1.0"
-- prefix = "ask"

text_from = ""
text_to = ""

local urll = require "url"
local md_color = require "md_colors"
local green = md_colors.green_400

function on_search(input)
    text_from = input
    text_to = ""
    search:show({input},{green})
end

function on_click(idx)
    system:open_browser(
       "https://www.perplexity.ai/?q=" .. urll.quote(text_from)
    )
end
