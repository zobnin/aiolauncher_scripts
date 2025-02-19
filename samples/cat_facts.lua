-- name = "Cat Facts"
-- type = "widget"

-- on_alarm is called automatically, up to once every 30 minutes, to refresh the widget.
function on_alarm()
    ui:show_text("Loading a random cat fact...")
    http:get("https://catfact.ninja/fact")
end

function on_network_result(body, code)
    if code == 200 then
        local json = require "json"
        local data = json.decode(body)  -- The json module converts the JSON string into a Lua table.
        if data and data.fact then
            ui:show_text("Random Cat Fact:\n" .. data.fact)
        else
            ui:show_text("Failed to retrieve a cat fact.")
        end
    else
        ui:show_text("Error loading data. Code: " .. code)
    end
end

