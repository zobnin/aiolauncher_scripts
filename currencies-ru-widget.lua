-- name = "Курсы валют"
-- description = "Виджет курсов валют. Нажмите на дату чтобы изменить ее."
-- dataSource = "https://github.com/fawazahmed0/currency-api#readme"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"
-- argumentsHelp = "Введите список валютных пар в формате usd:rub btc:usd"
-- argumentsDefault = "usd:rub eur:rub"

stringx = require 'pl.stringx'

function onAlarm()
    curs = aio:getArgs()

    if curs == nil then
        curs = {"usd:rub", "eur:rub"}
    end

    getRates("latest")
end

function getRates(locDate)
    net:getText("https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/"..locDate.."/currencies/usd.json")
end

function onNetworkResult(result)
    local dat = json:getValue(result, "object string:date")
    local tab = {}

    table.insert(tab, "<font color=\""..ui:getSecondaryTextColor().."\">"..dat.."</font>")

    for idx = 1, #curs, 1 do
        local equals = "<font color=\""..ui:getSecondaryTextColor().."\"> = </font>"
        local cur = stringx.split(curs[idx], ":")
        local cur1 = cur[1]
        local cur2 = cur[2]
        local rate1 = json:getValue(result, "object object:usd double:"..cur1)
        local rate2 = json:getValue(result, "object object:usd double:"..cur2)
        local rate = math.floor(rate2/rate1*10000+0.5)/10000
        table.insert(tab, "1 "..string.upper(cur1)..equals..rate.." "..string.upper(cur2))
    end

    ui:showLines(tab)
end

function onClick(idx)
    if idx == 1 then
        ui:showEditDialog("Введите дату курсов", "Введите дату курсов в формате 2020-12-31. Пустое значение - текущая дата.")
    end
end

function onDialogAction(text)
    if text == "" then
        text = "latest"
    end

    getRates(text)
end
