function on_resume()
    ui:show_lines({ 
        "Click to open dialog", 
        "Click to open dialog with custom buttons",
        "Click to open edit dialog",
    })
end

function on_click(idx)
    if idx == 1 then
        ui:show_dialog("Dialog title\nSubtitle", "This is dialog")
    elseif idx == 2 then
        ui:show_dialog("Dialog title", "This is dialog", "Button 1", "Button 2")
    elseif idx == 3 then
        ui:show_edit_dialog("Dialog title", "Write any text", "default text")
    end
end

function on_dialog_action(value)
    if value == -1 then
        ui:show_toast("Cancelled")
    elseif value == 1 then
        ui:show_toast("Button 1 clicked!")
    elseif value == 2 then
        ui:show_toast("Button 2 clicked!")
    elseif type(value) == "string" then
        ui:show_toast("Text: "..value)
    end
end
