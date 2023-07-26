-- name = "Covid info"
-- description = "Cases of illness and death from covid"
-- data_source = "covid19api.com"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

equals = "<font color=\""..ui:colors().secondary_text.."\"> = </font>"

function on_alarm()
    http:get("https://api.covid19api.com/summary")
end

function on_network_result(result, code)
    if code >= 200 and code < 299 then
        local new = ajson:get_value(result, "object object:Global int:NewConfirmed")
        local total = ajson:get_value(result, "object object:Global int:TotalConfirmed")
        local newDeaths = ajson:get_value(result, "object object:Global int:NewDeaths")
        local totalDeaths = ajson:get_value(result, "object object:Global int:TotalDeaths")

        ui:show_lines({
            "<b>Disease</b> | total"..equals..comma_value(total).." | new"..equals..comma_value(new),
            "<b>Deaths</b> | total"..equals..comma_value(totalDeaths).." | new"..equals..comma_value(newDeaths)
        })
    end
end

-- credit http://richard.warburton.it
function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

