-- name = "Widgets switcher"
-- description = "Turns screen widgets on and off when buttons are pressed"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "3.1"

prefs = require "prefs"

local pos = 0
local buttons,colors = {},{}

function on_alarm()
    widgets = get_widgets()
    if not prefs.widgets then
        prefs.widgets = widgets.name
    end
    indexes = get_indexes(prefs.widgets, widgets.name)
    ui:show_buttons(get_buttons())
end

function on_long_click(idx)
	system:vibrate(10)
    pos = idx
	if idx > #prefs.widgets then
		return
	end
	ui:show_context_menu({{"angle-left",""},{"ban",""},{"angle-right",""},{widgets.icon[indexes[idx]],widgets.label[indexes[idx]]}})
end

function on_click(idx)
	system:vibrate(10)
	if idx > #prefs.widgets then
	    on_settings()
	    return
	end
	local widget = prefs.widgets[idx]
	if not aio:is_widget_added(widget) then
	    aio:add_widget(widget, get_pos())
	    aio:fold_widget(widget, false)
	else
	    aio:remove_widget(widget)
	end
    on_alarm()
end

function on_dialog_action(data)
	if data == -1 then
		return
	end
	local tab = {}
	for i,v in ipairs(data) do
	    tab[i] = widgets.name[v]
	end
	prefs.widgets = tab
	on_alarm()
end

function on_settings()
	dialogs:show_checkbox_dialog("Select widgets", widgets.label, indexes)
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

function get_buttons()
    local enabled_color = "#1976d2"
    local disabled_color = aio:colors().button
	buttons,colors = {},{}
	for i,v in ipairs(indexes) do
		table.insert(buttons, "fa:" .. widgets.icon[v])
		table.insert(colors, widgets.enabled[v] and enabled_color or disabled_color)
	end
	return buttons,colors
end

function move(x)
    local tab = prefs.widgets
    if (pos*x == -1) or (pos*x == #tab) then
        return
    end
    local cur = tab[pos]
    tab[pos] = tab[pos+x]
    tab[pos+x] = cur
    prefs.widgets = tab
    on_alarm()
end

function remove()
    local tab = prefs.widgets
    table.remove(tab,pos)
    prefs.widgets = tab
    on_alarm()
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

function on_widget_action(action, name)
    on_alarm()
end

function get_pos()
	local name = aio:self_name()
	local tab = aio:active_widgets()
	for _,v in ipairs(tab) do
		if v.name == name then
			return v.position+1
		end
	end
	return 4
end

function get_widgets()
	local tab = {}
	tab.icon = {}
	tab.name = {}
	tab.label = {}
	tab.enabled = {}
	for i,v in ipairs(aio:available_widgets()) do
		if v.type == "builtin" then
			table.insert(tab.icon, v.icon)
			table.insert(tab.name, v.name)
			table.insert(tab.label, v.label)
			table.insert(tab.enabled, v.enabled)
		end
	end
	return tab
end
