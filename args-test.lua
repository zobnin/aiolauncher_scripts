-- argumentsHelp = "The word recorded here will be displayed on the screen."

function onResume()
    local args = aio:getArgs()
    if args == nil then
        ui:showText("args is empty")
    else
        ui:showText("arg1: "..args[1])
    end
end
