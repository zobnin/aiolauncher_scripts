function on_resume()
    if ui.show_list_dialog then
        ui:show_text("list dialog is supported")
    else
        ui:show_text("list dialog is not supported")
    end
end
