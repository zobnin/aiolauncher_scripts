function on_resume()
    ui:set_title("New title")
    ui:show_text("Original title: "..ui:default_title())
end
