function on_resume()
    ui:show_lines({ "Vibrate", "Alarm" })
end

function on_click(idx)
    if idx == 1 then
        system:vibrate(500)
    else
        system:alarm_sound(5)
    end
end
