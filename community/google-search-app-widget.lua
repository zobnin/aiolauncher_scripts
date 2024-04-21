-- name = "Google search"
-- description = "AIO wrapper for the Google search app widget"
-- type = "widget"
-- author = "Theodor Galanis"
-- version = "2.0"
-- foldable = "false"
-- uses_app: "com.google.android.googlequicksearchbox"

local prefs = require "prefs"

local w_bridge = nil
local gravs = {}
local indices = {}

function on_alarm()
    if not widgets:bound(prefs.wid) then
        setup_app_widget()
    end
    if not prefs.mode then
        prefs.mode = 1
    end
    mode = prefs.mode
    gravs = {"left", "right"}
    indices = {1, 3, 5, 7}
    if mode == 2 then
        gravs= reverse(gravs)
        indices = reverse(indices)
    end
    widgets:request_updates(prefs.wid)
end

function on_app_widget_updated(bridge)
    w_bridge = bridge
    local tab = {
        {"button", "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; %%fa:magnifying-glass%% &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;", {gravity = gravs[1]}},
        {"spacer", 2},
        {"button", "&nbsp; &nbsp; %%fa:asterisk%% &nbsp;", {gravity = gravs[2]}},
        {"spacer", 2},
        {"button", "&nbsp; &nbsp; %%fa:microphone%% &nbsp;"},
        {"spacer", 2},
        {"button", "&nbsp; &nbsp; %%fa:camera%% &nbsp;"}
    }

    if mode==1 then
        my_gui = gui(tab)
    else
        my_gui =gui(reverse(tab))
    end

    my_gui.render()
end

function on_click(idx)
    if idx == indices[1] then
        w_bridge:click("image_4")
    elseif idx == indices[2] then
        w_bridge:click("image_7")
    elseif idx == indices[3] then
        w_bridge:click("image_9")
    elseif idx == indices[4] then
        w_bridge:click("image_10")
    else return
    end
end

function on_settings()
    local tab = {"Left-handed mode", "Right-handed mode"}
    ui:show_radio_dialog("Select mode", tab, mode)
end

function on_long_click(idx)
    if idx == indices[1] then
        ui:show_toast("Google search")
    elseif idx == indices[2] then
        ui:show_toast("Google discover")
    elseif idx == indices[3] then
        ui:show_toast("Google voice search")
    elseif idx == indices[4] then
        ui:show_toast("Google Lens")
    end
end

function on_dialog_action(data)
    if data == -1 then
        return
    end
    prefs.mode = data
    on_alarm()
end

function setup_app_widget()
    local id = widgets:setup("com.google.android.googlequicksearchbox/com.google.android.googlequicksearchbox.SearchWidgetProvider")

    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_text("Can't add widget")
        return
    end
end
