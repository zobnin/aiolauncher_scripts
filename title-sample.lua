function on_resume()
    ui:show_text("Original title: "..ui:get_default_title())
    ui:set_title("New title")
end
