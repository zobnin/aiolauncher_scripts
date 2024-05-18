function on_resume()
    ui:show_lines{
        "Show notify",
        "Update notify",
        "Cancel notify",
    }
end

function on_click(idx)
    if idx == 1 then
        system:show_notify{
            message = "Just message",
            silent = true,
            action1 = "cancel",
        }
    elseif idx == 2 then
        system:show_notify{
            message = "Message updated",
            silent = true,
            action1 = "cancel",
            action2 = "action #2",
            action3 = "action #3",
        }
    else
        system:cancel_notify()
    end
end

function on_notify_action(idx, action)
    ui:show_toast("action: "..idx..": "..action)

    if action == "cancel" then
        system:cancel_notify()
    end
end
