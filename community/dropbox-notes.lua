-- name = "Network file"

function on_resume()
    local args = aio:get_args()

    if next(args) == nil then
        ui:show_text("Tap to enter text file URL")
    else
        http:get(args[1])
    end
end

function on_click()
    aio:show_args_dialog()
end

function on_network_result(result)
    ui:show_text(result)
end
