stringx = require 'pl.stringx'

function onResume()
    local string = "String with spaces"
    local sList = stringx.split(string, " ")
    ui:showText(sList[3])
end
