function onResume()
    ui:showLines({ 
        "Click to open dialog", 
        "Click to open dialog with custom buttons",
        "Click to open edit dialog",
    })
end

function onClick(idx)
    if idx == 1 then
        ui:showDialog("Dialog title", "This is dialog")
    elseif idx == 2 then
        ui:showDialog("Dialog title", "This is dialog", "Button 1", "Button 2")
    elseif idx == 3 then
        ui:showEditDialog("Dialog title", "Write any text", "default text")
    end
end

function onDialogAction(value)
    if value == 1 then
        ui:showToast("Button 1 clicked!")
    elseif value == 2 then
        ui:showToast("Button 2 clicked!")
    elseif type(value) == "string" then
        ui:showToast("Text: "..value)
    end
end
