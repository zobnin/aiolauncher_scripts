-- name = "ТВ-Программа"
-- description = "Программа телепередач российского телевидения"
-- type = "widget"
-- version = "1.0"
-- author = "Andrey Gavrilov"

local url = "https://api.peers.tv/tvguide/2/"
local channel_id = "10338240"
local title = "Матч ТВ"
local tab_name = {}
local tab_time = {}
local tab_desc = {}
local tab_link = {}
local link = ""

function on_resume()
    ui:set_folding_flag(true)
    ui:show_lines(tab_name,tab_time)
end

function on_alarm()
    tab_name = {}
    tab_time = {}
    tab_desc = {}
    tab_link = {}
    http:get(url.."schedule.json?channel="..channel_id,"schedule")
end

function on_click(idx)
    if idx > #tab_desc then
        ui:show_edit_dialog("Введите название канала")
    else
        ui:show_dialog("Описание",tab_desc[idx],"Перейти к каналу")
        link = tab_link[idx]
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
    tab_name = {}
    tab_time = {}
    tab_desc = {}
    tab_link = {}
    http:get(url.."schedule.json?channel="..channel_id,"schedule")
end

function on_dialog_action(data)
    if type(data) == "string" then
        data = data:gsub(" ","+")
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
    table.insert(tab_name,"Выберите канал")
    table.insert(tab_time,"")
    ui:set_title(ui:get_default_title().." ("..title..")")
    ui:show_lines(tab_name,tab_time)
end

function on_settings()
    return
end
