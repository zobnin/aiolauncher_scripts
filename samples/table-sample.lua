function on_resume()
    local table = {
        "1", "20", "30",
        "40", "5", "66",
        "07", "28", "9",
    }

    ui:show_table(table, 3, true)
end

function on_click(idx)
    ui:show_toast("Cell: "..idx)
end

