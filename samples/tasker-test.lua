local tasks = {}

function on_resume()
    tasks = tasker:get_tasks()
    ui:show_lines(tasks)
end

function on_click(idx)
    tasker:run_task(tasks[idx])
end

-- Optional
function on_task_result(success)
    if success then
        ui:show_toast("Successfull!")
    else
        ui:show_toast("Failed!")
    end
end
