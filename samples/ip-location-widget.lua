ip_service_url = "https://freegeoip.app/json/"
addr_service_url = "https://nominatim.openstreetmap.org/reverse?format=json"

function on_alarm()
    http:get(ip_service_url, "ip") 
end

function on_network_result_ip(result)
    local location = { 
        ajson:read(result, "object string:latitude"),
        ajson:read(result, "object string:longitude")
    }
    http:get(addr_service_url.."&lat="..location[1].."&lon=".. location[2].."&addressdetails=1", "addr")
end

function on_network_result_addr(result)
    local adr = ajson:read(result, "object string:display_name")
    ui:show_text(adr)
end

