-- name = "Time & Date"
-- description = "Simple widget showing current time and date"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- type = "widget"
-- aio_version = "5.2.1"

local function draw()
    local now  = os.date("*t")
    local time = string.format("%02d:%02d", now.hour, now.min)
    local date = os.date("%a, %d %b")

    gui{
        {"spacer", 2},
        {"text", time, { size = 40 }},
        {"text", date, { size = 20, gravity = "right|center_v" }},
        {"spacer", 2},
    }.render()
end

function on_tick()
    draw()
end

function on_click(idx)
    -- time
    if idx == 2 then
        intent:start_activity{
            action = "android.intent.action.SHOW_ALARMS"
        }
        return
    end

    -- date
    if idx == 3 then
        intent:start_activity{
            action = "android.intent.action.MAIN",
            category = "android.intent.category.APP_CALENDAR"
        }
    end
end

