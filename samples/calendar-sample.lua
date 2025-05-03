events = {}

function on_resume()
    local ev_titles = {}

    events = slice(calendar:events(), 1, 10)

    for k,v in ipairs(events) do
        ev_titles[k] = v.title
    end

    ui:show_lines(ev_titles)
end

function on_click(idx)
    calendar:show_event_dialog(events[idx])
end
