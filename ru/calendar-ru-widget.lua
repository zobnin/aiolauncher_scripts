-- name = "Календарь"
-- description = "Производственный календарь с праздниками"
-- data_source = ""
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"
-- language = "ru"

local color = require "md_colors"
local json = require "json"

local days = {}
local tab = {}
local line = ""
local text = ""

local pr_text_color = ui:get_primary_text_color()
local sec_text_color = ui:get_secondary_text_color()
local year = os.date("*t").year
local month = os.date("*t").month
local day = os.date("*t").day

function on_alarm()
	is_days_off(year,month)
end

function is_days_off(y,m)
    http:get("https://isdayoff.ru/today?pre=1&covid=1", "today")
	http:get("https://isdayoff.ru/api/getdata?year="..y.."&month="..m.."&pre=1&delimeter=-&covid=1", "month")
end

function on_network_result_month(result)
	days = result:split("-")
	tab = get_cal(year,month)
	ui:show_table(table_to_tables(tab,8),0, true, line)
	ui:set_title(ui:get_default_title().." ("..string.format("%02d.%04d",month,year)..")")
end

function on_network_result_today(result)
    line = "Сегодня "
    if result == "0" then
        line = line.."рабочий"
    elseif result == "4" then
        line = line.."рабочий"
    elseif result == "1" then
        line = line.."нерабочий"
    elseif result == "2" then
        line = line.."предпраздничный"
    end
    line = line.." день"
end

function on_network_result_day(result)
    local t = json.decode(result)
    if #t.saints ~= 0 then
        text = text.."<br><br><b>Святые</b>"
    end
    for i = 1, #t.saints do
      text = text.."<br>• "..t.saints[i].title
    end
    if #t.ikons ~= 0 then
      text = text.."<br><br><b>Иконы</b>"
    end
    for i = 1, #t.ikons, 1 do
      text = text.."<br>• "..t.ikons[i].title
    end
    if #t.holidays ~= 0 then
        text = text.."<br><br><b>Православные праздники</b>"
    end
    for i = 1, #t.holidays, 1 do
      text = text.."<br>• "..t.holidays[i].title
    end
    ui:show_dialog(string.format("%02d.%02d.%04d", day, month, year).."\n"..os.date("*t", get_time(year,month,day)).yday.." день года", text)
end

function on_click(i)
    text = "<big><b>События</b></big>"
	if i == 1 then
		local time = get_time(begin_month(year,month))-24*60*60
		local y,m,d = get_day(time)
		year = y
		month = m
	elseif i == 8 then
		local time = get_time(end_month(year,month))+24*60*60
		local y,m,d = get_day(time)
		year = y
		month = m
	elseif i > 1 and i < 8 then
		ui:show_edit_dialog("Введите месяц и год", "Формат - 12.2020. Пустое значение - текущий месяц", string.format("%02d.%04d", month, year))
	elseif (i-1)%8 ~= 0 and tab[i] ~= " " then
		day = tonumber(tab[i]:match(">(%d+)<"))
		http:get("https://azbyka.ru/days/api/day/"..string.format("%04d-%02d-%02d", year, month, day)..".json", "day")
		return
	else
		return
	end
	is_days_off(year,month)
end

function on_dialog_action(data)
	if data == -1 then
		return
	elseif data == "" then
		local date = os.date("*t")
		if year == date.year and month == date.month then
			return
		end
		year = date.year
		month = date.month
		is_days_off(year,month)
		return
	elseif not check_date(data) then
		return
	else
		local m,y = data:match("(%d+)%.(%d+)")
		if year == tonumber(y) and month == tonumber(m) then
			return
		end
	end
	local m,y = data:match("(%d+)%.(%d+)")
	year = tonumber(y)
	month = tonumber(m)
	is_days_off(year,month)
end

function get_cal(y,m)
	local from = get_time(begin_month(y,m))
	local tab = {
				"ᐊ <font color=\""..sec_text_color.."\">#</font>",
				"<font color=\""..sec_text_color.."\">Пн</font>",
				"<font color=\""..sec_text_color.."\">Вт</font>",
				"<font color=\""..sec_text_color.."\">Ср</font>",
				"<font color=\""..sec_text_color.."\">Чт</font>",
				"<font color=\""..sec_text_color.."\">Пт</font>",
				"<font color=\""..sec_text_color.."\">Сб</font>",
				"<font color=\""..sec_text_color.."\">Вс</font> ᐅ"
				}
	table.insert(tab,"<font color=\""..sec_text_color.."\">"..weeknumber(get_day(from)).."</font>")
	for i =1, weekday(get_day(from))-1,1 do
		table.insert(tab," ")
	end
	local to = get_time(end_month(y,m))
	local k=0
	for time = from,to,24*60*60 do
		k=k+1
		local y,m,d = get_day(time)
		table.insert(tab, format_day(d,k))
		if weekday(get_day(time))==7 and time ~= to then
			table.insert(tab, "<font color=\""..sec_text_color.."\">"..weeknumber(get_day(time+24*60*60)).."</font>")
		end
	end
	for i = weekday(get_day(to))+1,7,1 do
		table.insert(tab," ")
	end
	return tab
end

function weeknumber(y,m,d)
	local yday = os.date("*t",os.time{day=d,month=m,year=y}).yday
	local wday = weekday(y,m,1)
	return math.floor((yday+10-wday)/7)
end

function weekday(y,m,d)
	local wday = os.date("*t",os.time{day=d,month=m,year=y}).wday-1
	if wday == 0 then wday = 7 end
	return wday
end

function begin_month(y,m)
	local time = os.time{day=1,month=m,year=y}
	local date = os.date("*t",time)
	return date.year,date.month,date.day
end

function end_month(y,m)
	local time = os.time{day=1,month=m,year=y}+31*24*60*60
	local date = os.date("*t",time)
	local time = os.time{day=1,month=date.month,year=date.year}-24*60*60
	local date = os.date("*t",time)
	return date.year,date.month,date.day
end

function get_day(t)
	local date = os.date("*t",t)
	return date.year,date.month,date.day
end

function get_time(y,m,d)
	return os.time{day=d,month=m,year=y}
end

function format_day(d,k)
	local dd = d
	if days[k] == "2" then
		dd = "<font color=\""..color.orange_500.."\">"..dd.."</font>"
	elseif days[k] == "1" then
		dd = "<font color=\""..color.red_A700.."\">"..dd.."</font>"
	elseif days[k] == "4" then
		dd = "<font color=\""..sec_text_color.."\">"..dd.."</font>"
	else
		dd = "<font color=\""..pr_text_color.."\">"..dd.."</font>"
	end
	if year == os.date("*t").year and month == os.date("*t").month and d == os.date("*t").day then
		dd = "<b>"..dd.."</b>"
	end
	return dd
 end
 
function check_date(date)
	local m, Y = date:match("(%d+).(%d+)")
	local time = os.time{day=1, month=m or 0, year=Y or 0}
	local str = string.format("%02d.%04d", m or 0, Y or 0)
	return str == os.date("%m.%Y", time)
end

function table_to_tables(tab, num)
    local out_tab = {}
    local row = {}
    for k,v in ipairs(tab) do
        table.insert(row, v)
        if k % num == 0 then
            table.insert(out_tab, row)
            row = {}
        end
    end
    return out_tab
end
