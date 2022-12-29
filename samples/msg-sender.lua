function on_resume()
    ui:show_lines{
        "send text to msg-receiver.lua script",
        "send 123 to all",
        "send table to all",
    }
end

function on_click(idx)
    if idx == 1 then
        aio:send_message("text", "msg-receiver.lua")
    elseif idx == 2 then
        aio:send_message(123)
    else
        aio:send_message{ "one", "two", "three" }
    end
end
