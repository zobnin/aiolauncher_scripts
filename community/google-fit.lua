-- name = "Google Fit"
-- description = "Start/Stop tracking workouts in google fit"
-- data_source = "internal"
-- type = "search"
-- author = "Sriram SV"
-- version = "1.0"
-- prefix = "fit|track"

fit_intent_action = "vnd.google.fitness.TRACK"
fit_intent_mime_type = "vnd.google.fitness.activity/other"
fit_intent_category = "android.intent.category.DEFAULT"
fit_package_name = "com.google.android.apps.fitness"

local md_color = require "md_colors"
local blue = md_colors.light_blue_800
local red = md_colors.red_800
function on_search(input)
    search:show({"Start Tracking", "Stop Tracking"},{blue,red})
end

function on_click(idx)
    local status = ""
    if idx == 1 then
        status = "ActiveActionStatus"
    elseif idx ==2 then
        status = "CompletedActionStatus"
    end
    intent:start_activity{
        action = fit_intent_action,
        category = fit_intent_category,
        package = fit_package_name,
        type = fit_intent_mime_type,
        extras = {
            actionStatus=status
        }
    }
end


