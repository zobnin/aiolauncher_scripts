-- name = "Notes"
-- description = "Notes widget"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"

local json = require "json"

local diag_id = ""
local id = 0

function on_alarm()
    if files:read("notes") == nil then
        files:write("notes",json.encode({}))
    end
    local notes = json.decode(files:read("notes"))
    local buttons = {}
    local colors = {}
    for i,v in ipairs(notes) do
        local utf8 = require "utf8"
        local button = utf8.sub(v.text:match("^(.+)\n") or v.text,1,15)
        table.insert(buttons,button)
        table.insert(colors,v.color)
    end
    local color = aio:colors()
    table.insert(buttons,"+")
    table.insert(colors,color.secondary_text)
    ui:show_buttons(buttons,colors)
end

function on_click(idx)
    local notes = json.decode(files:read("notes"))
    if idx > #notes then
        ui:show_edit_dialog("New note")
        diag_id = "new"
    else
        ui:show_dialog("Note", json.decode(files:read("notes"))[idx].text:replace("\n","<br>"), "Edit", "Delete")
        diag_id = "read"
        id = idx
    end
end

function on_dialog_action(data)
    if data ~= -1 then
        if diag_id == "new" then
            if data ~= "" then
                local color = aio:colors()
                local note = {}
                note.text = data
                note.color = color.button
                local notes = json.decode(files:read("notes"))
                table.insert(notes,note)
                files:write("notes",json.encode(notes))
                on_alarm()
            end
        elseif diag_id == "read" then
            if data == 1 then
                ui:show_edit_dialog("Edit","",json.decode(files:read("notes"))[id].text)
                diag_id = "edit"
            else
                local notes = json.decode(files:read("notes"))
                table.remove(notes,id)
                files:write("notes",json.encode(notes))
                on_alarm()
            end
        elseif diag_id == "edit" then
            if data ~= "" then
                local notes = json.decode(files:read("notes"))
                notes[id].text = data
                files:write("notes",json.encode(notes))
                on_alarm()
            end
        end
    end
end

function on_long_click(idx)
    local notes = json.decode(files:read("notes"))
    if idx > #notes then
        return
    end
    id = idx
    ui:show_context_menu({{"angle-left","Up"},{"share-alt","Share"},{"angle-right","Down"},{"circle","Default"},{"circle","Red"},{"circle","Blue"},{"circle","Green"}})
end

function on_context_menu_click(idx)
    local md_color = require "md_colors"
    local color = aio:colors()
    if idx == 1 then
        move(-1)
    elseif idx == 2 then
        system:share_text(json.decode(files:read("notes"))[id].text)
    elseif idx == 3 then
        move(1)
    elseif idx == 4 then
        update_color(color.button)
    elseif idx == 5 then
        update_color(md_color.red_500)
    elseif idx == 6 then
        update_color(md_color.blue_500)
    elseif idx == 7 then
        update_color(md_color.green_500)
    end
end

function update_color(col)
    local notes = json.decode(files:read("notes"))
    notes[id].color = col
    files:write("notes",json.encode(notes))
    on_alarm()
end

function move(x)
    local notes = json.decode(files:read("notes"))
    if id+x < 1 or id+x > #notes then
        return
    end
    local note = notes[id]
    table.remove(notes,id)
    table.insert(notes,id+x,note)
    files:write("notes",json.encode(notes))
    on_alarm()
end
