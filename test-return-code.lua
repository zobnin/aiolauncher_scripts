function on_resume()
    net:get_text("https://google.com")
end

function on_network_result(body, code)
    ui:show_text(code)
end
