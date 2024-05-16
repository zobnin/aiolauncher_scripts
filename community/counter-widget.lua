-- name = "Counter"
-- description = "Time counting widget to fight bad habits"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- arguments_help = "Enter the date of the start of counting in the format DD.MM.YYYY"
-- version = "1.0"

local date = require "date"

-- constants
local year = 365.25
local month = 30.43

local milestones = {
    1, 3, 7, 14,
    month, month * 3, month * 6,
    year, year * 3, year * 5, year * 10, year * 20, year * 100
}

local milestones_formatted = {
    "1 day", "3 days", "1 week", "2 weeks",
    "1 months", "3 months", "6 months",
    "1 year", "3 years", "5 years", "10 years", "20 years", "100 years"
}

function on_resume()
    local args = settings:get()

    if next(args) == nil then
        ui:show_text("Tap to enter date")
        return
    end

    local arr = args[1]:split("%.")
    local start_date = date(arr[3], arr[2], arr[1])

    local curr_date = date()
    local passed = date.diff(curr_date, start_date)
    local passed_days = math.floor(passed:spandays())
    local idx = get_milestone_idx(passed)

    ui:show_progress_bar(passed_days.." days / "..milestones_formatted[idx],
        passed_days, milestones[idx])
end

function on_click()
    settings:show_dialog()
end

function on_settings()
    settings:show_dialog()
end

-- utils

function get_milestone_idx(passed)
    local days_passed = passed:spandays()
    local idx = 1

    for k,v in ipairs(milestones) do
        if days_passed > v then
            idx = idx + 1
        end
    end

    return idx
end

