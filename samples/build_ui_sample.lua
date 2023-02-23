function on_resume()
    ui:build{
        "text <b>This is a sample</b>",
        "space 2",
        "text Battery level",
        "space",
        "battery",
        "space 2",
        "text Notes",
        "space",
        "notes 2",
        "space 2",
        "text Exchange rates",
        "exchange 10 usd amd",
        "space 2",
        "text Timezones",
        "worldclock new_york kiev bangkok",
    }
end
