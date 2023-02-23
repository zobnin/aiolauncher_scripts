-- name = "Script #5"
-- type = "search"

function on_search()
    local points = {
        { 1628501740654, 123456789 },
        { 1628503740654, 300000000 },
        { 1628505740654, 987654321 },
    }

    search:show_chart(points, "x:date y:number")
end

function on_click(idx)
    if idx == 1 then
        system:vibrate(100)
    else
        system:vibrate(300)
    end
end
