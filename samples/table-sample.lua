function on_resume()
    local table = {
        "12345678", "", "",
        "1", "2", "3",
        "4", "5", "6",
        "7", "8", "9",
    }

    ui:show_table(table, 3, true, false, "Nothing there")
end

function on_click(idx)
    ui:show_toast("Cell: "..idx)
end

