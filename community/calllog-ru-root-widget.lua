-- name = "История вызовов"
-- type = "widget"
-- root = "yes"
-- author = "Andrey Gavrilov"
-- version = "1.0"

local types = {"Входящие","Исходящие","Пропущенные","Отменённые","Отклонённые","Заблокированные","Все"}

local tab = {}
local typ = 3

function on_resume()
    ui:set_folding_flag(true)
    redraw()
end

function redraw()
    local cmd = "content query --uri content://call_log/calls --projection date:number:name --sort \"date desc limit 10\""
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
    local tab1,tab2 = {},{}
    for i,v in ipairs(tab) do
        if v.name == "NULL" then
            table.insert(tab1,v.number)
        else
            table.insert(tab1,v.name.." ["..v.number.."]")
        end
        table.insert(tab2,os.date("%d.%m.%Y %H:%M",math.floor(v.date/1000)))
    end
    table.insert(tab1,types[typ])
    table.insert(tab2,"Выберите тип")
    ui:set_title(ui:get_default_title().." ("..types[typ]..")")
    ui:show_lines(tab1,tab2)
end

function on_click(idx)
    if idx > #tab then
        ui:show_radio_dialog("Выберите тип вызовов",types,typ)
    else
        local cmd = "am start -a android.intent.action.DIAL -d tel:"..tab[idx].number
        system:exec(cmd)
    end
end

function on_long_click(idx)
    if idx > #tab then
        return
    end
    phone:make_call(tab[idx].number)
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
