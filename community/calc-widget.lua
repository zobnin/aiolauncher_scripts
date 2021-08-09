-- name = "Калькулятор"
-- description = "Работает с математическими, строковыми и логическими операторами и функциями"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"

local maths = {"abs", "acos", "asin", "atan", "ceil", "cos", "cos", "deg", "exp", "floor", "fmod", "frexp", "huge", "ldexp", "log", "max", "min", "modf", "pi", "pow", "rad", "random", "sin", "sqrt", "tan"}
local strings = {"byte", "char", "dump", "find", "format", "len", "lower", "match", "rep", "reverse", "sub", "upper"}
local types = {"nil", "function", "table", "userdata", "thread"}

function on_alarm()
    ui:show_text("Введите выражение")
end

function on_click()
    ui:show_edit_dialog("Введите выражение")
end

function on_dialog_action(text)
    if text == "" then
        on_alarm()
    else
        ui:show_text("Результат: "..calculate_string(text))
    end
end

function calculate_string(text)
    local str = format_str(text)
    local f = load("return "..str)
    local status, result = pcall(f)
    if get_index(types, type(result)) > 0 or not status then
        result = "неопределён"
    else
        result = tostring(result)
        system:copy_to_clipboard(result)
    end
    return result
end 
 
function format_str(text)
    text = text:gsub("pi", "math.pi")
    text = text:gsub("π", "math.pi")
    text = text:gsub("math%.math", "math")
    local pattern = "(√) ?(%d+%.?%d*)"
    local oper, first = text:match(pattern)
    if oper == "√" then
        return "math.sqrt("..first..")"
    end
    local pattern = "(%d+%.?%d*) ?([+-*/%^]) ?(%d+%.?%d*)"
    local first, oper, last = text:match(pattern)
    if oper == "^" then 
         return "math.pow("..first..", "..last..")"
    end
    func = text:match("^%a+")
    if get_index(maths, func) > 0 then
        return "math."..text
    end
    if get_index(strings, func) > 0 then
        return "string.".. text
    end
    return text
end
