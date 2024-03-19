-- name = "Todoist"
-- description = "AIO wrapper for the official Todoist app widget"
-- type = "widget"
-- author = "Andey Gavrilov"
-- aio_version = "4.1.99"
-- uses_app = "com.todoist"

local prefs = require "prefs"
local fmt = require "fmt"

local widget = "com.todoist/com.todoist.appwidget.provider.ItemListAppWidgetProvider"

local curr_tab = {}
local w_bridge = nil
local colors = {}

function on_resume()
    if not widgets:bound(prefs.wid) then
        setup_app_widget()
    end
    widgets:request_updates(prefs.wid)
end

function on_app_widget_updated(bridge)
    w_bridge = bridge
    colors = bridge:dump_colors()
    curr_tab = bridge:dump_table()
    curr_tab = parse(curr_tab)
    ui:show_lines(curr_tab.lines)
end

function parse(t)
    local tab = {}
    local images = {}
    local lines = {}
    local clicks = {}
    local tasks = t.v_layout_1.frame_layout_2.list_layout_1
    if not tasks then tasks = {} end
    local tkeys = {}
    for k,v in pairs(tasks) do
        table.insert(tkeys,k)
    end
    table.sort(tkeys,function (a,b) return tonumber(a:match("%d+")) < tonumber(b:match("%d+")) end)
    for i1,v1 in ipairs(tkeys) do
        for k2,v2 in pairs(tasks[v1]) do
            for k3,v3 in pairs(v2) do
                if k3:sub(1,5) == "image" then
                    table.insert(images,k3)
                elseif k3:sub(1,8) == "v_layout" then
                    local text = ""
                    local subtexts = {}
                    for k4,v4 in pairs(v3) do
                        if k4:sub(1,4) == "text" then
                            table.insert(clicks,k4)
                            text = v4
                            local color = colors[images[#images]]
                            if color ~= "#909090" and color then
                                text = fmt.colored(fmt.bold(text),color)
                            end
                        elseif k4:sub(1,8) == "h_layout" then
                            subtexts = recursion(v4,subtexts,1,false)
                        end
                    end
                    table.insert(lines,text..table.concat(subtexts))
                end
            end
        end
    end
    local footer = t.v_layout_1.frame_layout_2
    for k,v in pairs(footer) do
        if k:sub(1,8) == "relative" then
            footer = v
            break
        end
    end
    for k1,v1 in pairs(footer) do
        for k2,v2 in pairs(v1) do
            if k2:sub(1,4) == "text" then
                table.insert(images,k2)
                table.insert(clicks,k2)
                local add_task = "Add task"
                if #lines ~= 0 then
                    add_task = fmt.secondary(add_task)
                end
                table.insert(lines,add_task)
                break
            end
        end
    end
    tab["images"] = images
    tab["lines"] = lines
    tab["clicks"] = clicks
    return tab
end

function recursion(t,tab,idx,flag)
    for k,v in pairs(t) do
        if k:sub(1,4) == "text" then
            local a,b = v:match("(%d+)/(%d+)")
            if a or flag then
                table.insert(tab,idx,fmt.secondary(" - ") .. fmt.colored(v,colors[k]))
            end
        elseif k:sub(1,8) == "h_layout" then
            tab = recursion(v,tab,#tab+1,true)
        end
    end
    return tab
end

function on_click(idx)
    w_bridge:click(curr_tab.clicks[idx])
end

function setup_app_widget()
    local id = widgets:setup(widget)
    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_toast("Can't add widget")
    end
end

function on_settings()
    w_bridge:click("text_1")
end
