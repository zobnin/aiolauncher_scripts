function onAlarm()
    local dateStr = os.date('%Y%m%d') 
    net:getText("https://isdayoff.ru/"..dateStr) 
end

function onNetworkResult(result)
    if result == "0" then
        ui:showText("Сегодня рабочий день")
    elseif result == "1" then
        ui:showText("Сегодня выходной")
    else
        ui:showText("Ошибка")
    end
end
