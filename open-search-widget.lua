-- name = "Search"

function onResume()
    ui:showText("Open search")
end

function onClick()
    aio:doAction("search")
end
