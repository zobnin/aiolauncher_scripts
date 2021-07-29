function onResume()
    local location = system:getLocation()
    ui:showText(location[1].." "..location[2])
end
