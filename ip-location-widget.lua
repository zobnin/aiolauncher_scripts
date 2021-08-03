function on_alarm()
    request_ip()
end

function on_network_result(result, code, id)
    if id == "ip" then 
        local location = { 
            ajson:get_value(result, "object string:latitude"),
            ajson:get_value(result, "object string:longitude")
        }
        request_addr(location)
    elseif id == "adr" then
        local adr = ajson:get_value(result, "object string:display_name")
        ui:show_text(adr)
    end
end

function request_ip()
    http:get("https://freegeoip.app/json/", "ip") 
end

function request_addr(location)
    http:get("https://nominatim.openstreetmap.org/reverse?format=json&lat="..location[1].."&lon=".. location[2].."&addressdetails=1", "adr")
end

