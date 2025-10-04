-- name = "Amdroid Buttons"
-- description = "Foldable AIO wrapper for the Amdroid Buttons app widget"
-- type = "widget"
-- author = "Theodor Galanis (t.me/TheodorGalanis)"
-- version = "1.10"
-- foldable = "true"
-- on_resume_when_folding = "true"
-- uses_app = "com.amdroidalarmclock.amdroid"

local prefs = require "prefs"
local indices = {1, 3, 4, 6, 8}
local next_alarm = ""
local accent="#888888"
local temp = {}

function on_resume()
    if not widgets:bound(prefs.wid) then
        setup_app_widget()
    end
     accent = aio:colors().accent
    widgets:request_updates(prefs.wid)
end

function on_app_widget_updated(bridge)
    local tab = bridge:dump_table()
next_alarm = tab.frame_layout_1.v_layout_1.text_1
    w_bridge = bridge
 local state = ui:is_folded()
 if state == false then
temp = {
	{"icon", "fa:alarm-clock", {gravity="center_h|center_v",color = accent}},
    {"spacer", 2 },
    {"text", next_alarm, {gravity="anchor_prev"}},
    {"button", "fa:backward", {gravity = "right"}},
    {"spacer", 2},
    {"button", "fa:right-long-to-line"},
    {"spacer", 2},
    {"button", "fa:forward"}
     }
     else
     temp = {
    {"icon", "fa:alarm-clock", {gravity="center_h|center_v",color = accent}},
    {"spacer", 2 },
    {"text", next_alarm, {gravity="anchor_prev"}}
     }
   end

   my_gui = gui(temp)
    my_gui.render()
end

function on_click(idx)
if idx == indices[1] or idx == indices[2] then
    w_bridge:click(next_alarm)
    elseif idx == indices[3] then
    w_bridge:click("image_3")
        elseif idx == indices[4] then
    w_bridge:click("image_1")
        elseif idx == indices[5] then
    w_bridge:click("image_2")
    end
end

function on_long_click(idx)
if idx == indices[1] or idx == indices[2] then
   ui:show_toast("Open Amdroid app")
    elseif idx == indices[3] then
   ui:show_toast("Adjust alarm's next occurance time 10 minutes earlier")
        elseif idx == indices[4] then
ui:show_toast("Skip alarm's next occurance")
        elseif idx == indices[5] then
 ui:show_toast("Adjust alarm's next occurance time 10 minutes later")
    end
end

function on_settings()
ui:show_dialog("Amdroid app Buttons widget", "This script wrapper uses Amdroid app's Buttons widget. Long click each button for function description. No settings are required.")
end

function setup_app_widget()
    local id = widgets:setup("com.amdroidalarmclock.amdroid/com.amdroidalarmclock.amdroid.AmdroidAppWidgetProvider")

    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_text("Can't add widget")
    end
end
