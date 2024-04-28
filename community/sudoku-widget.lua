-- name = "Sudoku"
-- description = "Sudoku games"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"

local json = require "json"
local folded = "Sudoku"

function tab_to_tabs(tab)
    local tab_in = tab
    local tab_out = {}
    local row = {}
    for i,v in ipairs(tab_in) do
        table.insert(row,v)
        if #row == 9 then
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
        table.insert(v,5,"│")
        table.insert(v,9,"│")
        table.insert(v,13,"│")
    end
    table.insert(t,1,{"┌","─","─","─","┬","─","─","─","┬","─","─","─","┐"})
    table.insert(t,5,{"├","─","─","─","┼","─","─","─","┼","─","─","─","┤"})
    table.insert(t,9,{"├","─","─","─","┼","─","─","─","┼","─","─","─","┤"})
    table.insert(t,13,{"└","─","─","─","┴","─","─","─","┴","─","─","─","┘"})
    return t
end

function desk_to_tabs(tab)
    local t = tab
    table.remove(t,13)
    table.remove(t,9)
    table.remove(t,5)
    table.remove(t,1)
    for i,v in ipairs(t) do
        table.remove(v,13)
        table.remove(v,9)
        table.remove(v,5)
        table.remove(v,1)
    end
    return t
end

function on_alarm()
    on_resume()
end

function on_resume()
    if (not files:read("sudoku")) or (not json.decode(files:read("sudoku")).mask) then
        reload()
    else
        redraw()
    end
end

function reload()
    local sudoku = matrix_create()
    files:write("sudoku",json.encode(sudoku))
    redraw()
end

function validate()
    local sudoku = json.decode(files:read("sudoku"))
    local state = "Solved"
    for i = 1, #sudoku.mask do
        if (sudoku.matrix[i] ~= sudoku.mask[i]) and (sudoku.mask[i] ~= 0) then
            state = "Wrong"
            break
        elseif sudoku.mask[i] == 0 then
            state = "Unsolved"
        end
    end
    ui:show_toast(state)
end

function solve()
    local sudoku = json.decode(files:read("sudoku"))
    sudoku.mask = sudoku.matrix
    files:write("sudoku",json.encode(sudoku))
    redraw()
end

function redraw()
    local tab = tabs_to_desk(tab_to_tabs(json.decode(files:read("sudoku")).mask))
    ui:show_table(tab, 0, true, folded)
end

function on_click(idx)
    if idx == 0 then
        dialog_id = "menu"
        ui:show_radio_dialog("Select Action",{"Reload","Validate","Solve"})
        return
    end
    x = math.ceil(idx/13)
    y = idx%13
    if y == 0 then y = 13 end
    local tab = tabs_to_desk(tab_to_tabs(json.decode(files:read("sudoku")).mask))
    if type(tab[x][y]) == "number" then
        dialog_id = "number"
        ui:show_radio_dialog("Select Number",{1,2,3,4,5,6,7,8,9},tab[x][y])
    end
end

function on_settings()
end

function on_dialog_action(idx)
    if idx == -1 then
        return
    end
    if dialog_id == "number" then
        local sudoku = json.decode(files:read("sudoku"))
        local tab = tabs_to_desk(tab_to_tabs(sudoku.mask))
        tab[x][y] = idx
        local mask = tabs_to_tab(desk_to_tabs(tab))
        sudoku.mask = mask
        files:write("sudoku",json.encode(sudoku))
        redraw()
    elseif dialog_id == "menu" then
        if idx == 1 then
            reload()
        elseif idx == 2 then
            validate()
        elseif idx == 3 then
            solve()
        end
    end
end

function matrix_create()
    local sudoku = {}
    local t = {}
    local m = {}
    local tmp
    for i = 1, 81 do
        t[i] = 0
    end
    for i = 0, 8 do
        for j = 1, 9 do
            t[i * 9 + j] = (i * 3 + math.floor( i / 3 ) + ( j - 1) ) % 9 + 1
        end
    end
    for i = 1, 42 do
        local n1 = math.random( 9 )
        local n2
        repeat
            n2 = math.random( 9 )
        until n1 ~= n2
        for row = 0, 8 do
            for col = 1, 9 do
                if t[row * 9 + col] == n1 then
                    t[row * 9 + col] = n2
                elseif(t[row * 9 + col] == n2) then
                    t[row * 9 + col] = n1
                end
            end
        end
    end
    for c = 1, 42 do
        local s1 = math.random( 2 )
        local s2 = math.random( 2 )
        for row = 0, 8 do
            tmp = t[row * 9 + (s1 * 3 + c % 3)]
            t[row * 9 + (s1 * 3 + c % 3)] = t[row * 9 + (s2 * 3 + c % 3)]
            t[row * 9 + (s2 * 3 + c % 3)] = tmp
        end
    end
    for s = 1, 42 do
        local c1 = math.random( 2 )
        local c2 = math.random( 2 )
        for row = 0, 8 do
            tmp = t[row * 9 + (s % 3 * 3 + c1)]
            t[row * 9 + (s % 3 * 3 + c1)] = t[row * 9 + (s % 3 * 3 + c2)]
            t[row * 9 + (s % 3 * 3 + c2)] = tmp
        end
    end
    for s = 1, 42 do
        local r1 = math.random( 2 )
        local r2 = math.random( 2 )
        for col = 1, 9 do
            tmp = t[(s % 3 * 3 + r1) * 9 + col]
            t[(s % 3 * 3 + r1) * 9 + col] = t[(s % 3 * 3 + r2) * 9 + col]
            t[(s % 3 * 3 + r2) * 9 + col] = tmp
        end
    end
    for i = 1, 81 do
        m[i] = t[i]
    end
    for i = 0, 2 do
        for j = 1, 3 do
            for k = 1, 5 do
                local c
                repeat
                    c = math.random( 9 ) - 1
                until m[(i * 3 + math.floor(c / 3)) * 9 + j * 3 + c % 3] ~= 0
                m[(i * 3 + math.floor(c / 3)) * 9 + j * 3 + c % 3] = 0
            end
        end
    end
    sudoku.matrix = t
    sudoku.mask = m
    return sudoku
end
