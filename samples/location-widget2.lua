function on_resume()
    ui:show_text("Tap to request location")
end

function on_click()
    system:request_location()
    ui:show_text("Loading...")
end

function on_location_result(location)
    if location ~= nil then
        ui:show_text(location[1].." "..location[2])
    else
        ui:show_text("Error")
    end
end
