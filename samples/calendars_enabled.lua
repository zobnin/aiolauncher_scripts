function on_resume()
    ui:show_text(table.concat(calendar:enabled_calendar_ids(), ", "))
end
