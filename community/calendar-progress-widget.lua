-- name = "Calendar Progress"
-- description = "Shows day, week, month, and year progress bars"
-- type = "widget"
-- author = "meluskyc"
-- version = "1.0"
-- foldable = "false"

local prefs = require "prefs"

function on_load()
    prefs.show_day = true
    prefs.show_week = true
    prefs.show_month = true
    prefs.show_year = true
end

function on_resume()
    local now = os.date("*t", os.time())
    local gui_elems = {}

    if prefs.show_day then
        local seconds_since_day_start =
            now.sec +       -- current minute
            now.min * 60 +  -- previous minutes
            now.hour * 3600   -- previous hours
        local progress_percentage = math.floor((seconds_since_day_start / (24 * 60 * 60)) * 100)
        local label = "Day: " .. progress_percentage .. "%"
        table.insert(gui_elems, {"progress", label, {progress = progress_percentage}})

        if prefs.show_week or prefs.show_month or prefs.show_year then
            table.insert(gui_elems, {"new_line", 1})
        end
    end

    if prefs.show_week then
        local seconds_since_week_start =
            now.sec +       -- current minute
            now.min * 60 +  -- previous minutes
            now.hour * 3600 + -- previous hours
            (now.wday - 1) * 86400 -- previous days
        local progress_percentage = math.floor((seconds_since_week_start / (7 * 24 * 60 * 60)) * 100)
        local label = "Week: " .. progress_percentage .. "%"
        table.insert(gui_elems, {"progress", label, {progress = progress_percentage}})

        if prefs.show_month or prefs.show_year then
            table.insert(gui_elems, {"new_line", 1})
        end
    end

    if prefs.show_month then
        local days_in_month = os.date("*t", os.time{year=now.year, month=now.month+1, day=0}).day
        local seconds_since_month_start =
            now.sec +       -- current minute
            now.min * 60 +  -- previous minutes
            now.hour * 3600 + -- previous hours
            (now.day - 1) * 86400 -- previous days
        local progress_percentage = math.floor((seconds_since_month_start / (days_in_month * 24 * 60 * 60)) * 100)
        local label = "Month: " .. progress_percentage .. "%"
        table.insert(gui_elems, {"progress", label, {progress = progress_percentage}})

        if prefs.show_year then
            table.insert(gui_elems, {"new_line", 1})
        end
    end

    if prefs.show_year then
        local seconds_since_year_start =
            now.sec +       -- current minute
            now.min * 60 +  -- previous minutes
            now.hour * 3600 + -- previous hours
            (now.yday - 1) * 86400 -- previous days

        -- check for leap year
        local days_in_year = 365
        if (now.year % 4 == 0 and now.year % 100 ~= 0) or (now.year % 400 == 0) then
            days_in_year = 366
        end

        local progress_percentage = math.floor((seconds_since_year_start / (days_in_year * 24 * 60 * 60)) * 100)
        local label = "Year: " .. progress_percentage .. "%"
        table.insert(gui_elems, {"progress", label, {progress = progress_percentage}})
    end

    gui(gui_elems).render()
end

function on_settings()
    prefs:show_dialog()
end
