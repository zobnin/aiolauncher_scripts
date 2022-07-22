function on_resume()
    ui:show_text("empty")
end

function on_message(value)
    if type(value) == "table" then
        ui:show_text("table first element: "..value[1])
    else
        ui:show_text(value)
    end
end
