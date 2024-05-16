-- name = "Period progress"
-- description = "Shows period progress"
-- type = "widget"
-- author = "Nikolai Galashev"
-- version = "1.0"
-- arguments_help = "Enter the title and the start and end date in this format: Title 2021 01 31 2021 09 25"

function on_resume()
    if (next(settings:get()) == nil) then
        ui:show_text("Tap to enter date")
        return
    end

    local params = settings:get()
    start_period = get_time(params[2], params[3], params[4]);
    end_period = get_time(params[5], params[6], params[7]);
    name_period = params[1]
    current_time = os.time()
    init_progressbar()
end

function on_click()
    settings:show_dialog()
end

function get_time(y,m,d)
    return os.time{day=d,month=m,year=y}
end

function init_progressbar()
    percent = math.floor((current_time - start_period) / ((end_period - start_period) / 100))
    ui:show_progress_bar(name_period..": "..percent.."%", current_time - start_period, end_period - start_period, "#7069f0ae")
end

function on_settings()
    settings:show_dialog()
end

