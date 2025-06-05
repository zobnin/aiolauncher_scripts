-- name = "15 Puzzle"
-- description = "Game"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.1"

local json = require "json"
local folded = "15 puzzle"

function tab_create()
    local tab_in = {"",1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
    local tab_out = {}
    repeat
        local idx = math.random(1,#tab_in)
        table.insert(tab_out,tab_in[idx])
        table.remove(tab_in,idx)
    until #tab_in == 0
    return tab_out
end

function tab_to_tabs(tab)
    local tab_in = tab
    local tab_out = {}
    local row = {}
    for i,v in ipairs(tab_in) do
        table.insert(row,v)
        if #row == math.sqrt(#tab) then
            table.insert(tab_out,row)
            row = {}
        end
    end
    return tab_out
end

function tabs_to_tab(tab)
    local tab_in = tab
    local tab_out = {}
    for i,v in ipairs(tab_in) do
        for ii,vv in ipairs(v) do
            table.insert(tab_out,vv)
        end
    end
    return tab_out
end

function tabs_to_desk(tab)
    local t = tab
    for i,v in ipairs(t) do
        table.insert(v,1,"│")
        table.insert(v,3,"│")
        table.insert(v,5,"│")
        table.insert(v,7,"│")
        table.insert(v,9,"│")
    end
    table.insert(t,1,{"┌","─","┬","─","┬","─","┬","─","┐"})
    table.insert(t,3,{"├","─","┼","─","┼","─","┼","─","┤"})
    table.insert(t,5,{"├","─","┼","─","┼","─","┼","─","┤"})
    table.insert(t,7,{"├","─","┼","─","┼","─","┼","─","┤"})
    table.insert(t,9,{"└","─","┴","─","┴","─","┴","─","┘"})
    return t
end

function desk_to_tabs(tab)
    local t = tab
    table.remove(t,9)
    table.remove(t,7)
    table.remove(t,5)
    table.remove(t,3)
    table.remove(t,1)
    for i,v in ipairs(t) do
        table.remove(v,9)
        table.remove(v,7)
        table.remove(v,5)
        table.remove(v,3)
        table.remove(v,1)
    end
    return t
end

function on_alarm()
    on_resume()
end

function on_resume()
    if (not files:read("fifteen")) or (#json.decode(files:read("fifteen"))~=16) then
        reload()
    else
        redraw()
    end
end

function redraw()
    local tab = tabs_to_desk(tab_to_tabs(json.decode(files:read("fifteen"))))
    ui:show_table(tab, 0, true, folded)
end

function on_click(idx)
    if idx == 0 then
        dialogs:show_dialog("Select Action","","Cancel","Reload")
        return
    else
        local tab = tabs_to_tab(tabs_to_desk(tab_to_tabs(json.decode(files:read("fifteen")))))
        if type(tab[idx]) ~= "number" then
            return
        end
        if tab[idx-2] == "" then
            tab[idx-2] = tab[idx]
            tab[idx] = ""
        elseif tab[idx+2] == "" then
            tab[idx+2] = tab[idx]
            tab[idx] = ""
        elseif (idx-18>0) and (tab[idx-18] == "") then
            tab[idx-18] = tab[idx]
            tab[idx] = ""
        elseif (idx+18<#tab) and (tab[idx+18] == "") then
            tab[idx+18] = tab[idx]
            tab[idx] = ""
        else
            return
        end
        system:vibrate(10)
        tab = tabs_to_tab(desk_to_tabs(tab_to_tabs(tab)))
        files:write("fifteen",json.encode(tab))
        redraw()
    end
end

function on_settings()
end

function reload()
    local tab = tab_create()
    files:write("fifteen",json.encode(tab))
    redraw()
end

function on_dialog_action(idx)
    if idx == 2 then
        reload()
    end
end
