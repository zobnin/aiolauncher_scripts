function on_alarm()
    local location = system:location()
    http:get("https://nominatim.openstreetmap.org/reverse?format=json&lat=".. location[1].."&lon=".. location[2].."&addressdetails=1")
end

function on_network_result(result)
    local adr = ajson:read(result, "object string:display_name")
    ui:show_text(adr)
end
