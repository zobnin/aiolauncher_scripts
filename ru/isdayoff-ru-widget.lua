-- name = "Сегодня выходной?"
-- description = "Показывает, выходной ли сегодня день."
-- data_source = "isdayoff.ru"
-- type = "widget"
-- lang = "ru"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

function on_alarm()
    local dateStr = os.date('%Y%m%d')
    http:get("https://isdayoff.ru/"..dateStr)
end

function on_network_result(result)
    if result == "0" then
        ui:show_text("Сегодня рабочий день")
    elseif result == "1" then
        ui:show_text("Сегодня выходной")
    else
        ui:show_text("Ошибка")
    end
end
