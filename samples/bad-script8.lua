-- testing = "true"

function on_resume()
    for i = 1, 15 do
        system:to_clipboard("aaa")
        ui:show_text(i)
    end
end

