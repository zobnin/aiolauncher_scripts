-- name = "Amdroid Next Alarm"
-- description = "AIO wrapper for the Amdroid next alarm app widget"
-- type = "widget"
-- author = "Theodor Galanis"
-- version = "1.0.2"
-- foldable = "false"
-- uses_app = "com.amdroidalarmclock.amdroid"

local prefs = require "prefs"

local next_alarm = ""
local accent="#FFFFFF"

function on_resume()
    if not widgets:bound(prefs.wid) then
        setup_app_widget()
    end
     accent = aio:colors().accent
    widgets:request_updates(prefs.wid)
end

function on_app_widget_updated(bridge)
    local tab = bridge:dump_table()

    next_alarm = tab.v_layout_1.text_1
    w_bridge = bridge

    if next_alarm ~= nil
 then
        my_gui=gui{
         {"text", " %%fa:alarm-clock%% <span style=\"color:#FFFFFF\">"..next_alarm.."</span>", {gravity="center_h", color=accent}}
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

function setup_app_widget()
    local id = widgets:setup("com.amdroidalarmclock.amdroid/com.amdroidalarmclock.amdroid.widgets.NextAlarmWidgetProvider")

    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_text("Can't add widget")
    end
end
