function on_resume()
    ui:show_text("Mail widget on the screen: " .. tostring(aio:is_widget_added("mail")))
end
