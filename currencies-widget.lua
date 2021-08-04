-- name = "Курсы валют"
-- description = "Виджет курсов валют. Нажмите на дату чтобы изменить ее."
-- data_source = "https://github.com/fawazahmed0/currency-api#readme"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"
-- arguments_help = "Введите список валютных пар в формате usd:rub btc:usd"
-- arguments_default = "usd:rub eur:rub"

local sx = require "pl.stringx"
local json = require "json"

-- constants
local red_color = "#f44336"
local green_color = "#48ad47"
local text_color = ui:get_secondary_text_color()
local equals = "<font color=\""..text_color.."\"> = </font>"

-- global vars
local result_curr = ""
local tabl = {}

function on_resume()
    ui:set_folding_flag(true)
    ui:show_lines(tabl)
end

function on_alarm()
    get_rates("latest", "curr")
end

function get_rates(loc_date,id)
    http:get("https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/"..loc_date.."/currencies/usd.json",id)
end

function on_network_result_curr(result)
   result_curr = result
   
   local t = json.decode(result)
   local dat = t.date
   local prev_date = prev_date(dat)

   get_rates(prev_date, "prev")
end

function on_network_result_prev(result)
    tabl = create_tab(result)
    ui:show_lines(tabl)
end

function on_click(idx)
    ui:show_edit_dialog("Введите дату курсов", "Введите дату курсов в формате 2020.12.31. Пустое значение - текущая дата.")
end

function on_dialog_action(dat)
    if dat == "" then dat = "latest" end
    get_rates(sx.replace(dat, ".", "-"), "curr")
end

function prev_date(dat)
    local prev_date = sx.split(dat, "-")
    local prev_time = os.time{year=prev_date[1], month=prev_date[2], day=prev_date[3]} - (60*60*24)
    return os.date("%Y-%m-%d", prev_time)
end

function create_tab(result)
    local curs = aio:get_args()
    local tab = {}
    local t_c = json.decode(result_curr)
    local t_p = json.decode(result)
   
    -- set title
    local dat = t_c.date
    ui:set_title(ui:get_default_title().." "..sx.replace(dat, "-", "."))

    for idx = 1, #curs, 1 do 
        local cur = sx.split(curs[idx], ":")
        
        local rate_curr1 = t_c.usd[cur[1]]
        local rate_curr2 = t_c.usd[cur[2]]
        local rate_prev1 = t_p.usd[cur[1]]
        local rate_prev2 = t_p.usd[cur[2]]

        local rate_curr = round(rate_curr2/rate_curr1, 4)
        local rate_prev = round(rate_prev2/rate_prev1, 4)
        local change = round((rate_curr-rate_prev)/rate_prev*100,2)

        local line = "1 "..string.upper(cur[1])..equals..rate_curr.." "..string.upper(cur[2])
        line = line..get_formatted_change_text(change)

        table.insert(tab, line)
    end
    return tab
end

-- utils --

function get_formatted_change_text(change)
    if change > 0 then
        return "<font color=\""..green_color.."\"><small> +"..change.."%</small></font>"
    elseif change < 0 then
        return "<font color=\""..red_color.."\"><small> "..change.."%</small></font>"
    else
        return "<font color=\""..text_color.."\"><small> "..change.."%</small></font>"
    end
end

function round(x, n)
    local n = math.pow(10, n or 0)
    local x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end
