function onResume()
    ui:showLines({ "Click to open dialog", "Click to open dialog with custom buttons" })
end

function onClick(idx)
    if idx == 1 then
        ui:showDialog("Dialog title", "This is dialog")
    elseif idx == 2 then
        ui:showDialog("Dialog title", "This is dialog", "Button 1", "Button 2")
    end
end

function onDialogClick(idx)
    if idx == 1 then
        ui:showToast("Button 1 clicked!")
    elseif idx == 2 then
        ui:showToast("Button 2 clicked!")
    end
end
