function on_resume()
    ui:show_lines{
        "Plain editor",
        "Plain editor with delete button",
        "Editor with colors",
        "Editor with date",
        "Editor with date and colors",
        "Editor with chekboxes",
    }
end

function on_click(idx)
    if idx == 1 then
        ui:show_rich_editor{
            text = "Sample text"
        }
    elseif idx == 2 then
        ui:show_rich_editor{
            text = "Sample text",
            new = false,
        }
    elseif idx == 3 then
        ui:show_rich_editor{
            text = "Sample text #2",
            colors = { "#FF0000", "#00FF00", "#0000FF" },
            color = 1
        }
    elseif idx == 4 then
        ui:show_rich_editor{
            text = "Sample text #3",
            due_date = os.time()
        }
    elseif idx == 5 then
        ui:show_rich_editor{
            text = "Sample text #3",
            due_date = os.time{ year = 2023, month = 1, day = 1 },
            colors = { "#FF0000", "#00FF00", "#0000FF" },
            color = 1
        }
    elseif idx == 6 then
        ui:show_rich_editor{
            text = "Sample text #4",
            checkboxes = {
                { name = "Checkbox #1", checked = true },
                { name = "Checkbox #2", checked = false }
            }
        }
    end
end

function on_dialog_action(result)
    if result == -1 then
        ui:show_toast("Canceled or deleted")
    else
        ui:show_toast(result.text)
    end
end
