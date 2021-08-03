-- arguments_help = "The word recorded here will be displayed on the screen."
-- arguments_default = "Word"

function on_resume()
    aio:set_args({"Word#1", "Word#2"})
    local args = aio:get_args()

    if args == nil then
        ui:show_text("args is empty")
    else
        ui:show_text("arg1: "..args[1])
    end
end
