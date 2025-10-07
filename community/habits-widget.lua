-- name = "Habit Tracker"
-- description = "Daily habit tracker with JSON storage"
-- type = "widget"
-- author = "Sergey Mironov"
-- version = "1.1"

local json = require("json")
local md = require("md_colors")

local buttons = {}
local filename = "button_data.json"
local dialog_state = nil  -- Track current dialog state
local mode = "buttons"

-- Get current date in YYYY-MM-DD format
local function get_current_date()
    return os.date("%Y-%m-%d")
end

-- Get random color from md_colors table
local function get_random_color()
    math.randomseed(os.time())
    local keys = {}
    for k, _ in pairs(md) do
        table.insert(keys, k)
    end
    local randomIndex = math.random(1, #keys)
    local randomKey = keys[randomIndex]
    return md[randomKey]
end

-- get datediff between two dates
local function daysBetween(date1, date2)
    -- Parse date strings in format "YYYY-MM-DD"
    local year1, month1, day1 = date1:match("(%d+)-(%d+)-(%d+)")
    local year2, month2, day2 = date2:match("(%d+)-(%d+)-(%d+)")

    -- Convert to timestamps
    local time1 = os.time({year=year1, month=month1, day=day1})
    local time2 = os.time({year=year2, month=month2, day=day2})

    -- Calculate difference in seconds and convert to days
    local diffSeconds = os.difftime(time2, time1)
    local diffDays = diffSeconds / (24 * 60 * 60)

    return math.floor(diffDays) + 1
end

local function calculate_progress(click_count, add_date)
    now = get_current_date()
    if now == add_date and click_count == 0 then
        return 0
    end
    return math.floor(click_count * 100 / daysBetween(add_date, now))
end

-- Load button data from JSON file
local function load_data()
    local content = files:read(filename)
    if content then
        local success, data = pcall(json.decode, content)
        if success and data then
            buttons = data
        else
            buttons = {}
        end
    else
        buttons = {}
    end
end

-- Save button data to JSON file
local function save_data()
    local content = json.encode(buttons)
    files:write(filename, content)
end

-- Display progress bars
local function display_progress()
    local progress_table = {}
    table.insert(progress_table, {"button", "fa:backward", {color=aio:colors().button}})
    for i, button in ipairs(buttons) do
        table.insert(progress_table, {"new_line", 1})
        table.insert(
                    progress_table,
                    {
                        "progress",
                        string.format(
                                        "%s: %d/%d",
                                        button.title,
                                        button.click_count,
                                        daysBetween(button.add_date, get_current_date())
                        ),
                        {progress = calculate_progress(button.click_count, button.add_date), color=button.color}})
    end
    my_gui = gui(progress_table)
    my_gui.render()
end

-- Display all buttons
local function display_buttons()
    local names = {}
    local colors = {}
    local current_date = get_current_date()

    -- Add the "chart" button at the beginning
    table.insert(names, "fa:chart-bar")
    table.insert(colors, aio:colors().button)  -- Gray color for add button

    -- Add the "+" button at the beginning
    table.insert(names, "fa:plus")
    table.insert(colors, aio:colors().button)  -- Gray color for add button

    -- Add existing buttons
    for i, button in ipairs(buttons) do
        table.insert(names, button.title)

        -- Check if button was clicked today
        if button.last_clicked == current_date then
            table.insert(colors, md.green_600)  -- Green if clicked today
        else
            table.insert(colors, button.color)  -- Original color
        end
    end

    ui:show_buttons(names, colors)
end

-- Handle button clicks
function on_click(index)
    if mode == "progress" then
        if index == 1 then
            mode = "buttons"
            display_buttons()
        end
        return
    end
    -- Check if it's the "=" button (first button)
    if index == 1 then
        mode = "progress"
        display_progress()
        return
    end
    local current_date = get_current_date()
    -- Check if it's the "+" button (second button)
    if index == 2 then
        -- Show add dialog - ask for title first
        dialog_state = {action = "add_title"}
        dialogs:show_edit_dialog("Add New Button", "Enter button title:", "")
        return
    end
    -- Handle existing button click (adjust index for "+" button)
    local button_index = index - 2
    local button = buttons[button_index]
    if button.last_clicked == current_date then
        -- Already clicked today, reset
        button.last_clicked = ""
        button.click_count = math.floor(button.click_count - 1)
        ui:show_toast("Unmarked: " .. button.title)
    else
        -- Not clicked today, mark as clicked
        button.last_clicked = current_date
        button.click_count = math.floor(button.click_count + 1)
        ui:show_toast("Marked: " .. button.title)
    end
    save_data()
    display_buttons()
end

-- Handle long clicks for editing
function on_long_click(index)
    -- Don't allow long-click on "+" button (first button)
    if mode == "progress" or index < 3 then
        return
    end
    -- Show edit options (adjust index for "+" button)
    local button_index = index - 2
    dialog_state = {action = "edit_options", index = button_index}
    local button = buttons[button_index]
    dialogs:show_dialog("Edit Button: " .. button.title, "Choose action:", "Edit", "Delete")
end

-- Handle dialog results
function on_dialog_action(value)
    if value == -1 then
        -- Cancel pressed
        dialog_state = nil
        return
    end

    if not dialog_state then
        return
    end

    if dialog_state.action == "add_title" then
        if type(value) == "string" and value:trim() ~= "" then
            -- Got title, now ask for color
            dialog_state = {action = "add_color", title = value}
            dialogs:show_edit_dialog("Add New Button\nTitle: " .. value, "Enter color (e.g., #FF0000):", get_random_color())
        else
            ui:show_toast("Invalid title")
            dialog_state = nil
        end

    elseif dialog_state.action == "add_color" then
        if type(value) == "string" and value:match("^#%x%x%x%x%x%x$") then
            -- Valid color, create button
            local new_button = {
                title = dialog_state.title,
                color = value,
                last_clicked = "",
                click_count = 0,
                add_date = get_current_date()
            }
            table.insert(buttons, new_button)
            save_data()
            display_buttons()
            ui:show_toast("Added: " .. dialog_state.title)
        else
            ui:show_toast("Invalid color format. Use #RRGGBB")
        end
        dialog_state = nil

    elseif dialog_state.action == "edit_options" then
        if value == 1 then
            -- Edit button - ask for new title
            local button = buttons[dialog_state.index]
            dialog_state = {action = "edit_title", index = dialog_state.index}
            dialogs:show_edit_dialog("Edit Button", "Enter new title:", button.title)
        elseif value == 2 then
            -- Delete button
            local button = buttons[dialog_state.index]
            table.remove(buttons, dialog_state.index)
            save_data()
            display_buttons()
            ui:show_toast("Deleted: " .. button.title)
            dialog_state = nil
        end

    elseif dialog_state.action == "edit_title" then
        if type(value) == "string" and value:trim() ~= "" then
            -- Got new title, now ask for color
            local button = buttons[dialog_state.index]
            dialog_state = {action = "edit_color", index = dialog_state.index, title = value}
            dialogs:show_edit_dialog("Edit Button\nTitle: " .. value, "Enter new color:", button.color)
        else
            ui:show_toast("Invalid title")
            dialog_state = nil
        end

    elseif dialog_state.action == "edit_color" then
        if type(value) == "string" and value:match("^#%x%x%x%x%x%x$") then
            -- Valid color, update button
            local button = buttons[dialog_state.index]
            button.title = dialog_state.title
            button.color = value
            save_data()
            display_buttons()
            ui:show_toast("Updated: " .. button.title)
        else
            ui:show_toast("Invalid color format. Use #RRGGBB")
        end
        dialog_state = nil
    end
end

-- Initialize widget
function on_resume()
    load_data()

    -- Add some sample data if empty
    if #buttons == 0 then
        buttons = {
            {
                title = "Exercise",
                color = md.pink_600,
                last_clicked = "",
                click_count = 0,
                add_date = get_current_date()
            },
            {
                title = "Read",
                color = md.cyan_600,
                last_clicked = "",
                click_count = 0,
                add_date = get_current_date()

            },
            {
                title = "Water",
                color = md.light_blue_600,
                last_clicked = "",
                click_count = 0,
                add_date = get_current_date()
            }
        }
        save_data()
    end
    if mode == "buttons" then
        display_buttons()
    else
        display_progress()
    end
end
