-- name = "Мобильный оператор"
-- description = "Cкрипт отображает мобильного оператора по номеру телефона"
-- data_source = "http://rosreestr.subnets.ru/"
-- type = "search"
-- lang = "ru"
-- author = "Andrey Gavrilov"
-- version = "1.1"

function on_search(input)
	local num = input:match("^(+?7?%d%d%d%d%d%d%d%d%d%d+)$")
	if not num then
		return
	end
	show_operator(num)
end

function show_operator(num)
    local json = require "json"
	local uri = "http://rosreestr.subnets.ru/?get=num&format=json&num=" .. num:gsub("%D", "")
	local tab = {}
	local result = shttp:get(uri)
	if not result.error then
		local t = json.decode(result.body)
		if not t.error then
			if not t["0"].country then
				if not t["0"].moved2operator then
				    table.insert(tab, t["0"].operator)
				else
				    table.insert(tab, t["0"].moved2operator)
				end
				table.insert(tab, t["0"].region)
			else
			    table.insert(tab, t["0"].country)
			    table.insert(tab, t["0"].description)
			end
		else
		    table.insert(tab, t.error)
		end
	else
	    table.insert(tab, result.error)
	end
	search:show_lines({table.concat(tab, ", ")}, {aio:colors().button})
end
