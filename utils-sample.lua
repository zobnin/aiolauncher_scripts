function on_resume()
    local str = "one two three"
    local tab = str:split(" ")
    ui:show_text(tab[2])
end
