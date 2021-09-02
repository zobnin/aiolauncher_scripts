function on_resume()
    ui:show_lines({
        "Make call 123",
        "Send SMS 123",
        "Show dialog"
    })
end

function on_click(idx)
    if idx == 1 then
        phone:make_call("123")
    elseif idx == 2 then
        phone:send_sms("123", "Test")
    else
        local first_contact = phone:get_contacts()[1]
        phone:show_contact_dialog(first_contact.id)
    end
end

