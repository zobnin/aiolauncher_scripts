-- name = "Currency"
-- description = "A currency widget. Click on the widget to change the currency. The base currency and date are changed in the context menu."
-- data_source = "https://github.com/fawazahmed0/currency-api#readme"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"

local json = require "json"
local color = require "md_colors"
local text_color = ui:get_secondary_text_color()
local equals = "<font color=\""..text_color.."\"> = </font>"

-- constants
local curs = {"usd", "eur", "gbp", "chf", "aed", "cny", "inr", "btc"}
local base_curs = {"rub", "usd"}

-- vars
local dialog_id = ""
local cur = curs[1]
local base_cur = base_curs[1]
local date = "latest"
local rate = 0

function on_alarm()
    get_rates(date, "curr")
end

function get_rates(date, id)
    http:get("https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/"..date.."/currencies/"..cur.."/"..base_cur..".min.json",id)
end

function on_network_result_curr(result)
    local dat = ajson:get_value(result, "object string:date")
    rate = ajson:get_value(result, "object double:"..base_cur)
    ui:set_title(ui:get_default_title().." ("..format_date(dat)..")")
    get_rates(prev_date(dat), "prev")
end

function on_network_result_prev(result)
    local line = "1 "..string.upper(cur)..equals..round(rate, 4).." "..string.upper(base_cur)
    local prev_rate = ajson:get_value(result, "object double:"..base_cur)
    local change = (rate - prev_rate)/rate*100
    line = line..get_formatted_change_text(round(change, 2))
    ui:show_text(line)
    ui:prepare_context_menu({{"copy","Копировать"},{"ruble-sign","Базовая валюта"},{"calendar-alt","Дата курса"}})
end

function on_click(idx)
    dialog_id = "cur"
    ui:show_checkbox_dialog("Выберите валюту", curs, 1)
end

function on_dialog_action(data)
    if data ~= -1 then
        if dialog_id == "date" then
            if data == "" then
                date = "latest"
            elseif data == data:match("[0-3]?%d%.[0-1]?%d%.[1-2]%d%d%d") then
                date = unformat_date(data)
            end
        elseif dialog_id == "cur" then
            cur = curs[data]
        elseif dialog_id == "base_cur" then
            base_cur = base_curs[data]
        end
        on_alarm()
    end
end

function on_context_menu_click(item_idx, menu_idx)
    if menu_idx == 3 then
        dialog_id = "date"
        ui:show_edit_dialog("Введите дату курса", "Формат даты - 31.12.2020. Пустое значение - текущая дата", "")
    elseif menu_idx == 2 then
        dialog_id = "base_cur"
        ui:show_checkbox_dialog("Выберите базовую валюту", base_curs, 1)
    elseif menu_idx == 1 then
        system:copy_to_clipboard(rate)
    end
end

-- утилиты --
function get_formatted_change_text(change)
    if change > 0 then
        return "<font color=\""..color.green_700.."\"> +"..change.."%</font>"
    elseif change < 0 then
        return "<font color=\""..color.red_A700.."\"> "..change.."%</font>"
    else
        return "<font color=\""..text_color.."\"> "..change.."%</font>"
    end
end

function format_date(dat)
    local y, m, d = dat:match("(%d+)-(%d+)-(%d+)")
    return os.date("%d.%m.%Y", os.time{year=tonumber(y), month=tonumber(m), day=tonumber(d)})
end

function unformat_date(dat)
    local d, m, y = dat:match("(%d+)%.(%d+)%.(%d+)")
    return os.date("%Y-%m-%d", os.time{year=tonumber(y), month=tonumber(m), day=tonumber(d)})
end

function prev_date(dat)
    local y, m, d = dat:match("(%d+)-(%d+)-(%d+)")
    return os.date("%Y-%m-%d", os.time{year=tonumber(y), month=tonumber(m), day=(d)} - (60*60*24))
end
