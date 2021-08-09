function on_resume()
    local points = { 
        { 1628501740654, 123 },
        { 1628503740654, 300 },
        { 1628505740654, 175 },
    }
    ui:show_chart("Test", points, "MM.dd")
end
