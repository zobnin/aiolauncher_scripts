-- name = "Rich GUI Basic sample"

function on_resume()
    my_gui = gui{
        {"text", "First line"},
        {"new_line", 1},
        {"text", "Second line"},
        {"new_line", 2},
        {"button", "Button #1"},
        {"spacer", 2},
        {"button", "Button #2"},
    }

    my_gui.render()
end

