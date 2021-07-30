-- name = "Covid info"
-- description = "Cases of illness and death from covid (covid19api.com)"
-- type = "widget"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

equals = "<font color=\"#9E9E9E\"> = </font>"

function onAlarm()
    net:getText("https://api.covid19api.com/summary")
end

function onNetworkResult(result)
    local new = json:getValue(result, "object object:Global int:NewConfirmed")
    local total = json:getValue(result, "object object:Global int:TotalConfirmed")
    local newDeaths = json:getValue(result, "object object:Global int:NewDeaths")
    local totalDeaths = json:getValue(result, "object object:Global int:TotalDeaths")
    
    ui:showLines({
        "<b>Disease:</b> total"..equals..comma_value(total).." new"..equals..comma_value(new),
        "<b>Deaths:</b> total"..equals..comma_value(totalDeaths).." new"..equals..comma_value(newDeaths)
    })
end

function comma_value(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

