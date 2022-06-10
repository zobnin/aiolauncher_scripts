local names = {
    "Open AIO Launcher site",
    "Copy to clipboard",
    "Wait 2 seconds and enable flashlight",
}

local tasks = {
    "VIEW_URL http://aiolauncher.app '' false ''",
    "SET_CLIPBOARD 'Text to copy' false ''",
    "WAIT 0 2 0 0 0; TORCH true",
}

function on_resume()
    ui:show_lines(names)
end

function on_click(idx)
    tasker:run_own_task(tasks[idx])
end

-- Optional
function on_task_result(success)
    if success then
        ui:show_toast("Successfull!")
    else
        ui:show_toast("Failed!")
    end
end
