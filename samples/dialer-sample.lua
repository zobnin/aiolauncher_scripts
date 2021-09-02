function on_resume()
    ui:show_lines({ "Make call 123", "Send SMS 123" })
end

function on_click(idx)
    if idx == 1 then
        phone:make_call("123")
    else
        phone:send_sms("123", "Test")
    end
end
