-- name = "Quick Actions"
-- type = "widget"
-- description = "Launcher selected actions widget - long click button for options, open widget settings for list of buttons"
--foldable = "true"
-- author = "Theodor Galanis"
-- version = "3.0"

prefs = require "prefs"
prefs._name = "quickactions"

local actions = { "quick_menu", "settings", "apps_menu", "ui_settings", "headers", "quick_apps_menu", "refresh", "restart", "notify", "clear_notifications", "quick_settings", "show_recents", "private_mode", "screen_off", "fold", "unfold", "scroll_down", "scroll_up", "add_note", "add_task", "add_purchase", "shortcuts", "send_mail", "voice", "one_handed", "right_handed", "camera", "flashlight", "dialer", "search"}

local icons = { "fa:ellipsis-vertical", "fa:sliders-h", "fa:indent", "fa:paintbrush", "fa:bars", "fa:share-from-square", "fa:redo", "fa:power-off", "fa:bring-forward", "fa:eraser", "fa:square-ellipsis", "fa:square-full", "fa:user-shield", "fa:lock", "fa:layer-minus", "fa:layer-group", "fa:chevron-down", "fa:chevron-up", "fa:notes-medical", "fa:list-check", "fa:tag", "fa:share", "fa:envelope", "fa:microphone", "fa:hand", "fa:right-to-bracket", "fa:camera", "fa:brightness", "fa:phone", "fa:search"}

local cols = { "#6A1B9A", "#4527A0",  "#8E24AA", "#FF6F00", "#E65100", "#0D47A1", "#546E7A", "#1B5E20", "#689F38", "#1565C0", "#F06292", "#0073DD", "#00796B", "#424242", "#3F51B5", "#3F51B5", "#AB47BC", "#AB47BC", "#D81B60", "#F57C00", "#9E9D24", "#00838F", "#B71C1C", "#512DA8", "#795548", "#5C6BC0", "#FF5252", "#FF8F00", "#B388FF", "#37474F"}

local pos = 0
local buttons,colors = {},{}

function on_alarm()
    args = get_args()
    if not prefs.args then
        prefs.args = args.action
    end
    indexes = get_indexes(prefs.args, args.action)
    ui:show_buttons(get_buttons())
end

function on_click(idx)
    if idx > #prefs.args then
        on_settings()
        return
    end
    local action = prefs.args[idx]
    aio:do_action(action)
    on_alarm()
end

function on_long_click(idx)
    local label = ""
    pos = idx
    if idx > #prefs.args then
        return
    end
    label = get_label(args.action[indexes[idx]])
    ui:show_context_menu({{"angle-left",""},{"ban",""},{"angle-right",""},{args.icon[indexes[idx]]:gsub("fa:",""),label}})
end

function on_context_menu_click(menu_idx)
    if menu_idx == 1 then
        move(-1)
    elseif menu_idx == 2 then
        remove()
    elseif menu_idx == 3 then
        move(1)
    end
end

function on_dialog_action(data)
    if data == -1 then
        return
    end
    local tab = {}
    for i,v in ipairs(data) do
        tab[i] = args.action[v]
    end
    prefs.args = tab
    on_alarm()
end

function on_settings()
    local labels = {}
    for i = 1, #icons do
        table.insert(labels, get_label(args.action[i]))
    end
    ui:show_checkbox_dialog("Select actions", labels, indexes)
end

--utilities--

function move(x)
    local tab = prefs.args
    if (pos*x == -1) or (pos*x == #tab) then
        return
    end
    local cur = tab[pos]
    tab[pos] = tab[pos+x]
    tab[pos+x] = cur
    prefs.args = tab
    on_alarm()
end

function remove()
    local tab = prefs.args
    table.remove(tab,pos)
    prefs.args = tab
    on_alarm()
end


function get_label(name)
    local lab=""
    local axions = aio:actions()
    if name == "clear_notifications" then
        lab = aio:res_string("clear_notifications","Clear notifications")
    else for _, action in ipairs(axions) do
        if action["name"] == name then
            lab = action["label"]
        end
    end
end
return lab
end

function get_args()
    local tab = {}
    tab.action = actions
    tab.icon = icons
    tab.color = cols
    return tab
end

function get_buttons()
    buttons,colors = {},{}
    for i,v in ipairs(indexes) do
        table.insert(buttons, args.icon[v])
        table.insert(colors, args.color[v])
    end
    return buttons,colors
end


function get_indexes(tab1,tab2)
    local tab = {}
    for i1,v1 in ipairs(tab1) do
        for i2,v2 in ipairs(tab2) do
            if v1 == v2 then
                tab[i1] = i2
                break
            end
        end
    end
    return tab
end
