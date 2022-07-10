-- type = "widget"
-- name = "Todoist"
-- description = "Integration with Todoist"
-- data_source = "https://todoist.com/app/"
-- author = "Timo Peters & Andrey Gavrilov"
-- aio_version = "4.4.1-beta11"
-- version = "2.3

-- modules
local json = require "json"
local fmt = require "fmt"
local md_colors = require "md_colors"

-- constants
local dot = "⬤ "
local exclamation = "❗"
local today_meta = "<!--meta:today-->"
local overdue_meta = "<!--meta:overdue-->"
local hour = 60 * 60
local day = 24 * hour
local week = 7 * day
local decay_time = 6 * hour
local colors = {
    md_colors.red_500,
    md_colors.orange_500,
    md_colors.blue_500,
}

-- vars
local projects = {}
local sections = {}
local tasks = {}
local dialog_id = ""
local lines_id = {}
local task = 0

function on_alarm()
    -- settings format: { "token", project_id }

    if next(settings:get()) == nil or settings:get()[1] == "" then
        settings:set({"", 0})
    end

    local token = settings:get()[1]
    if token == "" then
        ui:show_text("Tap to enter your API token!")
        return
    end

    api_set_token(token)
    api_get_projects()
end

function on_network_result_projects(res)
    files:write("todoist_projects", res)
    api_get_sections()
end

function on_network_result_sections(res)
    files:write("todoist_sections", res)
    api_get_tasks()
end

function on_network_result_tasks(res, err)
    files:write("todoist_tasks", res)
    files:write("todoist_time", os.time())
    on_resume()
end

function on_resume()
    if settings:get()[1] == "" then
        on_alarm()
        return
    end

    if not files:read("todoist_projects") then
        files:write("todoist_projects", json.encode({}))
    end
    if not files:read("todoist_sections") then
        files:write("todoist_sections", json.encode({}))
    end
    if not files:read("todoist_tasks") then
        files:write("todoist_tasks", json.encode({}))
    end

    projects = json.decode(files:read("todoist_projects"))
    sections = json.decode(files:read("todoist_sections"))
    tasks = json.decode(files:read("todoist_tasks"))

    redraw()
end

function on_click(idx)
    if settings:get()[1] == "" then
        dialog_id = "settings"
        ui:show_edit_dialog("Enter your API token")
    elseif idx == 1 then
        select_project()
    elseif idx == #lines_id then
        create_task()
    else
        open_task(lines_id[idx])
    end
end

function select_project()
    local tab = {}
    table.insert(tab, "All projects")
    for i,v in ipairs(projects) do
        table.insert(tab, v.name)
    end

    dialog_id = "projects"
    ui:show_radio_dialog("Select project", tab, get_project_idx() + 1)
end

function on_dialog_projects(res)
    local args = settings:get()

    if res > 1 then
        args[2] = projects[res-1].id
    else
        args[2] = 0
    end

    settings:set(args)
    on_resume()
end

function get_project_idx()
    local project = tonumber(settings:get()[2])
    for i,v in ipairs(projects) do
        if project == v.id then
            return i
        end
    end
    return 0
end

function on_settings()
    dialog_id = "settings"
    ui:show_edit_dialog("Enter your API token", "", settings:get()[1])
end

function on_dialog_settings(res)
    local args = settings:get()
    args[1] = res
    settings:set(args)
    on_alarm()
end

function redraw()
    local project_name = ""
    local first_line = ""
    local lines = {}
    local tasks = {}
    lines_id = {}

    local project_id = tonumber(settings:get()[2])
    local project_name = fmt.bold(get_project_name(project_id))
    --project_name = fmt.colored(project_name, get_project_color(project_id))

    if os.time() - files:read("todoist_time") > decay_time then
        first_line = project_name.." (outdated)"
    else
        first_line = project_name
    end

    table.insert(lines_id, project_id)

    tasks = insert_tasks(tasks, project_id, 0)

    for i,v in ipairs(sections) do
        tasks = insert_tasks(tasks, project_id, v.id)
    end

    table.insert(lines_id, 0)

    table.insert(lines, first_line)
    concat_tables(lines, tasks)
    table.insert(lines, fmt.secondary("Add task"))

    local today_str = "empty"

    if #tasks > 0 then
        today_str = "today: "..get_today_tasks_num(tasks)
    end

    local overdue_str = ""
    local overdue_num = get_overdue_tasks_num(tasks)

    if (overdue_num > 0) then
        overdue_str = ", "..fmt.red("overdue: "..get_overdue_tasks_num(tasks))
    end

    local folded_str = project_name.." ("..today_str..overdue_str..")"

    ui:show_lines(lines, nil, folded_str)
end

function get_today_tasks_num(tasks)
    return get_tasks_num_with_meta(tasks, today_meta)
end

function get_overdue_tasks_num(tasks)
    return get_tasks_num_with_meta(tasks, overdue_meta)
end

function get_tasks_num_with_meta(tasks, meta)
    local num = 0
    for i,v in ipairs(tasks) do
        if v:find(meta, 1, true) then
            num = num + 1
        end
    end

    return num
end

function get_project_name(project_id)
    local project = get_project(project_id)

    if project ~= nil then
        return project.name
    else
        return "All projects"
    end
end

function get_project_color(project_id)
    local project = get_project(project_id)

    if project ~= nil then
        return todoist_colors[project.color]
    else
        return fmt.primary()
    end
end

function get_section_name(id)
    for i,v in ipairs(sections) do
        if v.id == id then
            return v.name
        end
    end
end

function insert_tasks(tab, pr, sec)
    local is_sec = true

    table.sort(tasks, function (a,b)
        return a.order < b.order
    end)

    for i,v in ipairs(tasks) do
        if ((pr == v.project_id) or (pr == 0)) and (sec == v.section_id) and (not v.parent) and not v.completed then
            if is_sec and sec ~= 0 then
                table.insert(tab, "<b><i>" .. get_section_name(sec) .. "</i></b>")
                table.insert(lines_id, sec)
                is_sec = false
            end

            local line = task_text(v)..task_date(v)

            table.insert(tab, "%%mkd%%"..line)
            table.insert(lines_id, v.id)

            tab = insert_subtasks(tab, v.id, 1)
        end
    end
    return tab
end

function insert_subtasks(tab, id, lev)
    local curr_time = os.time()

    for i,v in ipairs(tasks) do
        if (v.parent_id == id) and not v.completed then
            local line = task_text(v)..task_date(v)

            for i = 1, lev do
                line = "&nbsp;&nbsp;&nbsp;&nbsp;"..line
            end

            table.insert(tab, "%%mkd%%"..line)
            table.insert(lines_id, v.id)

            tab = insert_subtasks(tab, v.id, lev + 1)
        end
    end
    return tab
end

function open_task(task_id)
    local t = find_task(task_id)
    if t == nil then return end

    dialog_id = "task"
    task = t.id

    local color = 6
    if t.priority > 1 then
        color = 5 - t.priority
    end

    local text = t.content
    if t.description ~= nil then
        text = t.content.."\n"..t.description
    end

    ui:show_rich_editor{
        text = text,
        date = iso8601_datetime_to_local(t.created),
        due_date = parse_due_date(t.due),
        colors = colors,
        color = color,
        new = false
    }
end

function on_dialog_task(res)
    if res == -1 then
        api_delete_task(task)
    else
        local body = create_task_json(res)
        api_edit_task(task, body)
    end
end

function create_task()
    dialog_id = "create"

    ui:show_rich_editor{
        due_date = 0,
        colors = colors,
        color = 6
    }
end

function on_dialog_create(res)
    local project = tonumber(settings:get()[2])
    local body = create_task_json(res, project)

    api_create_task(body)
end

function on_long_click(idx)
    open_context_menu(lines_id[idx])
end

function open_context_menu(id)
    for i,v in ipairs(tasks) do
        if v.id == id then
            dialog_id = "task"
            task = v.id

            local menu = {
                { "check", "Done" },
                { "trash", "Delete" },
                { "share", "Share" },
            }

            if v.due ~= nil then
                if v.due.datetime ~= nil then
                    concat_tables(menu, {
                        { "clock", "Add hour" },
                        { "clock", "Add day" },
                        { "clock", "Add week" },
                        { "clock", "Add month" },
                    })
                elseif v.due.date ~= nil then
                    concat_tables(menu, {
                        { "ban", "Add hour" },
                        { "clock", "Add day" },
                        { "clock", "Add week" },
                        { "clock", "Add month" },
                    })
                end
            end

            ui:show_context_menu(menu)
            return
        end
    end
    for i,v in ipairs(sections) do
        if v.id == id then
            dialog_id = "section"
            task = v.id
            ui:show_context_menu{
                { "trash", "Delete" }
            }
            return
        end
    end
    for i,v in ipairs(projects) do
        if (v.id == id) and (get_project_name(id) ~= "Inbox") then
            dialog_id = "project"
            task = v.id
            ui:show_context_menu{
                { "trash", "Delete" }
            }
            return
        end
    end

    ui:show_context_menu{
        { "repeat", "Refresh" }
    }
end

function on_context_menu_click(idx)
    if dialog_id == "task" then
        if idx == 1 then
            api_close_task(task)
        elseif idx == 2 then
            api_delete_task(task)
        elseif idx == 3 then
            share_task(task)
        elseif idx == 4 then
            increase_task_time(task, hour)
        elseif idx == 5 then
            increase_task_time(task, day)
        elseif idx == 6 then
            increase_task_time(task, week)
        elseif idx == 7 then
            increase_task_time(task, "month")
        end
    elseif dialog_id == "section" then
        api_delete_section(task)
    elseif dialog_id == "project" then
        api_delete_project(task)
    else
        on_alarm()
    end
end

function increase_task_time(task_id, added)
    local task = find_task(task_id)
    local date = parse_due_date(task.due)
    local new_date = 0

    if added == "month" then
        new_date = add_month(date)
    else
        new_date = date + added
    end

    local body = edit_task_time_json(task, new_date)
    api_edit_task(task_id, body)
end

function share_task(task_id)
    local task = find_task(task_id)
    if task == nil then return end

    system:share_text(task.content)
end

function on_dialog_action(res)
    if res == -1 and dialog_id ~= "task" then
        return
    end

    if dialog_id == "settings" then
        on_dialog_settings(res)
    elseif dialog_id == "projects" then
        on_dialog_projects(res)
    elseif dialog_id == "task" then
        on_dialog_task(res)
    elseif dialog_id == "create" then
        on_dialog_create(res)
    end
end

function on_network_result_close(res, err)
    if err == 204 then
        ui:show_toast("Task closed!")
        on_alarm()
        return
    end

    ui:show_toast("There was an error closing the task!")
end

function on_network_result_delete(res, err)
    if err == 204 then
        ui:show_toast("Task deleted!")
        on_alarm()
        return
    end

    ui:show_toast("There was an error deleting the task!")
end

function on_network_result_delete_sec(res, err)
    if err == 204 then
        ui:show_toast("Section deleted!")
        on_alarm()
        return
    end

    ui:show_toast("There was an error deleting the section!")
end

function on_network_result_delete_pr(res, err)
    if err == 204 then
        ui:show_toast("Project deleted!")
        local args = settings:get()
        args[2] = 0
        settings:set(args)
        on_alarm()
        return
    end
    ui:show_toast("There was an error deleting the project!")
end

function on_network_result_create(res, err)
    if err == 200 then
        ui:show_toast("Task created!")
        on_alarm()
        return
    end

    ui:show_toast("There was an error creating the task!")
end

function on_network_result_task(res, err)
    if err == 204 then
        ui:show_toast("Task updated!")
        on_alarm()
        return
    end

    ui:show_toast("There was an error updating the task!")
end

function on_network_error_create() show_no_connection() end
function on_network_error_task() show_no_connection() end
function on_network_error_close() show_no_connection() end
function on_network_error_delete() show_no_connection() end
function on_network_error_delete_sec() show_no_connection() end
function on_network_error_delete_pr() show_no_connection() end

function show_no_connection()
    ui:show_toast("No connection!")
end

-- Utils

function concat_tables(t1, t2)
    for _,v in ipairs(t2) do
        table.insert(t1, v)
    end
end

function find_task(task_id)
    for i,v in ipairs(tasks) do
        if v.id == task_id then
            return v
        end
    end

    return nil
end

function get_project(project_id)
    for i,v in ipairs(projects) do
        if project_id == v.id then
            return v
        end
    end
    return nil
end

function edit_task_time_json(task, date)
    local body = {}

    if task.due.datetime ~= nil then
        body = {
            due_datetime = to_iso8601_datetime(date)
        }
    else
        body = {
            due_date = to_iso8601_date(date)
        }
    end

    return json.encode(body)
end

function create_task_json(res, project)
    local text_tab = res.text:split("\n")
    local content = text_tab[1]
    local desc = table.concat(text_tab, "\n", 2)

    local body = {
        content = content,
        description = desc,
        priority = 1,
    }

    if res.color < 6 then
        body.priority = 5 - res.color
    end

    if res.due_date ~= 0 then
        if os.date("%H:%M", res.due_date) == "00:00" then
            body.due_date = to_iso8601_date(res.due_date)
        else
            body.due_datetime = to_iso8601_datetime(res.due_date)
        end
    end

    if project ~= nil and project > 0 then
        body.project_id = project
    end

    return json.encode(body)
end

function task_text(v)
    local due_date = parse_due_date(v.due)
    local color = color_by_priority(v.priority)

    return fmt.colored(dot.." "..v.content, color)
end

function task_date(v)
    local due_date = parse_due_date(v.due)

    if due_date == nil then
        return ""
    end

    local date = ""
    local time = ""
    local meta = ""
    local str_end = ""

    if is_today(due_date) then
        date = "today"
        meta = today_meta
    else
        date = os.date("%d %b", due_date)
    end

    if is_all_day(due_date) then
        time = ""
    else
        time = ", "..os.date("%H:%M", due_date)
    end

    if is_overdue(due_date) then
        meta = meta..overdue_meta
        date = fmt.red(date)
        time = fmt.red(time)
        str_end = exclamation
    end

    return fmt.secondary(" - "..date..time)..meta..str_end
end

function is_today(date)
    return os.date("%d %b") == os.date("%d %b", date)
end

function is_all_day(date)
    return os.date("%H:%M", date) == "00:00"
end

function is_overdue(due_date)
    if due_date == nil then return end

    if is_all_day(due_date) then
        return due_date + day < os.time()
    else
        return due_date < os.time()
    end
end

function color_by_priority(priority)
    local color = ui:get_colors().primary_text

    if priority > 1 then
        color = colors[5 - priority]
    end

    return color
end

function parse_due_date(due)
    if due ~= nil then
        if due.datetime ~= nil then
            return iso8601_datetime_to_local(due.datetime)
        elseif due.date ~= nil then
            return parse_iso8601_date(due.date)
        end
    end

    return nil
end

function to_iso8601_datetime(date)
    return os.date("%Y-%m-%dT%H:%M:00Z", date - system:get_tz_offset())
end

function to_iso8601_date(date)
    return os.date("%Y-%m-%d", date)
end

function iso8601_datetime_to_local(datetime)
    local offset = 0
    if datetime:find('Z') then
        offset = system:get_tz_offset()
    end
    return parse_iso8601_datetime(datetime) + offset
end

function parse_iso8601_datetime(json_date)
    local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%+%-]?)(%d?%d?)%:?(%d?%d?)"
    local year, month, day, hour, minute,
        seconds, offsetsign, offsethour, offsetmin = json_date:match(pattern)
    local timestamp = os.time{year = year, month = month,
        day = day, hour = hour, min = minute, sec = seconds}
    local offset = 0
    if offsetsign ~= '' and offsetsign ~= 'Z' then
      offset = tonumber(offsethour) * 60 + tonumber(offsetmin)
      if xoffset == "-" then offset = offset * -1 end
    end

    return timestamp + offset * 60
end

function parse_iso8601_date(json_date)
    local pattern = "(%d+)%-(%d+)%-(%d+)"
    local year, month, day, hour = json_date:match(pattern)
    return os.time{year = year, month = month, day = day, hour = 0, min = 0, sec = 0}
end

function add_month(date)
    local date_tab = os.date("*t", date)

    if date_tab.month == 12 then
        date_tab.month = 1
        date_tab.year = date_tab.year + 1
    else
        date_tab.month = date_tab.month + 1
    end

    local max_days = get_days_in_month(date_tab.month, date_tab.year)

    if date_tab.day > max_days then
        date_tab.day = max_days
    end

    return os.time(date_tab)
end

function get_days_in_month(mnth, yr)
    return os.date('*t',os.time{year=yr,month=mnth+1,day=0})['day']
end

-- Todoist API

local base_uri = "https://api.todoist.com/rest/v1/"

function api_set_token(token)
    http:set_headers{ "Authorization: Bearer "..token }
end

function api_get_projects()
    http:get(base_uri.."projects", "projects")
end

function api_get_sections()
    http:get(base_uri.."sections", "sections")
end

function api_get_tasks()
    http:get(base_uri.."tasks", "tasks")
end

function api_create_task(body)
    http:post(base_uri.."tasks/", body, "application/json", "create")
end

function api_delete_task(task_id)
    http:delete(base_uri.."tasks/"..task_id, "delete")
end

function api_edit_task(task_id, body)
    http:post(base_uri.."tasks/"..task_id, body, "application/json", "task")
end

function api_close_task(task_id)
    http:post(base_uri.."tasks/"..task_id.."/close", "", "application/json", "close")
end

function api_delete_section(task_id)
    http:delete(base_uri.."sections/"..task_id, "delete_sec")
end

function api_delete_project(task_id)
    http:delete(base_uri.."projects/"..task_id, "delete_pr")
end

-- Todoist colors

todoist_colors = {
    [30] = "#b8256f",
    [31] = "#db4035",
    [32] = "#ff9933",
    [33] = "#fad000",
    [34] = "#afb83b",
    [35] = "#7ecc49",
    [36] = "#299438",
    [37] = "#6accbc",
    [38] = "#158fad",
    [39] = "#14aaf5",
    [40] = "#96c3eb",
    [41] = "#4073ff",
    [42] = "#884dff",
    [43] = "#af38eb",
    [44] = "#eb96eb",
    [45] = "#e05194",
    [46] = "#ff8d85",
    [47] = "#808080",
    [48] = "#b8b8b8",
    [49] = "#ccac93",
}
