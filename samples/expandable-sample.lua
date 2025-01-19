function on_resume()
    ui:set_expandable(true)

    if ui:is_expanded() then
        ui:show_text("Expanded mode")
    else
        ui:show_text("Standard mode")
    end
end
