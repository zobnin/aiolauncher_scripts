function on_resume()
    ui:show_lines{
        "Set progress 25%",
        "Set progress 50%",
        "Set progress 75%",
        "Set progress 100%",
    }
end

function on_click(idx)
    if idx == 1 then
        ui:set_progress(0.25)
    elseif idx == 2 then
        ui:set_progress(0.5)
    elseif idx == 3 then
        ui:set_progress(0.75)
    elseif idx == 4 then
        ui:set_progress(1)
    end
end
