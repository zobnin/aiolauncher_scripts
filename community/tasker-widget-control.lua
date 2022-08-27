-- name = "Tasker Widget Control"
-- description = "Add or Remove widgets from Tasker"
-- data_source = "internal"
-- type = "widget"
-- author = "Sriram SV"
-- version = "1.0"

-- command structure 
-- cmd:script:*:add=:=<widget_name>
-- cmd:script:*:remove=:=<widget_name>
-- adb shell am broadcast -a ru.execbit.aiolauncher.COMMAND --es cmd "script:tasker widget control:add=:=<widget_name>" --es password <password>
-- adb shell am broadcast -a ru.execbit.aiolauncher.COMMAND --es cmd "script:tasker widget control:remove=:=<widget_name>" --es password <password>
function on_command(cmd)
    data = cmd:split("=:=")
    command = data[1]
    widget_name = data[2]
    if command == "add" then
        aio:add_widget(widget_name)
    elseif command == "remove" then
        aio:remove_widget(widget_name)
    end
end

function on_alarm()
    ui:show_text("Use tasker tasks to add/remove widgets")
end