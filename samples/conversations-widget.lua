-- name = "Conversations"
-- description = "Dialogs widget anologue"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

local no_tab = {}
local messages_tab = {}
local keys_tab = {}
local folded_string = ""

function on_resume()
    update_notifications()
end

function on_notifications_updated()
    update_notifications()
end

function update_notifications()
    no_tab = {}
    local notifications = notify:list()
    
    for _, n in pairs(notifications) do
        -- Skip not clearable and non messenger notifications
        if (n.is_clearable == true and table_size(n.messages) > 0) then
            no_tab[n.key] = n
        end
    end
    
    redraw()
end

function on_apps_changed()
    redraw()
end

function redraw()
    if (table_size(no_tab) == 0) then
        ui:hide_widget()
        ui:show_text("Empty")
    else
        ui:show_widget()
        draw_ui()
    end
end

function draw_ui()
    gen_messages_tab(no_tab)
    gen_folded_string(no_tab)

    ui:show_lines(messages_tab, nil, folded_string)
end

function on_click(idx)
    notify:open(keys_tab[idx])
end

function on_long_click(idx)
    local key = keys_tab[idx]

    if (key == "NO_KEY") then
        return
    end

    local noti = no_tab[key]

    for _,action in pairs(noti.actions) do
        if (action.have_input) then
            notify:do_action(key, action.id)
            return
        end
    end

    ui:show_toast("Can't reply")
end

function gen_messages_tab(tab)
    tree_tab = {}
    tree_keys_tab = {}

    -- Create tree table:
    -- sender
    --   |--> message1 (from WhatsApp)
    --   `--> message2 (from Telegram)
    -- ...
    for _,notify in pairs(tab) do
        for _,message in pairs(notify.messages) do
            local sender = format_sender(message.sender)
            local message = format_message(message, notify.package)

            if tree_tab[sender] == nil then
                tree_tab[sender] = {}
                tree_keys_tab[sender] = {}
            end

            table.insert(tree_tab[sender], message)
            table.insert(tree_keys_tab[sender], notify.key)
        end
    end

    messages_tab = {}
    keys_tab = {}

    -- Flatten tree table
    for sender,messages in pairs(tree_tab) do
        table.insert(messages_tab, sender)
        for _,message in pairs(messages) do
            table.insert(messages_tab, message)
        end
    end

    -- Create correspondig key table
    for _,keys in pairs(tree_keys_tab) do
        table.insert(keys_tab, "NO_KEY")
        for _,key in pairs(keys) do
            saved_key = key
            table.insert(keys_tab, key)
        end
    end
end

function gen_folded_string(tab)
    local msg_num = 0

    for _,notify in pairs(tab) do
        msg_num = msg_num + table_size(notify.messages)
    end

    folded_string = "Messages: "..msg_num
end

function format_sender(sender)
    local final_sender = ""

    if (sender == "") then
        final_sender = "Unknown"
    else
        final_sender = sender
    end

    return "<b>"..final_sender.."</b> "
end

function format_message(message, package)
    local app_name = apps:get_name(package)
    local app_color = apps:get_color(package)
    local circle = "<font color=\""..app_color.."\">●</font>"
    local second_color = aio:colors().secondary_text
    local time = os.date("%H:%M", message.time)
    local time_str = "<font color=\""..second_color.."\">- "..time.."</font>"

    return circle.." "..html_escape(message.text).." "..time_str
end

-- Utils --

function html_escape(s)
    return (string.gsub(s, "[}{\">/<'&]", {
        ["&"] = "&amp;",
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ['"'] = "&quot;",
        ["'"] = "&#39;",
        ["/"] = "&#47;"
    }))
end

function table_size(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

