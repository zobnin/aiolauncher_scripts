-- name = "Habit tracker"
-- description = "Daily habit tracker with JSON storage"
-- type = "widget"
-- author = "Sergey Mironov"
-- version = "1.0"

local json = require("json")
local md = require("md_colors")

local buttons = {}
local filename = "button_data.json"
local dialog_state = nil  -- Track current dialog state

-- Get current date in YYYY-MM-DD format
local function get_current_date()
    return os.date("%Y-%m-%d")
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

-- Display all buttons
local function display_buttons()
    local names = {}
    local colors = {}
    local current_date = get_current_date()

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
    local current_date = get_current_date()

    -- Check if it's the "+" button (first button)
    if index == 1 then
        -- Show add dialog - ask for title first
        dialog_state = {action = "add_title"}
        dialogs:show_edit_dialog("Add New Button", "Enter button title:", "")
        return
    end

    -- Handle existing button click (adjust index for "+" button)
    local button_index = index - 1
    local button = buttons[button_index]
    if button.last_clicked == current_date then
        -- Already clicked today, reset
        button.last_clicked = ""
        ui:show_toast("Unmarked: " .. button.title)
    else
        -- Not clicked today, mark as clicked
        button.last_clicked = current_date
        ui:show_toast("Marked: " .. button.title)
    end

    save_data()
    display_buttons()
end

-- Handle long clicks for editing
function on_long_click(index)
    -- Don't allow long-click on "+" button (first button)
    if index == 1 then
        return
    end

    -- Show edit options (adjust index for "+" button)
    local button_index = index - 1
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
            dialogs:show_edit_dialog("Add New Button\nTitle: " .. value, "Enter color (e.g., #FF0000):", "#FF0000")
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
                last_clicked = ""
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
                last_clicked = ""
            },
            {
                title = "Read",
                color = md.cyan_600,
                last_clicked = ""
            },
            {
                title = "Water",
                color = md.light_blue_600,
                last_clicked = ""
            }
        }
        save_data()
    end

    display_buttons()
end
