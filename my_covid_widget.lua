-- name = "Covid info #2"
-- description = "Статистика по заболеввниям и выздоровлениям COVID-19"
-- data_source = "https://covid19api.com/"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

local api_url = "https://api.covid19api.com/summary"
local ccode = "RU"

local json = require "json"
local equals = "<font color=\""..ui:get_secondary_text_color().."\"> = </font>"
local tab = {}

function on_alarm()
    http:get(api_url)
end

function on_network_result(result)
   local t=json.decode(result)
   if ccode == "" then
       local dat = string.sub(t.Global.Date,1,10):gsub("-",".")
       ui:set_title(ui:get_default_title().." "..dat)
       local new = t.Global.NewConfirmed
       local total = t.Global.TotalConfirmed
       local newDeaths = t.Global.NewDeaths
       local totalDeaths = t.Global.TotalDeaths
       local newRecovered = t.Global.NewRecovered
       local totalRecovered = t.Global.TotalRecovered
       local newActives = new - newRecovered - newDeaths
       local totalActives = total - totalRecovered - totalDeaths
       tab = {
            "<u>Заболевшие</u> | всего"..equals..comma_value(total).." | новые"..equals..comma_value(new),
            "<u>Выздоровевшие</u> | всего"..equals..comma_value(totalRecovered).." | новые"..equals..comma_value(newRecovered),
            "<u>Умершие</u> | всего"..equals..comma_value(totalDeaths).." | новые"..equals..comma_value(newDeaths),
            "<u>Активные</u> | всего"..equals..comma_value(totalActives).." | новые"..equals..comma_value(newActives)
    }
   else
       local i = 1
       while 1 do
            if t.Countries[i].CountryCode == ccode then
                break
            end
            i = i + 1
        end
        local dat = string.sub(t.Countries[i].Date,1,10):gsub("-",".")
        ui:set_title(ui:get_default_title().." "..ccode.." "..dat)
        local new = t.Countries[i].NewConfirmed
        local total = t.Countries[i].TotalConfirmed
        local newDeaths = t.Countries[i].NewDeaths
        local totalDeaths = t.Countries[i].TotalDeaths
        local newRecovered = t.Countries[i].NewRecovered
        local totalRecovered = t.Countries[i].TotalRecovered
        local newActives = new - newRecovered - newDeaths
        local totalActives = total - totalRecovered - totalDeaths
        tab = {
            "<u>Заболевшие</u> | всего"..equals..comma_value(total).." | новые"..equals..comma_value(new),
            "<u>Выздоровевшие</u> | всего"..equals..comma_value(totalRecovered).." | новые"..equals..comma_value(newRecovered),
            "<u>Умершие</u> | всего"..equals..comma_value(totalDeaths).." | новые"..equals..comma_value(newDeaths),
            "<u>Активные</u> | всего"..equals..comma_value(totalActives).." | новые"..equals..comma_value(newActives)
        }
    end
    ui:show_lines(tab)
end

function comma_value(n) -- credit http://richard.warburton.it
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
  return (left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right):gsub(","," ")
end

function on_resume()
    ui:set_folding_flag(true)
    ui:show_lines(tab)
end
