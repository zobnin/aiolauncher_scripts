-- name = "Screen state"

local json = require "json"

function on_resume()
    ui:show_buttons{
        "Save screen",
        "Restore screen",
    }
end

function on_click(idx)
    if idx == 1 then
        save_state()
    else
        restore_state()
    end
end

function save_state()
    local state = aio:get_active_widgets()
    local json_str = json.encode(state)

    files:write("screen-state", json_str)
    ui:show_toast("Screen state saved!")
end

function restore_state()
    local json_str = files:read("screen-state")
    local state = json.decode(json_str)

    remove_all_widgets()

    for k,v in pairs(state) do
        aio:add_widget(v.name, v.position)
    end

    ui:show_toast("Screen state restored!")
end

function remove_all_widgets()
    local curr_state = aio:get_active_widgets()
    for k,v in pairs(curr_state) do
        if (v.name ~= "screen-state-widget.lua") then
            aio:remove_widget(v.position)
        end
    end
end
