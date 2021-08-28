function on_resume()
    ui:show_text("Open dialog")
end

function on_click()
    dialog_items = { "One", "Two", "Three" }
    ui:show_checkbox_dialog("Title", dialog_items, { 1, 3})
end

function on_dialog_action(tab)
    if tab == -1 then
        ui:show_toast("Dialog cancelled")
    else
        ui:show_toast("Checked: "..table_to_string(tab))
    end
end

function table_to_string(tab)
    local s = ""

    for k, v in ipairs(tab) do
        s = s..v.." "
    end

    return s
end
