events = {}

function on_resume()
    local ev_titles = {}

    events = slice(calendar:get_events(), 1, 10)

    for k,v in ipairs(events) do
        ev_titles[k] = v.title
    end

    ui:show_lines(ev_titles)
end

function on_click(idx)
    calendar:open_event_dialog(events[idx].id)
end
