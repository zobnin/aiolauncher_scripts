-- name = "Rich GUI Media Sample"
-- description = "Two images, a chart, and buttons using the raw GUI API"
-- type = "widget"
-- version = "1.0"

local pictures = {
    {name = "Blue", uri = "https://dummyimage.com/160x200/334455/ffffff"},
    {name = "Brown", uri = "https://dummyimage.com/160x200/665544/ffffff"},
}
local series = {
    {name = "Sample A", points = {{1, 12}, {2, 18}, {3, 15}, {4, 21}}},
    {name = "Sample B", points = {{1, 24}, {2, 17}, {3, 22}, {4, 16}}},
}
local selected_series = 1
local clicks = {}
local long_clicks = {}
local render

render = function()
    clicks = {}
    long_clicks = {}
    if ui.builder_image == nil or ui.builder_chart == nil then
        ui:show_text("This sample requires a build with Rich UI images and charts.")
        return
    end

    local definition = {}
    local function add(element, click, long_click)
        table.insert(definition, element)
        -- Indices include spacers and new lines, so derive them from the full definition.
        clicks[#definition] = click
        long_clicks[#definition] = long_click
    end

    for index, picture in ipairs(pictures) do
        local current = picture
        if index > 1 then
            add({"spacer", 2})
        end
        add({"image", current.uri, {width = 80, height = 100, scale = "crop"}},
            function() system:open_browser(current.uri) end,
            function() ui:show_toast(current.name) end)
    end
    add({"new_line"})
    add({"text", pictures[1].name .. " / " .. pictures[2].name})
    add({"new_line"})
    local current_series = series[selected_series]
    add({"chart", current_series.points, {
        height = 150,
        format = "x:number y:number",
        title = current_series.name,
        show_grid = true,
        copyright = "Demo data",
    }}, function() ui:show_toast(current_series.name .. ": four demo points") end)
    add({"new_line"})
    add({"button", "Swap images"}, function()
        pictures[1], pictures[2] = pictures[2], pictures[1]
        render()
    end)
    add({"spacer", 2})
    add({"button", "Change chart"}, function()
        selected_series = selected_series == 1 and 2 or 1
        render()
    end)
    gui(definition).render()
end

function on_load()
    render()
end

function on_click(index)
    local callback = clicks[index]
    if callback then
        callback()
    end
end

function on_long_click(index)
    local callback = long_clicks[index]
    if callback then
        callback()
    end
end
