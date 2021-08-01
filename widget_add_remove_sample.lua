function on_resume()
    ui:show_buttons({ "Add clock widget", "Remove clock widget" })
end

function on_click(idx)
    if idx == 1 then
        aio:add_widget("clock")
    else
        aio:remove_widget("clock")
    end
end
