function on_resume()
    http:get("https://google.com")
end

function on_network_result(body, code)
    ui:show_text(code)
end
