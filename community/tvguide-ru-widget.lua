-- name = "ТВ-Программа"
-- description = "Программа передач россиийского ТВ"
-- type = "widget"
-- version = "1.1"
-- lang = "ru"
-- author = "Andrey Gavrilov"

local url = "https://api.peers.tv/tvguide/2/"
local channel_id = "10338240"
local title = "Матч ТВ"
local tab_name,tab_time,tab_desc,tab_link,tab = {},{},{},{},{}
local link = ""

function on_resume()
    ui:show_table(tab,2)
end

function on_alarm()
    tab_name,tab_time,tab_desc,tab_link = {},{},{},{}
    http:get(url.."schedule.json?channel="..channel_id,"schedule")
end

function on_click(idx)
    if math.ceil(idx/2) > #tab_desc then
        dialogs:show_edit_dialog("Введите название канала","",title)
    else
        dialogs:show_dialog(tab_name[math.ceil(idx/2)].."\n"..tab_time[math.ceil(idx/2)],tab_desc[math.ceil(idx/2)],"Перейти к каналу")
        link = tab_link[math.ceil(idx/2)]
    end
end

function on_network_result_channel(res)
    local json = require "json"
    local t = json.decode(res)
    if not next(t.channels[1]) then
        return
    end
    channel_id = tostring(t.channels[1].channelId)
    title = t.channels[1].title
    tab_name,tab_time,tab_desc,tab_link = {},{},{},{}
    http:get(url.."schedule.json?channel="..channel_id,"schedule")
end

function on_dialog_action(data)
    if type(data) == "string" then
        http:get(url.."idbytitle.json?titles="..data,"channel")
    elseif data ~= -1 then
        system:open_browser(link)
    end
end

function on_network_result_schedule(res)
    local json = require "json"
    local t = json.decode(res)
    for i,v in ipairs(t.telecastsList) do
        if os.time{year=v.date.year,month=v.date.month,day=v.date.day,hour=v.date.hour,min=v.date.minute} >= os.time() - v.duration then
            table.insert(tab_name,v.title)
            table.insert(tab_time,string.format("%02d:%02d",v.date.hour,v.date.minute))
            table.insert(tab_desc,v.description)
            table.insert(tab_link,v.URL)
        end
        if #tab_name >= 10 then
            break
        end
    end
    if #tab_name < 10 then
        http:get(url.."schedule.json?channel="..channel_id.."&dates="..os.date("%Y-%m-%d",os.time()+24*60*60),"schedule")
        return
    end
    tab = {}
    local colors = aio:colors()
    local row = {}
    for i,v in ipairs(tab_name) do
        local row = {}
        table.insert(row,"<font color=\""..colors.secondary_text.."\">"..tab_time[i].."</font>")
        table.insert(row,v)
        table.insert(tab,row)
        row = {}
    end
    table.insert(row," ")
    table.insert(row,"<font color=\""..colors.secondary_text.."\">Выберите канал</font>")
    table.insert(tab,row)
    ui:set_title(ui:get_default_title().." ("..title..")")
    ui:show_table(tab,2)
end

function on_settings()
    return
end
