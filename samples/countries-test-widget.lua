-- name = "Countries module test"
-- description = "Quick checks for the countries module"
-- type = "widget"
-- author = "Codex"
-- version = "1.0"

local function add_status(lines, label, ok, detail)
    local status = ok and "OK" or "FAIL"
    local line = status .. " - " .. label
    if detail and detail ~= "" then
        line = line .. ": " .. detail
    end
    table.insert(lines, line)
end

local function country_label(country)
    if not country then
        return "nil"
    end
    local name = country.name or "?"
    local alpha2 = country.alpha2 or "?"
    local alpha3 = country.alpha3 or "?"
    return name .. " (" .. alpha2 .. "/" .. alpha3 .. ")"
end

local function render()
    local lines = {}
    table.insert(lines, "Countries module test")

    local total = countries:count()
    add_status(lines, "count", type(total) == "number" and total > 200, tostring(total))

    local regions = countries:regions()
    add_status(lines, "regions", type(regions) == "table" and #regions > 0, tostring(#regions))

    local us = countries:get("US")
    add_status(lines, "get(US)", us ~= nil, country_label(us))

    local usa = countries:get_by_alpha3("USA")
    add_status(lines, "get_by_alpha3(USA)", usa ~= nil, country_label(usa))

    local named = countries:get_by_name("United")
    add_status(lines, "get_by_name(United)", named ~= nil, country_label(named))

    local search = countries:search("united")
    add_status(lines, "search(united)", type(search) == "table" and #search > 0, tostring(#search))

    local dial = countries:by_dial_code("1")
    add_status(lines, "by_dial_code(1)", type(dial) == "table" and #dial > 0, tostring(#dial))

    if type(regions) == "table" and #regions > 0 then
        local by_region = countries:by_region(regions[1])
        add_status(lines, "by_region(" .. regions[1] .. ")", type(by_region) == "table" and #by_region > 0, tostring(#by_region))
    else
        add_status(lines, "by_region", false, "no regions")
    end

    ui:show_lines(lines)
end

function on_load()
    render()
end

function on_resume()
    render()
end
