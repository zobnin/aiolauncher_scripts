function on_resume()
    ui:show_text("Click to freeze launcher")
end

function on_click()
    while true do
        system:copy_to_clipboard("http://google.com")
    end
end
