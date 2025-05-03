local fmt = require "fmt"

function on_resume()
    local widgets = aio:active_widgets()
    local tab = {}

    for k,v in pairs(widgets) do
        table.insert(tab, { fmt.bold(v.name), "(un)fold", "remove" })
    end

    ui:show_table(tab)
end

function on_click(idx)
    local widget_num = math.ceil(idx / 3)
    local action = idx % 3

    if action == 0 then
        aio:remove_widget(widget_num)
    elseif action == 2 then
        aio:fold_widget(widget_num)
    end
end

function on_widget_action(action, name)
    ui:show_toast(name.." "..action)
    on_resume()
end
