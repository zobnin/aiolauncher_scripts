json = require "json"

function on_resume()
    local t = json.decode('[1,2,3,{"x":10}]')
    ui:show_text(t[4].x)
end
