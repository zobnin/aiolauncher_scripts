-- name = "Profile Switcher"
-- version = "1.1"
-- description = "Tap: restore profile / Long-press: save to profile"
-- type = "widget"
-- author = "Marcus Johansson"

local profs
local profile

function on_load()
    profs = profiles:list()
    ui:show_buttons(profs)
end

function on_click(idx)
    profile = profs[idx]
    profiles:restore(profile)
    ui:show_toast(profile..": Restored")
end

function on_long_click(idx)
    profile = profs[idx]
    title = 'Save to "'..profile..'" ?'
    text = 'Do you want to save the current screen state to the "'..profile..'" profile ?'
    dialogs:show_dialog(title, text, "Yes", "Cancel")
end

function on_dialog_action(value)
    if value == 1 then 
       profiles:dump(profile)
       ui:show_toast(profile..": Saved")
    elseif value == 2 then
       ui:show_toast("Canceled")
    end
end