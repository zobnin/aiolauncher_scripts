-- name = "Share Text"
-- description = "Share text with other apps"
-- data_source = "internal"
-- type = "search"
-- author = "Sriram SV"
-- version = "1.0"
-- prefix = "share"

local md_color = require "md_colors"

-- constants
local blue = md_colors.blue_500
local red = md_colors.red_500

-- variables
text_from = ""
text_to=""
function on_search(input)
    text_from = input
    text_to = ""
    search:show_buttons({"Share \""..input.."\""}, {blue}, true)
end

function on_click()
    if text_to == "" then
        system:share_text(text_from)
    end
end

