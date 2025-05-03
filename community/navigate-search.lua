-- name = "Navigate"
-- description = "Navigate to address"
-- data_source = "internal"
-- type = "search"
-- author = "Sriram SV"
-- version = "1.0"
-- prefix = "navigate|nav"

text_from = ""
text_to = ""
maps_intent_action = "android.intent.action.VIEW"
maps_intent_category = "android.intent.category.DEFAULT"
maps_package_name = "com.google.android.apps.maps"

local md_color = require "md_colors"
local blue = md_colors.light_blue_800

function on_search(input)
    text_from = input
    text_to = ""
    search:show_buttons({input},{blue})
end

function on_click(idx)
    intent:start_activity{
        action = maps_intent_action,
        category = maps_intent_category,
        package = maps_package_name,
        data = "google.navigation:q="..text_from
    }
end

