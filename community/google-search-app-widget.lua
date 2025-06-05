-- name = "Google search"
-- description = "AIO wrapper for the Google search app widget - open widget settings for options"
-- type = "widget"
-- author = "Theodor Galanis (t.me/TheodorGalanis)"
-- version = "2.7"
-- foldable = "false"
-- uses_app: "com.google.android.googlequicksearchbox"

local prefs = require "prefs"

local w_bridge = nil
local indices = {}

function on_alarm()
    if not widgets:bound(prefs.wid) then
        setup_app_widget()
    end
    if not prefs.mode then
    prefs.mode = 1
    end
   mode = prefs.mode
   indices = set_indices()
  widgets:request_updates(prefs.wid)
end

function on_app_widget_updated(bridge)
    w_bridge = bridge
    local tab = {
{"button", "fa:magnifying-glass", {expand = true}},
{"spacer", 2},
{"button", "fa:sun-cloud"},
{"spacer", 2},
{"button", "fa:asterisk"},
{"spacer", 2},
{"button", "fa:microphone"},
{"spacer", 2},
{"button", "fa:camera"}
}

tab = set_gui(tab)
my_gui = gui(tab)
my_gui.render()
end

function on_click(idx)
if idx == indices[1] then
    w_bridge:click("image_4")
elseif idx == indices[2] then
    intent:start_activity(open_weather())
elseif idx == indices[3] then
    w_bridge:click("image_7")
elseif idx == indices[4] then
    w_bridge:click("image_11")
elseif idx == indices[5] then
    w_bridge:click("image_12")
   else return
end
end

function on_settings()
local tab = {"Left-handed mode with weather", "Left-handed mode, no weather", "Right-handed mode with weather", "Right-handed mode, no weather" }
dialogs:show_radio_dialog("Select mode", tab, mode)
end

function on_long_click(idx)
if idx == indices[1] then
ui:show_toast("Google search")
elseif idx == indices[2] then
ui:show_toast("Google weather")
elseif idx == indices[3] then
    ui:show_toast("Google discover")
elseif idx == indices[4] then
   ui:show_toast("Google voice search")
elseif idx == indices[5] then
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

function set_indices()
local temp = {1, 3, 5, 7, 9}
 if mode == 2 then
temp = {1, 9, 3, 5, 7}
elseif mode == 3 then
temp = reverse (temp)
elseif mode == 4 then
temp = {7, 9, 5, 3, 1}
end
return temp
end

function set_gui(tab)
local temp = tab
 if mode == 2 or mode == 4 then
table.remove(tab, 3)
table.remove(tab, 3)
end
if mode > 2 then
   temp = reverse(temp)
end
return temp
end

function open_weather()
local tab ={}
tab.category = "MAIN"
tab.package = "com.google.android.googlequicksearchbox"
tab.component = "com.google.android.googlequicksearchbox/com.google.android.apps.search.weather.WeatherExportedActivity"
return tab
end
