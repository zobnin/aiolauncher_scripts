function on_resume()
    local tab = {
        { "1", "2", "3" },
        { "4", "5", "6" },
        { "7", "8", "9" },
    }

    local folded = { "-1", "-2", "-3" }
    ui:show_table(tab, 0, true, folded)
end
