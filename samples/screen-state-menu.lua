-- name = "Screen state"
-- type = "drawer"

local prefs = require "prefs"

function on_drawer_open()
    if prefs.states == nil then
        prefs.states = {}
    end

    update_screen()
end

function update_screen()
    local state_names = {}

    for k,v in pairs(prefs.states) do
        table.insert(state_names, k)
    end

    table.insert(state_names, "Save new state")

    drawer:show_list(state_names)
end

function on_click(idx)
    if idx > #prefs.states then
        save_state("State")
    else
        restore_state(name)
    end
end

function save_state(name)
    local state = aio:active_widgets()
    prefs.states[name] = state
    update_screen()
end

function restore_state(name)
    remove_all_widgets()

    for k,v in pairs(prefs.states[name]) do
        aio:add_widget(v.name, v.position)
    end
end

function remove_all_widgets()
    local curr_state = aio:active_widgets()
    for k,v in pairs(curr_state) do
        aio:remove_widget(v.position)
    end
end
