function on_resume()
    files:delete("abc.txt")
    files:write("abc.txt", "This is text")
    local string = files:read("abc.txt")
    ui:show_text(string)
end
