-- name = "Chuck Norris translated"
-- description = "Jokes with translation"
-- data_source = "icndb.com"
-- type = "widget"
-- author = "Alexander Ivanitsa (griva99@gmail.com)"
-- version = "1.0"

local joke = ""
local txt = ""

function urlencode(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w _ %- . ~])", function (c) return string.format ("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

function urldecode(str)
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
    return str
end

function on_alarm()
    http:get("http://api.icndb.com/jokes/random")
end

function on_network_result(result)
    local first_letter = string.sub(result, 1, 1)
    local textColor = ui:get_colors().secondary_text

    joke = ajson:get_value(result, "object object:value string:joke")
    local id = ajson:get_value(result, "object object:value string:id")
    txt = "<font color=\""..textColor.."\">"..tostring(id)..":</font> "..joke
    ui:show_text(txt)
end

-- translate --
function on_click(idx)
    local lang = system:get_lang()
    local link_href="http://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl="..lang.."&dt=t&q="
    http:get(link_href..urlencode(joke), "translate")
end

function on_network_result_translate(result)
    local js = require "json"
    local tt= ""
    local elem = js.decode(result)[1]
    for k,v in pairs(elem) do
        if type(v[1]) == "string" then
            tt = tt..v[1]
        end
    end
    ui:show_lines({txt,"---",tt})
end
