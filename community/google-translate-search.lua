-- name = "Google Translate"
-- description = "A search script that shows the translation of what you type in the search window"
-- data_source = "translate.google.com"
-- type = "search"
-- author = "Evgeny Zobnin"
-- version = "1.0"

local json = require "json"
local md_color = require "md_colors"

-- constants
local blue = md_colors.blue_500
local red = md_colors.red_500
local uri = "http://translate.googleapis.com/translate_a/single?client=gtx&sl=auto"

-- vars
local text_from = ""
local text_to = ""

function on_search(input)
    text_from = input
    text_to = ""

    search:show_buttons({"Translate \""..input.."\""}, {blue}, true)
end

function on_click()
    if text_to == "" then
        search:show_buttons({"Translating..."}, {blue}, true)
        request_trans(text_from)
        return false
    else
        system:to_clipboard(text_to)
        return true
    end
end

function request_trans(str)
    http:get(uri.."&tl="..system:lang().."&dt=t&q="..str)
end

function on_network_result(result, code)
    if code >= 200 and code < 300 then
        decode_and_show(result)
    else
        search:show_buttons({"Server error"}, {red}, true)
    end
end

function decode_and_show(result)
    local t = json.decode(result)

    for i, v in ipairs(t[1]) do
        text_to = text_to..v[1]
    end

    --local lang_from = t[3]

    if text_to ~= "" then
        search:show_buttons({text_to}, {blue}, true)
    end
end

