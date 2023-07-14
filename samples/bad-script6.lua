-- testing = "true"

function on_resume()
    ui:show_text("Tap to halt")
end

function on_click()
    os.exit()
end
