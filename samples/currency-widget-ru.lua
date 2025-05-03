-- name = "Курс валюты"
-- description = "Виджет курса валюты. Нажмите на виджет, чтобы изменить валюту. Базовая валюта и дата меняются в контекстном меню."
-- data_source = "https://exchangerate.host/"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "2.0"
-- lang = "ru"

local json = require "json"
local color = require "md_colors"
local text_color = aio:colors().secondary_text
local equals = "<font color=\""..text_color.."\"> = </font>"

-- константы --
local curs = {"usd", "eur", "gbp", "chf", "aed", "cny", "inr", "btc", "other"}
local curs_n = {"Доллар США", "Евро", "Фунт стерлингов", "Швейцарский франк", "Дирхам ОАЭ", "Китайский юань", "Индийская рупия", "Биткойн", "Другая"}
local base_curs = {"rub", "usd", "other_b"}
local base_curs_n = {"Российский рубль", "Доллар США", "Другая"}

-- переменные --
local dialog_id = ""
local cur_idx = 1
local cur = curs[cur_idx]
local base_cur_idx = 1
local base_cur = base_curs[base_cur_idx]
local date = ""
local line = ""
local tab = {}
local amount = "1"
local rate = 0

function on_alarm()
    date = os.date("%Y-%m-%d")
    get_rates(date)
end

function get_rates(date)
    http:get("https://api.exchangerate.host/fluctuation?start_date="..prev_date(date).."&end_date="..date.."&symbols="..string.upper(base_cur).."&base="..string.upper(cur).."&amount="..amount)
end

function on_network_result(result)
    t = json.decode(result)
    if t.rates[string.upper(base_cur)].end_rate == nil then
        date = prev_date(date)
        get_rates(date)
        return
    end
    rate = round(t.rates[string.upper(base_cur)].end_rate,4)
    local change = round(-t.rates[string.upper(base_cur)].change_pct*100,2)
    line = amount.." "..string.upper(cur).." "..equals.." "..divide_number(rate," ").." "..string.upper(base_cur)..get_formatted_change_text(change)
    tab = {{"ᐊ", amount, string.upper(cur), equals, divide_number(rate," "), string.upper(base_cur), get_formatted_change_text(change), "ᐅ"}}
    ui:show_table(tab, 7)
    ui:set_title(ui:default_title().." ("..date:gsub("(%d+)-(%d+)-(%d+)", "%3.%2.%1")..")")
end

function on_click(idx)
    if idx == 1 then
        date = prev_date(date)
        get_rates(date)
        ui:show_toast("Загрузка")
    elseif idx == 2 then
        dialog_id ="amount"
        ui:show_edit_dialog("Введите количество", "", amount)
    elseif idx == 3 then
        dialog_id = "cur"
        ui:show_radio_dialog("Выберите валюту", curs_n, cur_idx)
    elseif idx == 6 then
        dialog_id = "base_cur"
        ui:show_radio_dialog("Выберите базовую валюту", base_curs_n, base_cur_idx)
    elseif idx == 8 then
        date = next_date(date)
        get_rates(date)
        ui:show_toast("Загрузка")
    else
        dialog_id = "date"
        ui:show_edit_dialog("Введите дату курса", "Формат даты - 31.12.2020. Пустое значение - текущая дата", date:gsub("(%d+)-(%d+)-(%d+)", "%3.%2.%1"))
    end
end

function on_long_click(idx)
  item_idx = idx

  ui:show_context_menu({
    {"share-alt","Поделиться"},
    {"copy","Копировать"},
    {"redo","Перезагрузить"}
  })
end

function on_dialog_action(data)
    if data == -1 then
        return
    end
    if dialog_id == "date" then
        if get_date(date:gsub("(%d+)-(%d+)-(%d+)", "%3.%2.%1")) == get_date(data) then
            return
        end
        date = get_date(data)
    elseif dialog_id == "cur" then
        if data == cur_idx and cur == curs[data] then
            return
        end
        cur_idx = data
        if curs[data] == "other" then
            dialog_id = "other"
            ui:show_edit_dialog("Введите валюту", "", string.lower(cur))
            return
        end
        cur = string.upper(curs[data])
    elseif dialog_id == "base_cur" then
        if data == base_cur_idx and base_cur == base_curs[data] then
            return
        end
        base_cur_idx = data
        if base_curs[data] == "other_b" then
            dialog_id = "other_b"
            ui:show_edit_dialog("Введите базовую валюту", "", string.lower(base_cur))
            return
        end
        base_cur = string.upper(base_curs[data])
    elseif dialog_id == "other" then
        if data == cur then
            return
        end
        cur = string.upper(data)
    elseif dialog_id == "other_b" then
        if data == base_cur then
            return
        end
        base_cur = string.upper(data)
    elseif dialog_id == "amount" then
        if amount == data:gsub(",",".") then
            return
        end
        amount = data:gsub(",","."):gsub("-","")
        if amount == "" then
            amount = "1"
        end
    end
    get_rates(date)
end

function on_context_menu_click(menu_idx)
    if menu_idx == 2 then
        system:copy_to_clipboard(rate)
    elseif menu_idx == 1 then
        system:share_text(date:gsub("(%d+)-(%d+)-(%d+)", "%3.%2.%1").." "..line:gsub("(.+)<.+>(.+)<.+>(.+)<.+>(.+)<.+>", "%1%2%3%4"))
    elseif menu_idx == 3 then
        cur_idx = 1
        cur = string.upper(curs[cur_idx])
        base_cur_idx = 1
        base_cur = string.upper(base_curs[base_cur_idx])
        amount = "1"
        get_rates(os.date("%Y-%m-%d"))
        ui:show_toast("Начальные установки")
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

function prev_date(date)
    local y, m, d = date:match("(%d+)-(%d+)-(%d+)")
    return os.date("%Y-%m-%d", os.time{year=y, month=m, day=d} - (60*60*24))
end

function next_date(date)
    local y, m, d = date:match("(%d+)-(%d+)-(%d+)")
    return os.date("%Y-%m-%d", os.time{year=y, month=m, day=d} + (60*60*24))
end

function divide_number(n, str)
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1'..str):reverse())..right
end

function get_date(date)
    local d, m, Y = date:match("(%d+).(%d+).(%d+)")
    local d0, m0, Y0 = os.date("%d.%m.%Y"):match("(%d+).(%d+).(%d+)")
    local time = os.time{day=d or 0, month=m or 0, year=Y or 0}
    local time0 = os.time{day=d0, month=m0, year=Y0}
    local str = string.format("%04d-%02d-%02d", Y or 0, m or 0, d or 0)
    if not (str == os.date("%Y-%m-%d", time) and time <= time0 - 24*60*60) then
        str = os.date("%Y-%m-%d")
    end
    return str
end
