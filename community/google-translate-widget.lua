-- name = "Google Translate"
-- data_source = "https://translate.google.com"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.3"

local json = require "json"
local uri = "http://translate.googleapis.com/translate_a/single?client=gtx&sl=auto"
local text_from = ""

function on_resume()
    ui:show_text("Tap to enter text")
end

function on_click()
    dialogs:show_edit_dialog("Enter text")
end

function on_dialog_action(text)
    if text == "" or text == -1 then
        on_resume()
    else
        text_from = text
        translate(text)
    end
end

function translate(str)
    http:get(uri.."&tl="..system:lang().."&dt=t&q="..str)
end

function on_network_result(result)
    local t = json.decode(result)
    local text_to = ""

    for i, v in ipairs(t[1]) do
        text_to = text_to..v[1]
    end

    local lang_from = t[3]
    ui:show_lines({text_from.." ("..lang_from..")"}, {text_to})
end

