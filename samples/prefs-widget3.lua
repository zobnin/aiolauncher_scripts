--[[
This example shows how to use the prefs module
to display a settings dialog automatically generated on the screen.
]]

prefs = require("prefs")

function on_load()
    -- Initialize settings with default values
    prefs.text_field_1 = "Test"
    prefs.text_field_2 = "Test #2"
    prefs.numeric_field = 123
    prefs.boolean_field = false
    prefs._hidden_field = "Hidden"
end

function on_resume()
    ui:show_toast("On resume called")
    ui:show_text("Click to edit preferencies")
end

function on_click()
    --[[
    The `show_dialog()` method automatically creates a window of current settings from fields defined in prefs.
    The window will display all fields with a text key and a value of one of three types: string, number, or boolean.
    All other fields of different types will be omittedi.
    Fields whose names start with an underscore will also be omitted.
    Script will be reloaded on settings save.
    ]]
    prefs:show_dialog()
end
