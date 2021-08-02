function on_resume()
    ui:show_text("Open dialog")
end

function on_click()
    dialog_items = { "One", "Two", "Three" }
    ui:show_checkbox_dialog("Title", dialog_items, "Two")
end

function on_dialog_action(idx)
    ui:show_toast("Checked: "..dialog_items[idx])
end
