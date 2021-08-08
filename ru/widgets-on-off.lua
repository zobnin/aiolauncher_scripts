-- name = "Включение виджетов"
-- description = "Включает и отключает виджеты на экране при нажатии на кнопки"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"
-- arguments_help = "Введите список виджетов и кнопок в формате bitcoin:Биткойн timer:Таймер"
-- arguments_default = "bitcoin:Битк. timer:Тайм. stopwatch:Секунд. recorder:Дикт. calculator:Кальк."

function on_resume()
    local args = get_args_kv()
    
    widgets = args[1]
    buttons = args[2]
    colors = {}

    for idx,widget in ipairs(widgets) do
        if aio:is_widget_added(widget) then
            colors[idx] = md_colors.red_500
        else
            colors[idx] = md_colors.green_500
        end
    end

    ui:show_buttons(buttons, colors)
end

function on_click(idx)
    local widget = widgets[idx]
    
    if aio:is_widget_added(widget) then
        aio:remove_widget(widget)
        colors[idx] = md_colors.green_500
    else
        aio:add_widget(widget)
        colors[idx] = md_colors.red_500
    end

    ui:show_buttons(buttons, colors)
end

function get_args_kv()
    local keys = {}
    local values = {}
    local args = aio:get_args()
    
    for idx = 1, #args, 1 do
        local arg = args[idx]:split(":")
        keys[idx] = arg[1]
        values[idx] = arg[2]
    end

    return { keys, values }
end
