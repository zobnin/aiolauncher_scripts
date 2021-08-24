function on_resume()
    local table = {
        { "<", "1 USD = 74.023 RUB -0.01%", ">" },
        { "<", "1 USD = 74.023 RUB -0.01%", ">" },
        { "<", "1 USD = 74.023 RUB -0.01%", ">" },
    }

    ui:show_table(table, 2)
end

function on_click(idx)
    ui:show_toast("Cell: "..idx)
end

