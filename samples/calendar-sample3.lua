function on_resume()
    ui:show_text("Tap to create new event")
end

function on_click(idx)
    calendar:open_new_event(os.time(), os.time() + 3600)
end
