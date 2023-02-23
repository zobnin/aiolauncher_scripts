-- name = "Script #1"
-- type = "search"

local table = {}

function on_search(input)
    search:show_buttons({ input.." 1", input.." 2" })
end

function on_click(idx)
    system:vibrate(100)
end

function on_long_click(idx)
    system:vibrate(300)
end
