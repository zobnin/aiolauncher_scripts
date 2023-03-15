-- name = "Calendar"
-- description = "Calendar search script"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- type = "search"

local events = calendar:events()
local results = {}

function on_search(str)
    results = {}
    buttons = {}

    for _,event in pairs(events) do
        if event.title:lower():find(str:lower()) ~= nil then
            table.insert(results, event)
            table.insert(buttons, event.title)
        end
    end

    search:show(buttons)
end

function on_click(idx)
    calendar:open_event(results[idx].id)
end
