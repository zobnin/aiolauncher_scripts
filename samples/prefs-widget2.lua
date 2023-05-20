prefs = require("prefs")

prefs._name = "zzz"

function on_resume()
    prefs[1] = "text Battery level"
    prefs[2] = "space"
    prefs[3] = "battery"
    ui:build(prefs)
end
