function on_alarm()
    weather:get_by_hour()
end

function on_weather_result(tab)
    local tab2 = {}

    for k,v in pairs(tab) do
        table.insert(tab2, time_to_string(v.time)..": "..v.temp)
    end

    ui:show_lines(tab2)
end

function time_to_string(time)
    return os.date("%c", time)
end
