sx = require 'pl.stringx'

function on_resume()
    local string = "String with spaces"
    local s_list = sx.split(string, " ")
    ui:show_text(s_list[3])
end
