buttons = { "Disabled", "Disabled", "Disabled" }

function on_resume()
    redraw()
end

function on_click(idx) 
    if buttons[idx] == "Disabled" then
        buttons[idx] = "Enabled"
    else
        buttons[idx] = "Disabled"
    end

    redraw()
end

function redraw()
    ui:show_buttons(buttons)
end
