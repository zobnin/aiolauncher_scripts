-- type = "drawer"

-- This script shows how to manage settings in the side menu script

local prefs = require("prefs")

function on_drawer_open()
    -- Init prefs table with default values
    if prefs.elem1 == nil then
        prefs.elem1 = "Element #1"
    end
    if prefs.elem2 == nil then
        prefs.elem2 = "Element #2"
    end
    if prefs.elem3 == nil then
        prefs.elem3 = "Element #3"
    end

    -- Show values from the prefs table
    drawer:show_list{
        prefs.elem1,
        prefs.elem2,
        prefs.elem3,
    }
end

function on_click()
    -- Show prefs edit dialog
    -- On the next open side menu it will show changed values
    prefs:show_dialog()
end
