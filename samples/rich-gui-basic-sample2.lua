-- name = "Rich GUI Basic sample #2"

function on_resume()
    my_gui = gui{
        {"progress", "Progress #1", {progress = 30}},
        {"new_line", 1},
        {"progress", "Progress #2", {progress = 60}},
        {"new_line", 1},
        {"progress", "Progress #3", {progress = 90}},
    }

    my_gui.render()
end

