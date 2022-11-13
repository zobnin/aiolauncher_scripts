function on_resume()
    ui:show_text("Empty")
end

function on_widget_action(action, name)
    ui:show_toast(name.." "..action)
end

