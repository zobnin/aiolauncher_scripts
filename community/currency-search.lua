-- name = "Exchange rates"
-- description = "Shows currency rate by code"
-- data_source = "https://api.exchangerate.host"
-- type = "search"
-- author = "Evgeny Zobbin & Andrey Gavrilov"
-- version = "1.0"

-- modules
local json = require "json"
local md_color = require "md_colors"

-- constants
local host = "https://api.exchangerate.host"
local red = md_colors.red_500
local base_currency = system:get_currency()

-- variables
local req_currency = ""
local req_amount = 1
local result = 0

function on_search(inp)
    req_currency = ""
    req_amount = 1
	result = 0

	local a,c = inp:match("^(%d*)%s?(%a%a%a)$")
    if c == nil then return end

	req_currency = c:upper()

    if get_index(supported, req_currency) == 0 then
        return
    end

    if a ~= "" then
        req_amount = a
    end

	search:show({"Exchange rate for "..req_amount.." "..req_currency},{red})
end

function on_click()
    if result == 0 then
	    http:get(host.."/convert?from="..req_currency.."&to="..base_currency.."&amount="..req_amount)
	    return false
	else
	    system:copy_to_clipboard(result)
	    return true
	end
end

function on_long_click()
	system:copy_to_clipboard(result)
	return true
end

function on_network_result(res)
    local tab = json.decode(res)

    if tab.success then
        search:show({tab.query.amount.." "..tab.query.from.." = "..tab.result.." "..tab.query.to}, {red})
    else
	    search:show({"No data"},{red})
    end
end

-- curl -s -XGET 'https://api.exchangerate.host/symbols?format=csv' | cut -d ',' -f 2 | grep -v code | sed 's/$/,/' | tr '\n' ' '
supported = {
    "AED", "AFN", "ALL", "AMD", "ANG", "AOA", "ARS", "AUD", "AWG", "AZN", "BAM", "BBD", "BDT", "BGN", "BHD", "BIF", "BMD", "BND", "BOB", "BRL", "BSD", "BTC", "BTN", "BWP", "BYN", "BZD", "CAD", "CDF", "CHF", "CLF", "CLP", "CNH", "CNY", "COP", "CRC", "CUC", "CUP", "CVE", "CZK", "DJF", "DKK", "DOP", "DZD", "EGP", "ERN", "ETB", "EUR", "FJD", "FKP", "GBP", "GEL", "GGP", "GHS", "GIP", "GMD", "GNF", "GTQ", "GYD", "HKD", "HNL", "HRK", "HTG", "HUF", "IDR", "ILS", "IMP", "INR", "IQD", "IRR", "ISK", "JEP", "JMD", "JOD", "JPY", "KES", "KGS", "KHR", "KMF", "KPW", "KRW", "KWD", "KYD", "KZT", "LAK", "LBP", "LKR", "LRD", "LSL", "LYD", "MAD", "MDL", "MGA", "MKD", "MMK", "MNT", "MOP", "MRO", "MRU", "MUR", "MVR", "MWK", "MXN", "MYR", "MZN", "NAD", "NGN", "NIO", "NOK", "NPR", "NZD", "OMR", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN", "PYG", "QAR", "RON", "RSD", "RUB", "RWF", "SAR", "SBD", "SCR", "SDG", "SEK", "SGD", "SHP", "SLL", "SOS", "SRD", "SSP", "STD", "STN", "SVC", "SYP", "SZL", "THB", "TJS", "TMT", "TND", "TOP", "TRY", "TTD", "TWD", "TZS", "UAH", "UGX", "USD", "UYU", "UZS", "VEF", "VES", "VND", "VUV", "WST", "XAF", "XAG", "XAU", "XCD", "XDR", "XOF", "XPD", "XPF", "XPT", "YER", "ZAR", "ZMW", "ZWL",
}
