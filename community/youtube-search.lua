-- name = "Youtube"
-- description = "Search anything in youtube app"
-- data_source = "internal"
-- type = "search"
-- author = "Sriram SV"
-- version = "1.0"
-- prefix = "youtube|yt"

text_from = ""
text_to = ""
yt_intent_action = "android.intent.action.SEARCH"
yt_intent_category = "android.intent.category.DEFAULT"
yt_package_name = "com.google.android.youtube"

local md_color = require "md_colors"
local red = md_colors.red_800

function on_search(input)
    text_from = input
    text_to = ""
    search:show_buttons({input},{red})
end

function on_click(idx)
    intent:start_activity{
        action = yt_intent_action,
        category = yt_intent_category,
        package = yt_package_name,
        extras = {
            query=text_from
        }
    }
end


