local fmt = require "fmt"

function on_resume()
    local widgets = aio:available_widgets()
    local tab = {}

    for k,v in pairs(widgets) do
        table.insert(tab, { fmt.bold(v.name), v.type })
    end

    ui:show_table(tab)
end

