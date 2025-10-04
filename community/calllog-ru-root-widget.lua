-- name = "История вызовов"
-- description = "Скрипт показывает историю вызов через прямое чтение базы звонков"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.1"
-- lang = "ru"
-- root = "true"

local types = {"Входящие","Исходящие","Пропущенные","Отменённые","Отклонённые","Заблокированные","Все"}

local tab = {}
local typ = 3

function on_resume()
    redraw()
end

function redraw()
    local cmd = "content query --uri content://call_log/calls --projection date:number:name:type:duration --sort \"date desc limit 10\""
    if typ == 4 then
        cmd = cmd.." --where \"type=2 and duration=0\""
    elseif typ ~= 7 then
        cmd = cmd.." --where \"type="..typ.."\""
    end
    system:su(cmd)
end

function on_shell_result(res)
    if res:sub(1,8) == "Starting" or res == "No result found." then
        return
    end
    local text = res
    text = text:gsub("^Row:%s%d+%s","{{")
    text = text:gsub("%sRow:%s%d+%s","\"},{")
    text = text:gsub("=","=\"")
    text = text:gsub(",%s","\",")
    text = text.."\"}}"
    tab = load("return "..text)()
    local tab1,tab2,row,rows = {},{},{},{}
    local colors = ui:get_colors()
    local md_colors = require "md_colors"
    for i,v in ipairs(tab) do
        local dir = " "
        if v.type == "1" then
            dir = "<b><font color=\""..colors.progress.."\">⬃</font></b>"
        elseif v.type == "2" then
            if v.duration == "0" then
                dir = "<b><font color=\""..md_colors.orange_600.."\">⬀</font></b>"
            else
                dir = "<b><font color=\""..colors.progress_good.."\">⬀</font></b>"
            end
        elseif v.type == "3" then
            dir = "<b><font color=\""..colors.progress_bad.."\">⬃</font></b>"
        elseif v.type == "5" then
            dir = "<b><font color=\""..md_colors.orange_600.."\">⬃</font></b>"
        elseif v.type == "6" then
            dir = "<b><font color=\""..colors.secondary_text.."\">⬃</font></b>"
        end
        table.insert(row,dir)
        if v.name == "NULL" then
            table.insert(row,v.number)
        else
            table.insert(row,v.name)
        end
        table.insert(row,"<font color=\""..colors.secondary_text.."\">"..os.date("%H:%M - %d.%m",math.floor(v.date/1000)).."</font>")
        table.insert(rows,row)
        row = {}
    end
    table.insert(row," ")
    table.insert(row,"<font color=\""..colors.secondary_text.."\">Выберите тип</<font>")
    table.insert(row," ")
    table.insert(rows,row)
    ui:set_title(ui:get_default_title().." ("..types[typ]..")")
    ui:show_table(rows,2)
end

function on_click(idx)
    if math.ceil(idx/3) > #tab then
        dialogs:show_radio_dialog("Выберите тип вызовов",types,typ)
    else
        local cmd = "am start -a android.intent.action.DIAL -d tel:"..tab[math.ceil(idx/3)].number
        system:exec(cmd)
    end
end

function on_long_click(idx)
    if math.ceil(idx/3) > #tab then
        return
    end
    phone:make_call(tab[math.ceil(idx/3)].number)
end

function on_dialog_action(idx)
    if idx == -1 then
        return
    end
    typ = idx
    redraw()
end

function on_settings()
    return
end
