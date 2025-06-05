-- name = "Shell widget"
-- description = "Shows the result of executing console commands"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
-- foldable = "false"

current_output = "Click to enter command"

function on_preview()
    ui:show_text("Shows the result of executing console commands")
end

function on_resume()
    redraw()
end

function redraw()
    ui:show_text("%%txt%%"..current_output)
end

function on_click(idx)
    dialogs:show_edit_dialog("Enter command")
end

function on_dialog_action(text)
    system:exec(text)
end

function on_shell_result(text)
    if text == "" then
        current_output = "no output"
    else
        current_output = text
    end

    redraw()
end

