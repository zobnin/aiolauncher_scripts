-- name = "Tasks tests"
-- type = "drawer"
-- aio_version = "4.7.99"
-- author = "Evgeny Zobnin"
-- version = "1.0"
-- testing = "true"

local fmt = require "fmt"
local tasks_list = {}
local test_task = {}

function on_drawer_open()
    refresh()
end

function refresh()
    tasks:load()
end

function on_tasks_loaded(new_tasks)
    tasks_list = new_tasks
    local texts = map(tasks_list, task_to_text)
    table.insert(texts, fmt.italic("Show new task dialog"))
    table.insert(texts, fmt.italic("Add test task"))
    table.insert(texts, fmt.italic("Change test task"))
    drawer:show_ext_list(texts)
end

function on_click(idx)
    if idx == #tasks_list+1 then
        tasks:show_editor()
    elseif idx == #tasks_list+2 then
        tasks:add{text = "test task"}
        refresh()
    elseif idx == #tasks_list+3 then
        test_task.text = "test task (changed)"
        tasks:save(test_task)
        refresh()
    else
        tasks:show_editor(tasks_list[idx].id)
    end
end

function on_long_click(idx)
    if idx <= #tasks_list then
        tasks:remove(tasks_list[idx].id)
        refresh()
    end
end

function task_to_text(it)
    if it.text == "test task" then
        test_task = it
    end

    if it.completed_date > 0 then
        return fmt.strike(it.text)
    elseif it.due_date < os.time() then
        return fmt.bold(fmt.red(it.text))
    elseif it.is_today then
        return fmt.bold(it.text)
    else
        return it.text
    end
end

function map(tbl, f)
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = f(v)
    end
    return ret
end
