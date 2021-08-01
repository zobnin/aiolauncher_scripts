-- name = "Курсы валют"
-- description = "Виджет курсов валют. Нажмите на дату чтобы изменить ее."
-- dataSource = "https://github.com/fawazahmed0/currency-api#readme"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"
-- argumentsHelp = "Введите список валютных пар в формате usd:rub btc:usd"
-- argumentsDefault = "usd:rub eur:rub"

sx = require 'pl.stringx'

function on_alarm()
    curs = aio:get_args()

    if curs == nil then
        curs = {"usd:rub", "eur:rub"}
    end

    get_rates("latest")
end

function get_rates(loc_date)
    net:get_text("https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/"..loc_date.."/currencies/usd.json")
end

function on_network_result(result)
    local textColor = ui:get_secondary_text_color()
    local dat = ajson:get_value(result, "object string:date")
    local tab = {}

    table.insert(tab, "<font color=\""..textColor.."\">"..sx.replace(dat, "-", ".").."</font>")

    for idx = 1, #curs, 1 do
        local equals = "<font color=\""..textColor.."\"> = </font>"
        local cur = sx.split(curs[idx], ":")
        local cur1 = cur[1]
        local cur2 = cur[2]
        local rate1 = ajson:get_value(result, "object object:usd double:"..cur1)
        local rate2 = ajson:get_value(result, "object object:usd double:"..cur2)
        local rate = math.floor(rate2/rate1*10000+0.5)/10000
        table.insert(tab, "1 "..string.upper(cur1)..equals..rate.." "..string.upper(cur2))
    end

    ui:show_lines(tab)
end

function on_click(idx)
    if idx == 1 then
        ui:show_edit_dialog("Введите дату курсов", "Введите дату курсов в формате 2020.12.31. Пустое значение - текущая дата.")
    end
end

function on_dialog_action(date)
    if date == "" then
        date = "latest"
    end

    get_rates(sx.replace(date, ".", "-"))
end

