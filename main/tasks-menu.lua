-- name = "Notes & tasks menu"
-- name_id = "notes"
-- description = "Shows tasks in the side menu"
-- type = "drawer"
-- aio_version = "4.7.99"
-- author = "Evgeny Zobnin"
-- version = "1.0"

local fmt = require "fmt"
local prefs = require "prefs"

local primary_color = aio:colors().primary_color
local secondary_color = aio:colors().secondary_color

local bottom_buttons = {
    "fa:note_sticky",  -- notes tab
    "fa:list-check",   -- tasks tab
    "fa:pipe",         -- separator
    "fa:note_medical", -- new note button
    "fa:square_plus"   -- new task button
}

local notes_list = {}
local tasks_list = {}

if prefs.curr_tab == nil then
    prefs.curr_tab = 1
end

function on_drawer_open()
    drawer:add_buttons(bottom_buttons, prefs.curr_tab)

    if prefs.curr_tab == 1 then
        notes:load()
    else
        tasks:load()
    end
end

function on_tasks_loaded(new_tasks)
    tasks_list = new_tasks
    local texts = map(tasks_list, task_to_text)
    drawer:show_ext_list(texts)
end

function on_notes_loaded(new_notes)
    notes_list = new_notes
    local texts = map(notes_list, note_to_text)
    drawer:show_ext_list(texts)
end

function note_to_text(it)
    if it.text == "test note" then
        test_note = it
    end

    if it.color ~= 6 then
        return fmt.colored(it.text, notes:colors()[it.color])
    else
        return it.text
    end
end

function task_to_text(it)
    local text = ""
    local date_str = os.date("%b, %d, %H:%M", it.due_date)

    if it.completed_date > 0 then
        text = fmt.strike(it.text)
    elseif it.due_date < os.time() then
        text = fmt.bold(fmt.red(it.text))
    elseif it.is_today then
        text = fmt.bold(it.text)
    else
        text = it.text
    end

    return text.."<br/>"..fmt.space(4)..fmt.small(date_str)
end

function on_click(idx)
    if prefs.curr_tab == 1 then
        on_note_click(idx)
    else
        on_task_click(idx)
    end
end

function on_note_click(idx)
    notes:show_editor(notes_list[idx].id)
end

function on_task_click(idx)
    tasks:show_editor(tasks_list[idx].id)
end

function on_long_click(idx)
    if prefs.curr_tab == 1 then
        on_note_long_click(idx)
    else
        on_task_long_click(idx)
    end
end

function on_note_long_click(idx)
    system:to_clipboard(notes_list[idx].text)
end

function on_task_long_click(idx)
    system:to_clipboard(tasks_list[idx].text)
end

function on_button_click(idx)
    if idx < 3 then
        prefs.curr_tab = idx
        on_drawer_open()
    elseif idx == 4 then
        notes:show_editor()
    elseif idx == 5 then
        tasks:show_editor()
    end
end

function map(tbl, f)
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = f(v)
    end
    return ret
end
