function on_resume()
    local location = system:get_location()
    ui:show_text(location[1].." "..location[2])
end
