-- name = "Rich GUI sample"

function on_resume()
    local app = apps:app("ru.execbit.aiolauncher")
    if app == nil then return end

    my_gui = gui{
        {"text", "<b>Title</b>", {size = 19, color = "#ff0000", gravity = "center_h"}},
        {"new_line", 2},
        {"text", "Hello, World", {size = 21}},
        {"spacer", 2},
        {"text", "Center small text", {size = 8, gravity = "center_v"}},
        {"text", "Top right text", {size = 8, gravity = "top|right"}},
        {"new_line", 1},
        {"button", "Ok", {color = "#00aa00"}},
        {"button", "Neutral", {color = "#666666", gravity = "right"}},
        {"spacer", 2},
        {"button", "Cancel", {color = "#ff0000", gravity = "right"}},
        {"new_line", 2},
        {"progress", "Progress #1", {progress = 70}},
        {"progress", "Progress #2", {progress = 30, color = "#0000ff"}},
        {"new_line", 2},
        {"button", "Center button", {gravity = "center_h"}},
        {"new_line", 2},
        {"icon", "fa:microphone", {size = 17, color = "#00ff00", gravity = "center_v"}},
        {"spacer", 4},
        {"icon", "fa:microphone", {size = 22, gravity = "center_v"}},
        {"spacer", 4},
        {"icon", "fa:microphone", {size = 27, gravity = "center_v"}},
        {"spacer", 4},
        {"icon", "fa:microphone", {size = 32, gravity = "center_v"}},
        {"icon", app.icon, {size = 17, gravity = "center_v|right"}},
        {"spacer", 4},
        {"icon", app.icon, {size = 22, gravity = "center_v"}},
        {"spacer", 4},
        {"icon", app.icon, {size = 27, gravity = "center_v"}},
        {"spacer", 4},
        {"icon", app.icon, {size = 32, gravity = "center_v"}},
    }

    my_gui.render()
end

function on_apps_changed()
    on_resume()
end

function on_click(idx, extra)
    local elem_name = my_gui.ui[idx][1]

    if elem_name == "text" then
        my_gui.ui[idx][2] = "<u>"..my_gui.ui[idx][2].."</u>"
    elseif elem_name == "button" then
        my_gui.ui[idx][2] = "Clicked"
    elseif elem_name == "progress" then
        my_gui.ui[idx][3].progress = 100
    elseif elem_name == "icon" then
        my_gui.ui[idx][3].color = "#ff0000"
    end

    my_gui.render()
    ui:show_toast("Clicked: "..my_gui.ui[idx][1])
end

function on_long_click(idx)
    ui:show_toast("Long click: "..my_gui.ui[idx][1])
end
