-- type = "search"

settings_init = false

function on_search()
    if not settings_init then
        search:show_buttons{ "Set settings" }
    else
        search:show_buttons{ "Result #1", "Result #2" }
    end
end

function on_click(idx)
    if not settings_init then
        settings:show_dialog()
    else
        -- main work
    end
end
