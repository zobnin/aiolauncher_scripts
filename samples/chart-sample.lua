function on_resume()
    local points = { 
        { 1, 1 },
        { 2, 2 },
        { 3, 1 },
    }
    ui:show_chart("Test", points, true, "Folded", "Copyright")
end
