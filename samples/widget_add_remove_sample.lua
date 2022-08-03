function on_resume()
    ui:show_lines{
        "Add clock widget",
        "Add clock widget (position 1)",
        "Add clock widget (position 5)",
        "Remove clock widget",
        "Swap first and third widgets",
        "Swap back",
    }
end

function on_click(idx)
    if idx == 1 then
        aio:add_widget("clock")
    elseif idx == 2 then
        aio:add_widget("clock", 1)
    elseif idx == 3 then
        aio:add_widget("clock", 5)
    elseif idx == 4 then
        aio:remove_widget("clock")
    elseif idx == 5 then
        aio:move_widget(1, 3)
    elseif idx == 6 then
        aio:move_widget(3, 1)
    end
end
