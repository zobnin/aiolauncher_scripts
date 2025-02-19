-- name = "Interactive Counter"
-- type = "widget"

-- Global variable to store the current count.
local counter = 0

-- Function to update the display: shows two buttons with the counter embedded in the first button.
function update_display()
    ui:show_buttons({ "Increase (" .. counter .. ")", "Reset" })
end

function on_load()
    update_display()
end

-- Function to handle button clicks.
function on_click(index)
    if index == 1 then
        counter = counter + 1
    elseif index == 2 then
        counter = 0
    end
    update_display()
end

