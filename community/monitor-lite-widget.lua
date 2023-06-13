-- name = "Monitor"
-- description = "One line monitor widget"
-- type = "widget"
-- foldable = "false"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"

local fmt = require "fmt"
local good_color = aio:colors().progress_good
local bad_color = aio:colors().progress_bad

function on_tick(n)
    -- Update every ten seconds
    if n % 10 == 0 then
        update()
    end
end

function update()
    local batt_percent = system:battery_info().percent
    local is_charging = system:battery_info().charging
    local mem_total = system:system_info().mem_total
    local mem_available = system:system_info().mem_available
    local storage_total = system:system_info().storage_total
    local storage_available = system:system_info().storage_available

    if (is_charging) then
        batt_percent = fmt.colored(batt_percent.."%", good_color)
    elseif (batt_percent <= 15) then
        batt_percent = fmt.colored(batt_percent.."%", bad_color)
    else
        batt_percent = batt_percent.."%"
    end

    ui:show_text(
        "BATT: "..batt_percent..fmt.space(4)..
        "RAM: "..mem_available..fmt.space(4)..
        "NAND: "..storage_available
    )
end
