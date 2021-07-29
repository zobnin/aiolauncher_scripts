function onAlarm()
    local dateStr = os.date('%Y%m%d') 
    net:getText("https://isdayoff.ru/"..dateStr) 
end

function onNetworkResult(result)
    if result == "0" then
        aio:showText("Сегодня рабочий день")
    elseif result == "1" then
        aio:showText("Сегодня выходной")
    else
        aio:showText("Ошибка")
    end
end
