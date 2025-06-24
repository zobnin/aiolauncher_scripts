-- name = "Thirukkural"
-- description = "Thirukkural Widget that refreshes  a verse form the Tamil Book Thirukkural. Single click will open the diaglog with multiple translations in English and Tamili. Long press will retrive a new verse. This uses the API from getthirukural"
-- data_source = "https://getthirukural.appspot.com/"
-- type = "widget"
-- author = "Abdul MJ (mjabdulm@gmail.com)"
-- version = "1.0"
-- foldable = "false"

local json = require "json"
local kural_data = nil  -- Store the kural translation data

function on_alarm()
    -- Fetch random kural with English translation
    -- http:get("https://api.alquran.cloud/v1/ayah/random/en.sahih")
    http:get("https://getthirukural.appspot.com/api/3.0/kural/rnd?appid=bzh3rnqagllov")
end

function on_network_result(result)
        local response = json.decode(result)

        if response then
            -- Store kural data including athigaram name, kural number
            kural_data = {
                number = response.number,
                line1 = response.line1,
                line2 = response.line2,
                paal = response.paal,
                athigaram = response.athigaram,
                iyal = response.iyal,
				urai1Author = response.urai1Author,
				urai2Author = response.urai2Author,
				urai3Author = response.urai3Author,
				urai1       = response.urai1,
				urai2       = response.urai2,
				urai3       = response.urai3,
				en = response.en
            }

            display_kural()
        else
            ui:show_message("Error loading kural data.")
        end
end

function display_kural()
    if kural_data then
        local display_lines = {
            -- kural_data.number .. " : " .. kural_data.line1 .. "<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" .. kural_data.line2
            -- kural_data.line1 .. "<br/>" .. kural_data.line2 .. "&nbsp;-&nbsp;<font color=red style=font-size:0.5em;>" .. kural_data.number .. ":"..  kural_data.athigaram .. ":" .. kural_data.paal .. "</font>"
            kural_data.line1 .. "<br/>" .. kural_data.line2 .. "&nbsp;-<i><font color=red>" .. kural_data.number .. "</i></font>"
            -- kural_data.line1 .. "<br/>" .. kural_data.line2 .. [[-&nbsp;<font color=grey style="font-size: 0.5em;">]] .. kural_data.number .. ":" ..  kural_data.athigaram .. "</font>"
        }

        -- ui:show_lines(display_lines display_titles)
        ui:show_lines(display_lines)
    end
end

function on_click()
    if kural_data then
        -- Prepare text to copy to clipboard with English translation only
        local title = "Thirukkural:" .. kural_data.number

        local text = kural_data.number .. ":" .. kural_data.paal .. ":" .. kural_data.iyal .. ":" .. kural_data.athigaram .. "<br/><br/><b>Kural<br/></b>" .. kural_data.line1 .. "<br/>" .. kural_data.line2 .. "<br/><br/><b>English:</b><br/>" .. kural_data.en .. "<br\><br\><b>" .. kural_data.urai1Author .. "</b><br/>" .. kural_data.urai1 .. "<br\><br\><b>" .. kural_data.urai2Author .. "</b><br/>" .. kural_data.urai2 .. "<br\><br\><b>" .. kural_data.urai3Author .. "</b><br/>" .. kural_data.urai3

        -- system:to_clipboard(clipboard_text)
		dialogs:show_dialog(title,text)
		display_kural()
        -- ui:show_lines(clipboard_text)
    else
        ui:show_message("No kural available to copy.")
    end
end

function on_long_click()
    -- Fetch random kural on long-click
    http:get("https://getthirukural.appspot.com/api/3.0/kural/rnd?appid=bzh3rnqagllov")
end


