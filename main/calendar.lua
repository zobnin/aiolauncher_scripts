-- name = "Monthly Calendar"
-- description = "Monthly calendar with system calendar events"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "3.2"

local tab = {}
local line = " "
local events = {}
local dialog_id = ""
local widget_type = "table"

local year = os.date("%Y"):gsub("^0","")
local month = os.date("%m"):gsub("^0","")
local day = os.date("%d"):gsub("^0","")

function on_resume()
    if calendar:events(0,0) == "permission_error" then
        widget_type = "text"
        ui:show_text("Click to grant permission")
        return
    end
	if next(settings:get()) == nil then
		settings:set(get_all_cals()[2])
	end
	tab = get_cal(year,month)
	line = get_line()
	ui:show_table(table_to_tables(tab,8),0, true, line)
	ui:set_title(ui:default_title().." ("..get_date(month,year)..")")
	widget_type = "table"
end

function on_settings()
	dialog_id = "settings"
	dialogs:show_checkbox_dialog("Check calendars", get_all_cals()[3],cal_id_to_id(settings:get()))
end

function on_click(i)
	if widget_type == "table" then
		if i == 1 then
			system:vibrate(10)
			local time = os.time{year=year,month=month,day=1}-24*60*60
			year,month = os.date("%Y-%m",time):match("(%d+)-(%d+)")
			year,month = year:gsub("^0",""),month:gsub("^0","")
			on_resume()
		elseif i == 8 then
			system:vibrate(10)
			local time = os.time{year=year,month=month,day=1}+31*24*60*60
			year,month = os.date("%Y-%m",time):match("(%d+)-(%d+)")
			year,month = year:gsub("^0",""),month:gsub("^0","")
			on_resume()
		elseif i > 1 and i < 8 then
			dialog_id = "date"
			dialogs:show_edit_dialog("Enter month and year", "Format - 12.2020. Empty value - current month", string.format("%02d.%04d", month, year))
			return
		elseif (i-1)%8 ~= 0 and tab[i] ~= " " then
			day = tab[i]:match(">(%d+)<"):gsub("^0","")
			events = get_day_tab(get_my_events(year,month,day))
			if next(events) ~= nil then
				widget_type = "lines"
				ui:show_table(get_lines(events),2, false, line)
			end
		else
			return
		end
	elseif widget_type == "lines" then
		if math.ceil(i/3) <= #events then
			dialog_id = "event"
			calendar:show_event_dialog(events[math.ceil(i/3)][1])
		else
			widget_type = "table"
			ui:show_table(table_to_tables(tab,8),0, true, line)
		end
	elseif widget_type == "text" then
	    calendar:request_permission()
	end
end

function on_permission_granted()
    on_resume()
end

function on_dialog_action(data)
	if data == -1 then
		events = {}
		event_id = ""
		return
	end
	if dialog_id == "date" then
		if data == "" then
			local date = os.date("*t")
			local y,m = os.date("%Y-%m"):match("(%d+)-(%d+)")
			y,m = y:gsub("^0",""),m:gsub("^0","")
			if y==year and m==month then
				return
			end
			year,month = y,m
			on_resume()
			return
		elseif not check_date(data) then
			return
		else
			local m,y = data:match("(%d+)%.(%d+)")
			m,y = m:gsub("^0",""),y:gsub("^0","")
			if y==year and m==month then
				return
			end
		end
		month,year = data:match("(%d+)%.(%d+)")
		month,year = month:gsub("^0",""),year:gsub("^0","")
		on_resume()
	elseif dialog_id == "settings" then
		settings:set(id_to_cal_id(data))
		on_resume()
	end
end

function get_cal(y,m)
	local color = aio:colors()
	local events = get_my_events(y,m,0)
	local from = os.time{year=y,month=m,day=1}
	local tab = {
				"ᐊ <font color=\""..color.secondary_text.."\">#</font>",
				"<font color=\""..color.secondary_text.."\">Mo</font>",
				"<font color=\""..color.secondary_text.."\">Tu</font>",
				"<font color=\""..color.secondary_text.."\">We</font>",
				"<font color=\""..color.secondary_text.."\">Th</font>",
				"<font color=\""..color.secondary_text.."\">Fr</font>",
				"<font color=\""..color.secondary_text.."\">Sa</font>",
				"<font color=\""..color.secondary_text.."\">Su</font> ᐅ"
				}
	table.insert(tab,"<font color=\""..color.secondary_text.."\">"..os.date("%W",from).."</font>")
	for i = 1, os.date("%w",from):gsub("0","7")-1 do
		table.insert(tab," ")
	end
	local to = os.time{year=y,month=m,day=1}+31*24*60*60
	local yy,mm = os.date("%Y-%m",to):match("(%d+)-(%d+)")
	yy,mm = yy:gsub("^0",""),mm:gsub("^0","")
	to = os.time{year=yy,month=mm,day=1}-24*60*60
	for time = from,to,24*60*60 do
		local d = os.date("%d",time):gsub("^0","")
		table.insert(tab, format_day(y,m,d,events))
		if os.date("%w",time):gsub("0","7")=="7" and time ~= to then
			table.insert(tab, "<font color=\""..color.secondary_text.."\">"..os.date("%W",time+24*60*60).."</font>")
		end
	end
	for i = os.date("%w",to):gsub("0","7")+1,7 do
		table.insert(tab," ")
	end
	return tab
end

function format_day(y,m,d,events)
	local color = aio:colors()
	local from = os.time{year=y,month=m,day=d,hour=0,min=0,sec=0}
	local to = os.time{year=y,month=m,day=d,hour=23,min=59,sec=59}
	local yes = false
	for i=1,#events do
		local v = events[i]
		if v.begin >= from and v["end"] <= to then
			yes = true
			break
		end
	end
	local dd = d
	if yes then
		dd = "<b>"..dd.."</b>"
	end
	if year == os.date("%Y"):gsub("^0","") and month == os.date("%m"):gsub("^0","") and d == os.date("%d"):gsub("^0","") then
		dd = "<font color=\""..color.progress_good.."\">"..dd.."</font>"
	elseif calendar.is_holiday and calendar:is_holiday(os.time{year=y,month=m,day=d}) then
		dd = "<font color=\""..color.progress_bad.."\">"..dd.."</font>"
	else
		dd = "<font color=\""..color.primary_text.."\">"..dd.."</font>"
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

function get_date(m,y)
	local time = os.time{year=y,month=m,day=1}
	return os.date("%B",time).." "..string.format("%04d", y)
end

function get_my_events(y,m,d)
	local tab = {}
	local from = os.time{year=y,month=m,day=1,hour=0,min=0,sec=0}
	local to = os.date("*t",from + 31*24*60*60)
	to = os.time{year=to.year,month=to.month,day=1,hour=0,min=0,sec=0}-1
	if d ~= 0 then
		from =os.time{year=y,month=m,day=d,hour=0,min=0,sec=0}
		to = os.time{year=y,month=m,day=d,hour=23,min=59,sec=59}
	end
	local events = {}
    if next(settings:get()) then
	    events = calendar:events(from,to,settings:get())
	end
	for i=1,#events do
		local v = events[i]
		if v.begin >= from and v["end"] <= to then
			v["calendar_name"],v["calendar_color"]=get_my_calendar(v.calendar_id)
			table.insert(tab,v)
		end
		if v.begin > to then
			break
		end
	end
	return tab
end

function get_line()
	local line = ""
	local date = os.date("*t")
	local from = os.time{year=date.year,month=date.month,day=date.day,hour=0,min=0,sec=0}
	local to = os.time{year=date.year,month=date.month,day=date.day,hour=23,min=59,sec=59}
	local events = calendar:events(from,to,settings:get())
	if next(events) == nil then
		line = "No events today"
	else
		line = "There're events today"
	end
	return line
end

function get_my_calendar(id)
	local cals = calendar:calendars()
	for i=1,#cals do
		local v = cals[i]
		if id == v.id then
			return v.name,v.color
		end
	end
end

function get_day_tab(events)
	local tab = {}
	for i,v in ipairs(events) do
		local t = {v.id, v.all_day, os.date("%H:%M",v.begin), os.date("%H:%M",v["end"]), v.title, v.description, v.location, v.calendar_name, v.calendar_color}
		table.insert(tab,t)
	end
	return tab
end

function get_lines(events)
	local color = aio:colors()
	local lines = {}
	for i,v in ipairs(events) do
		table.insert(lines,"<font color = \""..v[9].."\">•</font>")
		table.insert(lines,v[5])
		if v[2] == false then
			table.insert(lines,"<font color = \""..color.secondary_text.."\">"..v[3].." - "..v[4].."</font>")
		else
			table.insert(lines,"<font color = \""..color.secondary_text.."\">All day</font>")
		end
	end
	local t = table_to_tables(tab,8)
	for i = #lines/3+1,#t-1 do
		table.insert(lines," ")
		table.insert(lines," ")
		table.insert(lines," ")
	end
	table.insert(lines," ")
	table.insert(lines,"☚ Back")
	table.insert(lines," ")
	return table_to_tables(lines,3)
end

function get_all_cals()
	local cals = calendar:calendars()
	local idx = {}
	local id = {}
	local name = {}
	local color = {}
	for i,v in ipairs(cals) do
		table.insert(idx,i)
		table.insert(id,v.id)
		table.insert(name,v.name)
		table.insert(color,v.color)
	end
	return {idx,id,name,color}
end

function id_to_cal_id(ids)
	local cals = calendar:calendars()
	local tab = {}
	for i,v in ipairs(ids) do
		table.insert(tab,cals[v].id)
	end
	return tab
end

function cal_id_to_id(cal_ids)
	local cals = calendar:calendars()
	local tab = {}
	for i,v in ipairs(cal_ids) do
		for ii,vv in ipairs(cals) do
			if tonumber(v) == tonumber(vv.id) then
				table.insert(tab,ii)
			end
		end
	end
	return tab
end
