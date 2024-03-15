-- name = "Chrome shortcuts"
-- description = "AIO wrapper for the Chrome shortcuts app widget"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
-- foldable = "false"
-- uses_app: "com.android.chrome"

local prefs = require "prefs"
prefs._name = "chrome"

local buttons_labels = {"fa:magnifying-glass", "fa:microphone", "fa:hat_cowboy_side", "fa:camera", "fa:gamepad"}
local buttons_targets = {"h_layout_2", "image_2", "image_3", "image_4", "image_5"}
local w_bridge = nil

function on_resume()
    if not widgets:bound(prefs.wid) then
        setup_app_widget()
    end

    widgets:request_updates(prefs.wid)
end

function on_app_widget_updated(bridge)
    w_bridge = bridge
    ui:show_buttons(buttons_labels)
end

function on_click(idx)
    w_bridge:click(buttons_targets[idx])
end

function setup_app_widget()
    local id = widgets:setup("com.android.chrome/org.chromium.chrome.browser.quickactionsearchwidget.QuickActionSearchWidgetProvider$QuickActionSearchWidgetProviderSearch")
    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_text("Can't add widget")
        return
    end
end
