-- name = "Включение виджетов"
-- description = "Включает и отключает виджеты на экране при нажатии на кнопки"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"
-- arguments_help = "Введите список виджетов и кнопок в формате bitcoin:Биткойн timer:Таймер"
-- arguments_default = "bitcoin:Битк. timer:Тайм. stopwatch:Секунд. recorder:Дикт. calculator:Кальк."

sx = require 'pl.stringx'

function on_resume()
    local args = get_args_kv()
    
    widgets = args[1]
    buttons = args[2]
    colors = {}

    for idx,widget in ipairs(widgets) do
        if aio:is_widget_added(widget) then
            colors[idx] = "#f44336"
        else
            colors[idx] = "#388e3c"
        end
    end

    ui:show_buttons(buttons, colors)
end

function on_click(idx)
    local widget = widgets[idx]
    
    if aio:is_widget_added(widget) then
        aio:remove_widget(widget)
        colors[idx] = "#388e3c"
    else
        aio:add_widget(widget)
        colors[idx] = "#f44336"
    end

    ui:show_buttons(buttons, colors)
end

function get_args_kv()
    local keys = {}
    local values = {}
    local args = aio:get_args()
    
    for idx = 1, #args, 1 do
        local arg = sx.split(args[idx], ":")
        keys[idx] = arg[1]
        values[idx] = arg[2]
    end

    return { keys, values }
end
