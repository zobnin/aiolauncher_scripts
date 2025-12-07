-- name = "Play Store"
-- description = "Search anything in Play Store app"
-- data_source = "internal"
-- type = "search"
-- author = "Sriram SV"
-- version = "1.0"
-- prefix = "store|ps"

text_from = ""
text_to = ""

local md_colors = require "md_colors"
local green = md_colors.green_600

function on_search(input)
    text_from = input
    text_to = ""
    search:show_buttons({input},{green})
end

function on_click(idx)
    system:open_browser("https://play.google.com/store/search?q="..text_from)
end


