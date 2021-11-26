function on_resume()
    files:delete("abc.txt")
    files:write_text("abc.txt", "This is text")
    local string = files:read_text("abc.txt")
    ui:show_text(string)
end
