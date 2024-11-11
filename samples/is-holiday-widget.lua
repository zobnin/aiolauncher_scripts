function on_resume()
    local unix_time = 1735698800 // 01.01.2025
    local date_str = os.date("%d.%m.%Y", unix_time)
    ui:show_text(date_str.." is holiday: "..tostring(calendar:is_holiday(unix_time)))
end
