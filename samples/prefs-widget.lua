prefs = require "prefs"

prefs._name = "preferencies"

function on_resume()
    prefs.new_key = "Hello"
    ui:show_lines{prefs.new_key}
end
