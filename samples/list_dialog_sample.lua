function on_resume()
    ui:show_lines{
        "List dialog",
        "List dialog without search",
        "List dialog without zebra",
        "List dialog with splitted strings",
    }
end

function on_click(idx)
    if idx == 1 then
        ui:show_list_dialog{
            title = "Title",
            lines = { "First line", "Second line", "Third line" },
        }
    elseif idx == 2 then
        ui:show_list_dialog{
            title = "Title",
            lines = { "First line", "Second line", "Third line" },
            search = false,
        }
    elseif idx == 3 then
        ui:show_list_dialog{
            title = "Title",
            lines = { "First line", "Second line", "Third line" },
            zebra = false,
        }
    elseif idx == 4 then
        ui:show_list_dialog{
            title = "Title",
            lines = { "First|line", "Second|line", "Third line" },
            split_symbol = "|",
        }
    end
end

function on_dialog_action(idx)
    if idx < 0 then
        ui:show_toast("Dialog closed")
    else
        ui:show_toast("Clicked element: "..idx)
    end
end
