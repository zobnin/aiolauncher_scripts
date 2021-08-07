-- name = "Google Translate"
-- data_source = "https://translate.google.com"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"

local json = require "json"
local text_from = ""
local text_color = ui:get_secondary_text_color()

function on_alarm()
    ui:show_text("<font color=\""..text_color.."\">Tap to enter text</font>")
end

function on_click()
    ui:show_edit_dialog("Введите текст")
end

function on_dialog_action(text)
    if text == "" then
        on_alarm()
    else
    text_from = text
    translate(text)
    end
end

function translate(str)
    http:get("http://translate.googleapis.com/translate_a/single?client=gtx&sl=auto".."&tl="..system:get_lang().."&dt=t&q="..str)
end

function on_network_result(result)
    local t = json.decode(result)
    local text_to = t[1][1][1]
    ui:show_lines({text_from}, {text_to})
end
