-- name = "Shell widget"
-- description = "Shows the result of executing console commands"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

currentOutput = "Click to enter command"

function onResume()
    redraw()
end

function redraw()
    ui:showText(currentOutput)
end

function onClick(idx)
    ui:showEditDialog("Enter command")
end

function onDialogAction(text)
    system:exec(text)
end

function onShellResult(text)
    currentOutput = text
    redraw()
end

