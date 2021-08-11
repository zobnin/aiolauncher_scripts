function on_resume()
    local points = { 
        { 1628501740654, 123456789 },
        { 1628503740654, 300000000 },
        { 1628505740654, 987654321 },
    }
    ui:show_chart(points, "x:date y:number")
end
