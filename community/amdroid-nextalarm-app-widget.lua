-- name = "Amdroid Next Alarm"
-- description = "AIO wrapper for the Amdroid Next alarm app widget"
-- type = "widget"
-- author = "Theodor Galanis (t.me/TheodorGalanis)"
-- version = "1.11"
-- foldable = "false"
-- uses_app = "com.amdroidalarmclock.amdroid"

local prefs = require "prefs"

local next_alarm = ""
local accent="#888888"

function on_resume()
    if not widgets:bound(prefs.wid) then
        setup_app_widget()
    end
     accent = aio:colors().accent
     primary = aio:colors().primary_text
    widgets:request_updates(prefs.wid)
end

function on_app_widget_updated(bridge)
    local tab = bridge:dump_table()

    next_alarm = tab.v_layout_1.text_1
    w_bridge = bridge

    if next_alarm ~= nil
 then
        my_gui=gui{
    {"icon", "fa:alarm-clock", {gravity="center_h|center_v",color = accent}},
{"spacer", 2},
    {"text", next_alarm, {gravity="anchor_prev"}}
  }
    else
    my_gui=gui{
         {"text", "Empty", {gravity="center_h" }}
         }
    end
    my_gui.render()
end

function on_click(idx)
    w_bridge:click(next_alarm)
end

function on_settings()
dialogs:show_dialog("Amdroid app Next Alarm widget", "This script wrapper uses Amdroid app's Next alarm widget to display the next scheduled alarm. No settings are required.")
end

function setup_app_widget()
    local id = widgets:setup("com.amdroidalarmclock.amdroid/com.amdroidalarmclock.amdroid.widgets.NextAlarmWidgetProvider")

    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_text("Can't add widget")
    end
end
