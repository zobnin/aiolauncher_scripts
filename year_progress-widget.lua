-- name = "Year progess"
-- description = "Shows current year progress"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function onResume()
    local yearDays = 365
    local currentDay = os.date("*t").yday
    local percent = math.floor(currentDay / (yearDays / 100))
    ui:showProgressBar("Year progress: "..percent.."%", currentDay, yearDays)
end
