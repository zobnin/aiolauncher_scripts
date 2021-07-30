-- name = "Курсы валют"
-- description = "Free Currency Rates API (https://github.com/fawazahmed0/currency-api#readme). Нажатие на дату загружает текущие курсы, на остальные строки - сдвигает дату на один день назад."
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"

curs1 = {"usd", "eur", "eur", "gbp", "gbp", "chf", "aed", "btc"}
curs2 = {"rub", "rub", "usd", "rub", "usd", "usd", "usd", "usd"}

function onAlarm()
	local locDate = "latest"
    getRates(locDate)
end
	
function getRates(locDate)
	net:getText("https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/"..locDate.."/currencies/usd.json")
end

function onNetworkResult(result)
	dat = json:getValue(result, "object string:date")
	tab = {}
	table.insert(tab, "<u>"..dat.."</u>")
	for idx = 1, #curs1, 1 do
		local cur1 = curs1[idx]
		local cur2 = curs2[idx]
		local rate1 = json:getValue(result, "object object:usd double:"..cur1)
		local rate2 = json:getValue(result, "object object:usd double:"..cur2)
		local rate = rate2/rate1
		table.insert(tab, "1 "..string.upper(cur1).." = "..rate.." "..string.upper(cur2))
	end
	ui:showLines(tab)
end

function onClick(idx)
	if idx == 1 then
		local locDat = "latest"
		getRates(locDat)
	else
		local locYear = tonumber(string.sub(dat, 1, 4))
		local locMonth = tonumber(string.sub(dat, 6,7))
		local locDay = tonumber(string.sub(dat, 9, 10))
		local locTime = os.time{year=locYear, month=locMonth, day=locDay} - (60*60*24)
		local locDate = os.date("%Y-%m-%d", locTime)
		getRates(locDate)
	end
end
