function on_resume()
    ui:show_text("Click me")
end

function on_click()
    tasker:run_task("Test", {
        firstname = "John",
        lastname = "Doe",
    })
end
