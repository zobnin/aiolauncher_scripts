function on_resume()
    ui:show_text("Open dialog")
end

function on_click()
    dialog_items = { "One", "Two", "Three" }
    ui:show_radio_dialog("Title", dialog_items, 2)
end

function on_dialog_action(idx)
    if idx == -1 then
        ui:show_toast("Dialog cancelled")
    else
        ui:show_toast("Choosen: "..dialog_items[idx])
    end
end
