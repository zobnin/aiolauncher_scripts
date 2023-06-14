local url = "https://aiolauncher.app"

function on_resume()
    ui:show_text("Click me")
end

function on_click()
    system:open_browser(url)
end
