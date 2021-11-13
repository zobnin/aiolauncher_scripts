function on_resume()
    ui:show_text("Tap to copy")
end

function on_click()
    system:copy_to_clipboard("test", true)
end
