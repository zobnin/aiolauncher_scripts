-- name = "Мобильный оператор"
-- description = "Cкрипт отображает мобильного оператора по номеру телефона"
-- data_source = "http://rosreestr.subnets.ru/"
-- type = "search"
-- lang = "ru"
-- author = "Andrey Gavrilov"
-- version = "1.0"

local num = ""

function on_search(input)
	num = input:match("^n (.+)")
	if not num then
		return
	end
	search:show({"Оператор "..num})
end

function on_click()
	local uri = "http://rosreestr.subnets.ru/?get=num&format=json&num=" .. num:gsub("%D", "")
	http:get(uri)
	return false
end

function on_network_result(result)
	local json = require "json"
	local t = json.decode(result)
	if not t.error then
		if not t["0"].country then
			if not t["0"].moved2operator then
				search:show({t["0"].operator, t["0"].region})
			else
				search:show({t["0"].moved2operator, t["0"].region})
			end
		else
			search:show({t["0"].country, t["0"].description})
		end
	else
		search:show({t.error})
	end
end
