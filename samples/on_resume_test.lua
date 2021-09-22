local i = 0

function on_resume()
    i = i + 1
    ui:show_toast("on_resume called: "..i)
end
