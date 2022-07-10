function on_resume()
    ui:show_lines({ "One", "Two", "Three" }, nil, "Folded")
end

function on_click(idx)
    if idx == 0 then
        ui:show_toast("Folded")
    else
        ui:show_toast("Not folded")
    end
end
