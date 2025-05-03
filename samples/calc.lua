
function on_alarm()
    ui:show_text("Enter an expression")
end

function on_click()
    ui:show_edit_dialog("Enter an expression")
end

function on_dialog_action(text)
    if text == "" then
        on_alarm()
    else
        ui:show_text(calculate_string(text))
    end
end

function sqrt(x)
    return math.sqrt(x)
end

function pow(x, y)
    return math.pow(x,y)
end

function calculate_string(str)
    return load("return "..str)
end 
 
