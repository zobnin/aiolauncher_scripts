local co = coroutine.create(function()
    ui:show_text("Hello world!")
end)

function on_resume()
    ui:set_title(coroutine.status(co))
    coroutine.resume(co)
end
