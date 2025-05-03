-- name = "Top Apps"
-- icon = "fa:star"
-- description = "Shows 10 most frequently used applications"
-- type = "widget"
-- foldable = "true"

-- Created in Cursor
-- Original prompt: "Read README and script examples and write a widget script that will display 10 most used applications."

function on_resume()
    -- Get list of applications sorted by launch count
    local apps = apps:apps("launch_count")
    
    -- Create table for display
    local lines = {}
    for i = 1, 10 do
        if apps[i] then
            -- Add number and application name
            table.insert(lines, i .. ". " .. apps[i].name)
        end
    end
    
    -- Display the list
    ui:show_lines(lines)
end

-- Handle application click
function on_click(index)
    local apps = apps:apps("launch_count")
    if apps[index] then
        apps:launch(apps[index].pkg)
    end
end 