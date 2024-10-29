-- name = "Electricity spot price"
-- description = "Day-ahead spot price of electricity"
-- data_source = "https://api.energy-charts.info/"
-- type = "widget"
-- foldable = "true"
-- author = "Hannu Hartikainen <hannu.hartikainen@gmail.com>"
-- version = "1.1"

json = require "json"
prefs = require "prefs"

url_base = "https://api.energy-charts.info/price?bzn=%s&end=%d"

price_data = nil
price_interval = nil
price_unit = nil
unit_multiplier = 1

next_fetch_ts = 0
next_redraw_ts = nil

-- parameters and default values
function on_load()
    -- bidding zone: see "Available bidding zones" in https://api.energy-charts.info/
    if not prefs.bidding_zone then
        prefs.bidding_zone = "FI"
    end

    -- VAT percentage
    if not prefs.vat_percentage then
        prefs.vat_percentage = 25.5
    end

    -- change threshold percentages for showing changes in folded format
    if not prefs.oneline_threshold_high then
        prefs.oneline_threshold_high = 1.3
    end
    if not prefs.oneline_threshold_low then
        prefs.oneline_threshold_low = 0.7
    end

    -- url to open when clicked
    if not prefs.click_url then
        prefs.click_url = "https://www.sahkonhintatanaan.fi/"
    end
end

function get_url()
    -- at most about 35 hours are known in advance; fetch all known prices
    local end_offset = 2*24*60*60
    local end_ts = os.time() + end_offset
    return string.format(url_base, prefs.bidding_zone, end_ts)
end

function on_alarm()
    if os.time() > next_fetch_ts then
        http:get(get_url())
    end
end

function on_network_result(result, code)
    if code >= 200 and code < 299 then
        parse_result(result)
        draw_widget(true)
    end
end

function on_tick(t)
    local ts = os.time()
    if next_redraw_ts and ts > next_redraw_ts then
        draw_widget(true)
    end
end

function on_click()
    if not ui:folding_flag() then
        system:open_browser(prefs.click_url)
    else
        draw_widget(false)
    end
end

function parse_result(result)
    price_data = json.decode(result)
    local price_count = #price_data.unix_seconds
    if price_count < 2 then
        return
    end

    price_interval = price_data.unix_seconds[2] - price_data.unix_seconds[1]
    if price_data.unit == "EUR/MWh" or price_data.unit == "EUR / megawatt_hour" then
        price_unit = "c/kWh"
        unit_multiplier = 0.1
    else
        price_unit = price_data.unit
        unit_multiplier = 1
    end

    -- assume next day is known 8 hours before it starts
    -- (eg. Nord Pool Spot typically publishes dayahead prices at 14 local time)
    local next_fetch_offset = 8*60*60
    local end_of_data_ts = price_data.unix_seconds[price_count] + price_interval
    next_fetch_ts = end_of_data_ts - next_fetch_offset
end

function get_current_idx()
    local t = os.time()
    for i = 1, #price_data.unix_seconds do
        local ts = price_data.unix_seconds[i]
        if ts < t and t < (ts+price_interval) then
            return i
        end
    end
end

function price(i)
    return price_data.price[i]
end

function get_display_price(idx)
    local mul = (1.0 + (prefs.vat_percentage / 100.0)) * unit_multiplier
    -- NOTE: float rounding in string.format doesn't work so do it here
    return math.floor(100.0 * price(idx) * mul + 0.5) / 100.0
end

function get_display_time(idx)
    return os.date("%H", price_data.unix_seconds[idx])
end

function format_price(idx)
    return string.format("%0.2f", get_display_price(idx))
end

function format_price_and_unit(idx)
    return string.format("%s %s", format_price(idx), price_unit)
end

function format_oneline(idx)
    local more_prices = ""
    local more_count = 0
    local cur_price = price(idx)
    for i = idx+1, #price_data.price do
        if price(i) > prefs.oneline_threshold_high * cur_price
            or price(i) < prefs.oneline_threshold_low * cur_price then
            more_count = more_count + 1
            more_prices = more_prices .. string.format("⋄ <i>%s′</i> <b>%s</b> ", get_display_time(i), get_display_price(i))
            cur_price = price(i)
            if more_count > 3 then
                break
            end
        end
    end
    return string.format("<b>%s</b> %s", format_price_and_unit(idx), more_prices)
end

-- NOTE: using timestamps would be better than indices, but the chart element
-- doesn't support times spanning multiple days properly
function make_chart_data(idx)
    local chart = {}
    for i = idx, #price_data.price do
        table.insert(chart, {
            i-1,
            get_display_price(i)
        })
    end
    return chart
end

function draw_widget(fold)
    ui:set_folding_flag(fold)
    local idx = get_current_idx()
    if not idx then
        ui:show_text("Error: no current price data")
        -- request fetch on next on_alarm and don't redraw before that
        next_fetch_ts = 0
        next_redraw_ts = nil
        return
    end

    next_redraw_ts = price_data.unix_seconds[idx+1]
    ui:set_title(string.format("Electricity spot price: %s", format_price_and_unit(idx)))
    ui:show_chart(make_chart_data(idx), "x: int, y: float", "", true, format_oneline(idx))
end

function on_settings()
    if (prefs.show_dialog) then
        prefs:show_dialog()
    end
end
