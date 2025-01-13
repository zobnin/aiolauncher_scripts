-- name = "Meta widget"
-- description = "Widget of widgets"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"

local widgets = {
    "text [TEXT]",
    "battery",
    "notes [NUM]",
    "exchange [NUM] [FROM] [TO]",
    "worldclock [TIME_ZONE]",
    "calendar [NUM]",
    "bitcoin",
    "traffic",
    "alarm",
    "tasks [NUM]",
    "memory",
    "storage",
    "weather [NUM]",
    "notify [NUM]",
    "screen",
    "dialogs [NUM]",
    "player",
    "health",
    "space [NUM]"
}

table.sort(widgets)

function on_resume()
    if not metawidget then
        if not files:read("metawidget") then
            metawidget = {"text Metawidget"}
            redraw()
            return
        end
    end
    metawidget = load("return " .. files:read("metawidget"))()
    ui:build(metawidget)
end

function on_settings()
    dialog_id = "settings"
    ui:show_radio_dialog("Select action", {"Add widget", "Remove widget", "Move widget", "Edit widget", "Edit metawidget"})
end

function on_dialog_action(res)
    if dialog_id == "settings" then
        if res == 1 then
            dialog_id = "add"
            ui:show_radio_dialog("Add widget", widgets)
        elseif res == 2 then
            dialog_id = "remove"
            ui:show_radio_dialog("Remove widget", metawidget)
        elseif res == 3 then
            dialog_id = "move"
            ui:show_radio_dialog("Move widget", metawidget)
        elseif res == 4 then
            dialog_id = "edit"
            ui:show_radio_dialog("Edit widget", metawidget)
        elseif res == 5 then
            dialog_id = "metaedit"
            ui:show_rich_editor({text = "{\n\"" .. table.concat(metawidget, "\",\n\"") .. "\",\n}", new = true})
        else
            dialog_id = ""
        end
    elseif dialog_id == "add" then
        dialog_id = ""
        if res ~= -1 then
            add_widget(res)
        end
    elseif dialog_id == "remove" then
        dialog_id = ""
        if res ~= -1 then
            remove_widget(res)
        end
    elseif dialog_id == "move" then
        if res == -1 then
            dialog_id = ""
        else
            dialog_id = "move_line"
            pos = res
            ui:show_radio_dialog("Remove widget", {"Up", "Down"})
        end
    elseif dialog_id == "edit" then
        if res == -1 then
            dialog_id = ""
        else
            dialog_id = "edit_line"
            pos = res
            ui:show_edit_dialog("Edit widget", "", metawidget[res])
        end
    elseif dialog_id == "metaedit" then
        dialog_id = ""
        if res ~= -1 then
            metawidget = load("return " .. res.text)()
            redraw()
        end
    elseif dialog_id == "add_line" then
        dialog_id = ""
        if (res ~= -1) and (res ~= "") then
            table.insert(metawidget, res)
            redraw()
        end
    elseif dialog_id == "move_line" then
        dialog_id = ""
        if res ~= -1 then
            move_widget(res)
        end
    elseif dialog_id == "edit_line" then
        dialog_id = ""
        if res ~= -1 then
            if res == "" then
                remove_widget(pos)
            else
                metawidget[pos] = res
                redraw()
            end
        end
    else
        return
    end
end

function add_widget(res)
    local lines = widgets[res]:split(" ")
    local line = lines[1]
    if line == widgets[res] then
        table.insert(metawidget, line)
        redraw()
    else
        dialog_id = "add_line"
        ui:show_edit_dialog("Enter parameters" .. widgets[res]:replace(line, ""), widgets[res], line .. " ")
    end
end

function remove_widget(res)
    table.remove(metawidget, res)
    redraw()
end

function move_widget(res)
    if res == 1 then
        if pos == 1 then
            return
        else
            local line = metawidget[pos]
            metawidget[pos] = metawidget[pos - 1]
            metawidget[pos - 1] = line
        end
    else
        if pos == #metawidget then
            return
        else
            local line = metawidget[pos]
            metawidget[pos] = metawidget[pos + 1]
            metawidget[pos + 1] = line
        end
    end
    redraw()
end

function redraw()
    files:write("metawidget", "{\n\"" .. table.concat(metawidget, "\",\n\"") .. "\",\n}")
    on_resume()
end
