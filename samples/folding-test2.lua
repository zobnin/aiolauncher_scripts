-- on_resume_when_folding = "true"

local counter = 0

function on_resume()
    counter = counter+1
    ui:show_text("refresh times: "..counter)
    ui:show_toast("on_resume called")
end
