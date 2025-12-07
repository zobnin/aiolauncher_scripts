-- name = "QR Code"
-- description = "Turn any text or url into QR code"
-- data_source = "https://api.qrserver.com/v1/"
-- type = "search"
-- author = "Sriram SV"
-- version = "1.0"
-- prefix = "qr"

qr_code_url = "https://api.qrserver.com/v1"
text_from = ""
text_to = ""

local md_color = require "md_colors"

-- constants
local blue = md_colors.blue_500


function on_search(input)
    text_to = ""
    text_from = input
    search:show_buttons({input},{blue})
end

function on_click()
    if text_to == "" then
        get_qr_code(text_from)
    end
end

function get_qr_code(text)
    url = qr_code_url.."/create-qr-code/?size=150x150&data="..text
    system:open_browser(url)
end
