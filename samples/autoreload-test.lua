function on_resume()
    local booleans = { true, false }

    if booleans[math.random(1, 2)] then
        ui:show_text("Loaded!")
    end
end
