-- name = "Праздники"
-- description = "Виджет отображает предстоящие праздники."
-- data_source = "date.nager.at"
-- type = "widget"
-- lang = "ru"
-- author = "Andrey Gavrilov"
-- version = "1.0"

--API--
local api_url = "https://date.nager.at/api/v3/NextPublicHolidays/RU"

local lines = {}

local json = require "json"

function on_resume()
    ui:show_lines(lines)
end

function on_alarm()
    http:get(api_url)
end

function on_network_result(result, code)
    if code < 200 or code > 299 then
        ui:show_text("Network error: "..code)
        return
    end

    local ok, t = pcall(json.decode, result)

    if not ok or type(t) ~= "table" then
        ui:show_text("Invalid data: "..result)
        return
    end

    for i = 1, #t, 1 do
	    local date = t[i].date:replace("-", ".")
		local name = t[i].localName
		lines[i] = date.." - "..name
    end
    ui:show_lines(lines)
end
