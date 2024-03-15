-- name = "Todoist"
-- description = "AIO wrapper for the official Todoist app widget"
-- type = "widget"
-- author = "Andey Gavrilov"
-- aio_version = "4.1.99"
-- uses_app = "com.todoist"

local prefs = require "prefs"
local fmt = require "fmt"

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
    curr_tab = parse(bridge:dump_table())
    ui:show_lines(curr_tab.lines)
end

function parse(t)
    local tab = {}
    tab["list"] = t.v_layout_1.frame_layout_1.relative_layout_1.text_1
    local footer = t.v_layout_1.frame_layout_2
    for k,v in pairs(footer) do
        if k:sub(1,8) == "relative" then
            footer = v
            break
        end
    end
    local images = {}
    local texts = {}
    local lines = {}
    local tasks = t.v_layout_1.frame_layout_2.list_layout_1
    if tasks == nil then tasks = {} end
    local tkeys = {}
    for k,v in pairs(tasks) do
        table.insert(tkeys,k)
    end
    table.sort(tkeys)
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
                            table.insert(texts,v4)
                            text = v4
                            local color = colors[images[#texts]]
                            if color ~= "#909090" and color then
                                text = fmt.colored(fmt.bold(text),color)
                            end
                        elseif k4:sub(1,8) == "h_layout" then
                            subtexts = recursion(v4,subtexts,#subtexts,false)
                        end
                    end
                    table.insert(lines,text..table.concat(subtexts))
                end
            end
        end
    end
    for k1,v1 in pairs(footer) do
        for k2,v2 in pairs(v1) do
            if k2:sub(1,4) == "text" then
                table.insert(images,k2)
                table.insert(texts,v2)
                table.insert(lines,fmt.secondary("Add task"))
                break
            end
        end
    end
    tab["images"] = images
    tab["texts"] = texts
    tab["lines"] = lines
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
            tab = recursion(v,tab,1,true)
        end
    end
    return tab
end

function on_click(idx)
    w_bridge:click(curr_tab.texts[idx])
end

function setup_app_widget()
    local id = widgets:setup("com.todoist/com.todoist.appwidget.provider.ItemListAppWidgetProvider")
    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_text("Can't add widget")
    end
end

function on_settings()
    w_bridge:click(curr_tab.list)
end
