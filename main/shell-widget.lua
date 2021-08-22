-- name = "Shell widget"
-- description = "Shows the result of executing console commands"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

current_output = "Click to enter command"

function on_resume()
    redraw()
end

function redraw()
    ui:show_text(current_output)
end

function on_click(idx)
    ui:show_edit_dialog("Enter command")
end

function on_dialog_action(text)
    system:exec(text)
end

function on_shell_result(text)
    current_output = text
    redraw()
end

