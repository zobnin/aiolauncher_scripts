-- name = "Android widgets dumper"
-- foldable = false

-- Place app package name with widget here
app_pkg = "com.google.android.googlequicksearchbox"
--app_pkg = "com.weather.Weather"
--app_pkg = "com.google.android.apps.tasks"
--app_pkg = "com.android.chrome"
--app_pkg = "com.whatsapp"

-- Widget size (string from "1x1" to "4x4")
-- In most cases you can use nil
widget_size = "4x1"

-- Globals
labels = {}
providers = {}
dump = ""
wid = -1

function on_resume()
    local list = widgets:list(app_pkg)

    if list == nil then
        ui:show_text("Error: No widgets")
        return
    end

    labels = map(function(it) return it.label end, list)
    providers = map(function(it) return it.provider end, list)

    w_content = ""

    if wid < 0 then
        ui:show_lines(labels)
    else
        widgets:request_updates(wid, widget_size)
    end
end

function on_click(idx)
    if w_content == "" then
        wid = widgets:setup(providers[idx])
        widgets:request_updates(wid, widget_size)
    else
        system:copy_to_clipboard(w_content)
    end
end

function on_app_widget_updated(bridge)
    local provider = bridge:provider()
    local dump = bridge:dump_tree()
    local colors = bridge:dump_colors()
    w_content = provider.."\n\n"..dump.."\n\n"..serialize(colors)

    ui:show_text("%%txt%%"..w_content)
    debug:log("dump:\n\n"..w_content)
end

