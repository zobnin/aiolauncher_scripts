local mod = require "./module"

function on_resume()
    ui:show_text(mod.hello_world())
end
