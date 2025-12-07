-- name = "Tasker Command Search"
-- description = "Sends tasker command from search bar"
-- data_source = "tasker"
-- type = "search"
-- author = "Sriram SV"
-- version = "1.0"
-- prefix = "tasker | Tasker | command"

local md_color = require "md_colors"
local orange = md_colors.orange_500

text_from = ""
text_to = ""

function on_search(input)
    text_from = input
    text_to = ""
    search:show_buttons({input},{orange})
end

function on_click(idx)
    text_from = string.lower(text_from)
    text_from=text_from:replace(" ", "=:=")
    tasker:send_command(text_from)
end
