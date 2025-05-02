-- Dumps app info table

app_pkg = "com.android.calendar"

function on_load()
    local calendar_app = apps:app(app_pkg)
    ui:show_text("%%txt%%"..serialize(calendar_app))
end
