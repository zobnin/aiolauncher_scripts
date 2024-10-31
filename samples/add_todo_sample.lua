function on_resume()
    ui:show_lines{
        "Add todo #1",
        "Add todo #2",
        "Add todo #3",
    }
end

function on_click(idx)
    if idx == 1 then
        aio:add_todo("face-smile", "Todo #1")
    elseif idx == 2 then
        aio:add_todo("face-smile-tongue", "Todo #2")
    else
        aio:add_todo("face-smile-tear", "Todo #3")
    end
end
