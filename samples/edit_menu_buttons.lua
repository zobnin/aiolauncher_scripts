edit_mode_buttons = { "fa:home", "fa:heart", "fa:gamepad" }

function on_resume()
    ui:set_edit_mode_buttons(edit_mode_buttons)
    ui:show_text("Swipe to ppen edit mode")
end

function on_edit_mode_button_click(idx)
    ui:show_toast(edit_mode_buttons[idx])
end
