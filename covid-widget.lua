function onAlarm()
    net:getText("https://api.covid19api.com/summary")
end

function onNetworkResult(result)
    local new = json:getValue(result, "object object:Global int:NewConfirmed")
    local total = json:getValue(result, "object object:Global int:TotalConfirmed")
    local newDeaths = json:getValue(result, "object object:Global int:NewDeaths")
    local totalDeaths = json:getValue(result, "object object:Global int:TotalDeaths")
    
    ui:showLines({
        "Disease:  total = "..total.."  new = "..new,
        "Deaths:  total = "..totalDeaths.."  new = "..newDeaths
    })
end
