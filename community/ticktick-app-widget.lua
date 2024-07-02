-- name = "TickTick"
-- description = "AIO Launhcer wrapper for official TickTick app widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
-- uses_app = "com.ticktick.task"

local prefs = require "prefs"
local fmt = require "fmt"

local w_bridge = nil
local lines = {}

function on_resume()
    if not widgets:bound(prefs.wid) then
        setup_app_widget()
    end

    widgets:request_updates(prefs.wid)
end

function on_app_widget_updated(bridge)
    lines = {}

    -- We use dump_tree instead of dump_table because Lua tables
    -- do not preserve the order of elements (which is important in this case).
    -- Additionally, the text tree is simply easier to parse.
    local tree = bridge:dump_tree()
    local all_lines = extract_list_item_lines(tree)
    lines = combine_lines(all_lines)

    table.insert(lines, fmt.secondary("Add task"))

    w_bridge = bridge
    ui:show_lines(lines)
end

function on_click(idx)
    if idx == #lines then
        -- "Plus" button
        w_bridge:click("image_3")
    else
        -- First task name
        w_bridge:click("text_2")
    end
end

function on_settings()
    w_bridge:click("text_1")
end

-- Extract all elements with a nesting level of 6 (task texts and dates)
function extract_list_item_lines(str)
    for line in str:gmatch("[^\n]+") do
        if line:match("^%s%s%s%s%s%s%s%s%s%s%s%s") then
            table.insert(lines, extract_text_after_colon(line))
        end
    end
    return lines
end

-- Tasks list elements in the the dump are separated by a 1x1 image,
-- so we can use it to understand where one task ends and another begins.
function combine_lines(lines)
    local result = {}
    local temp_lines = {}

    for i, line in ipairs(lines) do
        if line == "1x1" then
            if #temp_lines > 0 then
                table.insert(result, concat_lines(temp_lines))
                temp_lines = {}
            end
        else
            table.insert(temp_lines, line)
        end
    end

    if #temp_lines > 0 then
        table.insert(result, concat_lines(temp_lines))
    end

    return result
end

-- The text and date of a task in the dump appear consecutively,
-- and we need to combine them, keeping in mind that the date might be absent.
function concat_lines(lines)
    if lines[1] then
        lines[1] = fmt.primary(lines[1])
    end

    if lines[2] then
        lines[2] = fmt.secondary(lines[2])
    end

    return table.concat(lines, fmt.secondary(" - "))
end

function extract_text_after_colon(text)
    return text:match(":%s*(.*)")
end

function setup_app_widget()
    local id = widgets:setup("com.ticktick.task/com.ticktick.task.activity.widget.GoogleTaskAppWidgetProviderLarge")
    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_text("Can't add widget")
    end
end
