local co = coroutine.create(function()
    while true do
        ui:show_text("Hello world!")
        coroutine.yield()
    end
end)

function on_resume()
    ui:set_title(coroutine.status(co))
    coroutine.resume(co)
end
