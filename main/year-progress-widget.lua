-- name = "Year progress"
-- description = "Shows current year progress"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
-- foldable = "false"

function on_resume()
    local year_days = 365
    local current_day = os.date("*t").yday
    local percent = math.floor(current_day / (year_days / 100))
    ui:show_progress_bar("Year progress: "..percent.."%", current_day, year_days)
end
