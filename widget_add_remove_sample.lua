function onResume()
    ui:showButtons({ "Add clock widget", "Remove clock widget" })
end

function onClick(idx)
    if idx == 1 then
        aio:addWidget("clock")
    else
        aio:removeWidget("clock")
    end
end
