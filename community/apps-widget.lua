-- name = "My apps"
-- description = "Simple apps widget"
-- type = "widget"
-- version = "1.0"
-- author = "Andrey Gavrilov"

local utf8 = require "utf8"
local dialog_id = ""
local app_idx = 0

function on_resume()
	update_args()
	local folding = false
    if settings:get_kv()["folding"] == "true" then
        folding = true
    end
	ui:set_folding_flag(folding)
    redraw()
end

function on_alarm()
    local args = settings:get_kv()
    if next(args) == nil then
		args["no_hidden"] = true
		args["columns"] = 4
		args["trim"] = 10
		args["folding"] = false
		args["1"] = "com.android.settings"
        settings:set_kv(args)
        redraw()
    end
end

function on_settings()
    dialog_id = "settings"
    local tab = {"Applications list","No hidden setting","Columns number","Trim app name","Autofolding setting","Widget title"}
    ui:show_radio_dialog("Settings",tab)
end

function on_dialog_action(data)
    if data == -1 then
        return
    end
    if dialog_id == "settings" then
        if data == 1 then
            dialog_id = "apps"
            local tab = get_all_apps("abc",settings:get_kv()["no_hidden"])
            ui:show_checkbox_dialog("Select apps",tab[2],args_to_idx(tab[1]))
            return
        elseif data == 2 then
            dialog_id = "no_hidden"
            local tab = {"Not show hidden applications"}
            local tt = {}
            if tostring(settings:get_kv()["no_hidden"]) == "true" then
                tt = {1}
            end
            ui:show_checkbox_dialog("No hidden settings",tab,tt)
            return
		elseif data == 3 then
			dialog_id = "columns"
			ui:show_edit_dialog("Columns number","",settings:get_kv()["columns"])
			return
		elseif data == 4 then
			dialog_id = "trim"
			ui:show_edit_dialog("Trim app name","0 - not trim",settings:get_kv()["trim"])
			return
		elseif data == 5 then
            dialog_id = "folding"
            local tab = {"Autofolding"}
            local tt = {}
            if tostring(settings:get_kv()["folding"]) == "true" then
                tt = {1}
            end
            ui:show_checkbox_dialog("Autofolding settings",tab,tt)
            return
		elseif data == 6 then
            dialog_id = "name"
			ui:show_edit_dialog("Set widget title","Empty - default title",ui:get_default_title())
			return
        end
    elseif dialog_id == "no_hidden" then
        local args = settings:get_kv()
        if next(data) == nil then
            args["no_hidden"] = false
        else
            args["no_hidden"] = true
        end
        settings:set_kv(args)
		update_args()
        redraw()
        return
    elseif dialog_id == "apps" then
        settings:set_kv(idx_to_args(data))
        redraw()
        return
	elseif dialog_id == "columns" then
		if data == tostring(tonumber(data)) then
			if tonumber(data) == 0 then
				data = "1"
			end
			local args = settings:get_kv()
			args["columns"] = math.floor(tonumber(data))
			settings:set_kv(args)
			update_args()
			redraw()
		end
		return
	elseif dialog_id == "trim" then
		if data == tostring(tonumber(data)) then
			local args = settings:get_kv()
			args["trim"] = math.floor(tonumber(data))
			settings:set_kv(args)
			update_args()
			redraw()
		end
		return
	elseif dialog_id == "folding" then
        local args = settings:get_kv()
        if next(data) == nil then
            args["folding"] = false
        else
            args["folding"] = true
        end
        settings:set_kv(args)
        update_args()
        redraw()
        return
	elseif dialog_id == "name" then
        local title = ui:get_default_title()
        if data ~= "" then
            title = data
        end
        ui:set_title(title)
        return
	elseif dialog_id == "move" then
        if data == tostring(tonumber(data)) then
            local idx = math.floor(tonumber(data))
            local args = settings:get_kv()
            if idx < 1 then
                idx = 1
            elseif idx > max_key(args) then
                idx = max_key(args)
            end
            local from = args[tostring(app_idx)]
            local to = args[tostring(idx)]
            args[tostring(app_idx)] = to
            args[tostring(idx)] = from
            settings:set_kv(args)
            update_args()
            redraw()
            return
        end
    end
end

function on_context_menu_click(idx)
    if idx == 4 then
        apps:show_edit_dialog(settings:get_kv()[tostring(app_idx)])
    elseif idx == 1 then
        local args = settings:get_kv()
        if app_idx == max_key(args) then
            return
        end
        local from = args[tostring(app_idx)]
        local to = args[tostring(app_idx+1)]
        args[tostring(app_idx)] = to
        args[tostring(app_idx+1)] = from
        settings:set_kv(args)
        update_args()
        redraw()
        return
    elseif idx == 3 then
        local args = settings:get_kv()
        if app_idx == 1 then
            return
        end
        local from = args[tostring(app_idx)]
        local to = args[tostring(app_idx-1)]
        args[tostring(app_idx)] = to
        args[tostring(app_idx-1)] = from
        settings:set_kv(args)
        update_args()
        redraw()
        return
    elseif idx == 2 then
        local args = settings:get_kv()
        local new_args = {}
        for k,v in pairs(args) do
            if k ~= tostring(app_idx) then
                new_args[k] = v
            end
        end
        settings:set_kv(new_args)
        update_args()
        redraw()
        return
    elseif idx == 5 then
        dialog_id = "move"
        local text = "Number from 1 to "..tostring(max_key(settings:get_kv()))
        ui:show_edit_dialog("Set position",text,app_idx)
        return
    end
end

function redraw()
	local cols = tonumber(settings:get_kv()["columns"])
	if cols == 0 or cols == nil then
		cols = 1
	end
	ui:show_table(table_to_tables(tab_from_args(), cols))
end

function on_click(idx)
    apps:launch(settings:get_kv()[tostring(idx)])
end

function on_long_click(idx)
    app_idx = idx
	ui:show_context_menu({
		{ "chevron-right", "Forward" },
		{ "times",  "Remove" },
		{ "chevron-left", "Back" },
		{ "edit", "Edit" },
		{ "exchange", "Move" }
	})
end

function tab_from_args()
	local args = settings:get_kv()
	local len = tonumber(args["trim"])
	if len == nil then
		len = 0
	end
	local tab = {}
	for k,v in pairs(args) do
		if k == tostring(tonumber(k)) then
			tab[tonumber(k)] = get_formatted_name(v,len)
		end
	end
	return tab
end

function get_formatted_name(pkg,len)
    local str = apps:get_name(pkg)
    if utf8.len(str) > len and len > 0 then
        str = utf8.sub(str,1,len-1):gsub("[%. ]*$","").."."
    end
    return "<font color=\""..apps:get_color(pkg).."\">"..str.."</font>"
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
    if row ~= {} then
        table.insert(out_tab, row)
    end
    return out_tab
end

function get_all_apps(sort_by,no_hidden)
    if tostring(no_hidden) == "true" then
        no_hidden = true
    else
        no_hidden = false
    end
    local t = settings:get_kv()
    local all_apps = apps:get_list(sort_by,no_hidden)
    local apps_names = {}
    for k,v in ipairs(all_apps) do
        apps_names[k] = apps:get_name(v)
    end
    return {all_apps,apps_names}
end

function args_to_idx(tab)
    local args = settings:get_kv()
    local t = {}
    for k,v in pairs(args) do
        local idx = get_index(tab,v)
        if idx > 0 then
            table.insert(t,idx)
        end
    end
    return t
end

function idx_to_args(tab)
    local args = settings:get_kv()
    local all_apps = get_all_apps("abc",args["no_hidden"])[1]
    local new_args = {}
    for i,v in ipairs(tab) do
		if get_key(args,all_apps[tonumber(v)]) == 0 then
			new_args[tostring(max_key(args)+i)] = all_apps[tonumber(v)]
		else
			new_args[get_key(args,all_apps[tonumber(v)])] = all_apps[tonumber(v)]
        end
    end
    new_args = sort_by_key(new_args)
    new_args["no_hidden"] = args["no_hidden"]
    new_args["columns"] = args["columns"]
    new_args["trim"] = args["trim"]
    new_args["folding"] = args["folding"]
    return new_args
end

function update_args()
	local args = settings:get_kv()
	local all_apps = get_all_apps("abc",args["no_hidden"])[1]
	local new_args = {}
	for k,v in pairs(args) do
		if k == tostring(tonumber(k)) then
			if get_index(all_apps,v) ~= 0 then
				new_args[k] = v
			end
		end
	end
	new_args = sort_by_key(new_args)
	new_args["no_hidden"] = args["no_hidden"]
    new_args["columns"] = args["columns"]
    new_args["trim"] = args["trim"]
    new_args["folding"] = args["folding"]
	settings:set_kv(new_args)
end

function sort_by_key(tab)
    local t = {}
    local tt = {}
    for k,v in pairs(tab) do
        table.insert(t,tonumber(k))
    end
    table.sort(t)
    for i,v in ipairs(t) do
        for kk,vv in pairs(tab) do
            if kk == tostring(v) then
                tt[tostring(i)] = vv
                break
            end
        end
    end
    return tt
end

function max_key(tab)
    local t = {}
    for k,v in pairs(tab) do
        if k == tostring(tonumber(k)) then
            table.insert(t,k)
        end
    end
    table.sort(t)
    return #t
end
