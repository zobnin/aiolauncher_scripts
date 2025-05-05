function on_load()
    ui:show_lines{
        "Time zone: "..system:tz(),
        "Offset in seconds: "..system:tz_offset()
    }
end
