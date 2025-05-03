-- name = "Курс валют ЦБ"
-- description = "Cкрипт отображает курс валюты ЦБ России на заданную дату (usd 30 3 22)"
-- data_source = "https://www.cbr.ru/"
-- type = "search"
-- lang = "ru"
-- author = "Andrey Gavrilov"
-- version = "1.0"

-- modules
local xml = require "xml"
local md_color = require "md_colors"

-- constants
local red = md_colors.red_500

-- variables
local cur = ""
local dat = ""
local val = 0

function on_search(inp)
	val = 0
	local c,d,m,y = inp:match("^(%a%a%a)%s?(%d?%d?)%s?(%d?%d?)%s?(%d?%d?%d?%d?)$")
    if c == nil then return end

	cur = c:upper()
	local t = os.date("*t")
	if d == "" then
	    d = t.day
	end
	if m == "" then
	    m = t.month
	end
	if y == "" then
	    y = t.year
	elseif y%100 > 95 then
	    y = 1900 + y%100
	else
	    y = 2000 + y%100
	end
	dat = os.date("%d.%m.%Y",os.time{day=d,month=m,year=y})
	search:show({"Курс "..cur.." "..dat},{red})
end

function on_click()
    if val == 0 then
	    http:get("https://www.cbr.ru/scripts/XML_daily.asp?date_req="..dat:replace("%.","/"))
	    return false
	else
	    system:to_clipboard(val)
	    return true
	end
end

function on_network_result(res)
    local t = xml:parse(res)
	for i,v in ipairs(t.ValCurs.Valute) do
		if v.CharCode:value() == cur then
			search:show({t.ValCurs["@Date"],v.Nominal:value().." "..v.CharCode:value().." = "..v.Value:value():replace(",",".").." RUB"},{red,red})
			val = v.Value:value()
			return
		end
	end
	search:show_buttons({"Нет данных по валюте "..cur},{red})
end

function on_long_click()
	system:to_clipboard(val)
	return true
end
