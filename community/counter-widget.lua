-- name = "Counter"
-- description = "Time counting widget to fight bad habits"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "2.0"
-- on_resume_when_folding = "true"

local prefs = require "prefs"
local date = require "date"

-- constants
local max_counters = 5
local year = 365.25
local month = 30.43

local milestones = {
    1, 3, 7, 14,
    month, month * 3, month * 6,
    year, year * 3, year * 5, year * 10, year * 20, year * 100
}

local milestones_formatted = {
    "1+ days", "3+ days", "1+ weeks", "2+ weeks",
    "1+ months", "3+ months", "6+ months",
    "1+ years", "3+ years", "5+ years", "10+ years", "20+ years", "100+ years"
}

function on_load()
    init_default_settings()
end

function on_resume()
    local gui_inst = {}
    local lines_num = max_counters

    if ui:folding_flag() then
        lines_num = 1
    end

    for i = 1, lines_num do
        local title, start_date = parse_settings_string(i)
        if title == nil then
            break
        end

        local curr_date = date()
        local passed = date.diff(curr_date, start_date)
        local passed_days = math.floor(passed:spandays())

        if passed_days < 0 then
            table.insert(gui_inst, {"text", "Error: the date can't be in the future"})
            break
        end

        local idx = get_milestone_idx(passed)
        local passed_str = passed_days.." days"
        if prefs.show_milestones and passed_days > 0 then
            passed_str = passed_str.." / "..milestones_formatted[idx]
        end
        local next_milestone_percent = passed_days / milestones[idx+1] * 100

        table.insert(gui_inst, {"progress", title..": "..passed_str, {progress = next_milestone_percent}})
    end

    gui_inst = insert_between_elements(gui_inst, {"new_line", 1})
    gui(gui_inst):render()
end

function init_default_settings()
    if prefs.counter_1 == nil then
        prefs["counter_1"] = "Sample / 31.01.2024"
        for i = 2,max_counters do
            prefs["counter_"..i] = ""
        end
    end

    if prefs.show_milestones == nil then
        prefs.show_milestones = true
    end
end

function parse_settings_string(i)
    local title_and_date = prefs["counter_"..i]
    if title_and_date == nil or #title_and_date == 0 then
        return nil
    end

    local splitted = title_and_date:split("/")

    local title = trim(splitted[1])
    if title == nil or #title == 0 then
        return nil
    end

    local date_str = trim(splitted[2])
    if date_str == nil or #date_str == 0 then
        return nil
    end

    local arr = date_str:split("%.")
    if arr == nil or #arr < 3 then
        return nil
    end

    local start_date = date(arr[3], arr[2], arr[1])

    return title, start_date
end

function on_click()
    prefs:show_dialog()
end

function on_settings()
    prefs:show_dialog()
end

-- utils

function trim(s)
    if s == nil or #s == 0 then return s end
    return s:match("^%s*(.-)%s*$")
end

function insert_between_elements(t, element)
    local new_table = {}
    for i = 1, #t do
        table.insert(new_table, t[i])
        if i < #t then
            table.insert(new_table, element)
        end
    end
    return new_table
end


function get_milestone_idx(passed)
    local days_passed = passed:spandays()
    local idx = 0

    for k,v in ipairs(milestones) do
        if days_passed > v then
            idx = idx + 1
        else
            break
        end
    end

    return idx
end

