buttons = { "Disabled", "Disabled", "Disabled" }

function onResume()
    redraw()
end

function onClick(idx) 
    if buttons[idx] == "Disabled" then
        buttons[idx] = "Enabled"
    else
        buttons[idx] = "Disabled"
    end

    redraw()
end

function redraw()
    ui:showButtons(buttons)
end
