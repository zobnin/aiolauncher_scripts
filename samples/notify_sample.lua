-- This is an example of a widget that,
-- when a notification is added or removed,
-- simply reads the current notifications and refreshes the screen.

function on_resume()
    refresh()
end

function on_notifications_updated()
    refresh()
end

function refresh()
    local titles = map(
        function(it) return it.title end,
        notify:list()
    )
    ui:show_lines(titles)
end
