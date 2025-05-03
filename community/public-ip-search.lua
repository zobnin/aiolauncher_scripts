-- name = "Public IP"
-- description = "Shows your public IP in the search bar"
-- data_source = "ipify.org"
-- type = "search"
-- author = "Sriram SV"
-- version = "1.0"

local md_color = require "md_colors"
local blue = md_colors.blue_500
local red = md_colors.red_500

local ip = ""
function on_search(input)
    if input:lower():find("^ip$") then
        get_ip()
    end
end

function on_click()
    system:to_clipboard(ip)
end

function get_ip()
    http:get("https://api.ipify.org")
end

function on_network_result(result,code)
    if code >= 200 and code < 300 then
        ip = result
        search:show_buttons({result},{blue})
    else
        search:show_buttons({"Server Error"},{red})
    end
end


