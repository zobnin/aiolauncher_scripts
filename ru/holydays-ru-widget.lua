-- name = "Праздники"
-- description = "Виджет отображает предстоящие праздники."
-- data_source = "date.nager.at"
-- type = "widget"
-- lang = "ru"
-- author = "Andrey Gavrilov"
-- version = "1.0"

--API--
local api_url = "https://date.nager.at/api/v3/NextPublicHolidays/RU"

--Настройка автосворачивания виджета--
local auto_folding = false

local lines = {}

local json = require "json"

function on_resume()
    if auto_folding then
        ui:set_folding_flag(true)
        ui:show_lines(lines)
	end
end

function on_alarm()
    http:get(api_url)
end

function on_network_result(result)
    local t = json.decode(result)
    for i = 1, #t, 1 do
	    local date = t[i].date:replace("-", ".")
		local name = t[i].localName
		lines[i] = date.." - "..name
    end
    ui:show_lines(lines)
end
