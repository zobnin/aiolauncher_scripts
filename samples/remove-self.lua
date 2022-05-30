function on_resume()
    ui:show_text("Tap to remove me")
end

function on_click()
    aio:remove_widget()
end
