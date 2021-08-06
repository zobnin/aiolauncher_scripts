function on_resume()
    ui:set_title("New title")
    ui:show_text("Original title: "..ui:get_default_title())
end
