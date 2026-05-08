-- name = "Trade Tracker"
-- description = "Portfolio PnL tracker using Yahoo Finance"
-- type = "widget"
-- version = "1.0.0"

PORTFOLIO_FILE = "trade_tracker_portfolio.txt"
DISPLAY_FILE   = "trade_tracker_display.txt"
MAX_TICKERS    = 10

STATE        = "idle"
SELECTED_IDX = nil
pending      = 0
ltps         = {}
dates        = {}
errors       = {}

-- helper functions

function trim(s)
    return s:match("^%s*(.-)%s*$")
end

function jnum(s, key)
    return s:match('"' .. key .. '"%s*:%s*(%-?[0-9.]+)')
end

-- format numbers
function fmt_pnl(val)
    local sign    = val > 0 and "+" or (val < 0 and "-" or "")
    local abs_val = math.abs(val)
    local formatted = string.format("%.2f", abs_val)
    local dot_pos = formatted:find("%.")
    local int_part = formatted:sub(1, dot_pos - 1)
    local dec_part = formatted:sub(dot_pos + 1)
    local result = ""
    local len = #int_part
    for i = 1, len do
        if i > 1 and (len - i + 1) % 3 == 0 then
            result = result .. ","
        end
        result = result .. int_part:sub(i, i)
    end
    return sign .. result .. "." .. dec_part
end

-- portfolio file

function load_portfolio()
    local data    = files:read(PORTFOLIO_FILE)
    local entries = {}
    if data and data ~= "" then
        for line in (data .. "\n"):gmatch("([^\n]*)\n") do
            line = trim(line)
            if line ~= "" then
                local sym, qty, buy = line:match("^([^,]+),([^,]+),([^,]+)$")
                if sym and qty and buy then
                    table.insert(entries, {
                        symbol = trim(sym):upper(),
                        qty    = tonumber(trim(qty)) or 0,
                        buy    = tonumber(trim(buy)) or 0,
                    })
                end
            end
        end
    end
    return entries
end

function save_portfolio(entries)
    local lines = {}
    for _, e in ipairs(entries) do
        table.insert(lines, string.format("%s,%.0f,%.2f", e.symbol, e.qty, e.buy))
    end
    files:write(PORTFOLIO_FILE, table.concat(lines, "\n"))
end

-- render

function render()
    local portfolio = load_portfolio()
    if #portfolio == 0 then
        ui:show_text("No positions yet. Long-press to add a ticker.")
        return
    end

    local total_invested = 0
    local total_current  = 0
    local has_ltp        = false
    local html           = ""
    local today          = os.date("%Y-%m-%d")

    for _, e in ipairs(portfolio) do
        local ltp  = ltps[e.symbol]
        local date = dates[e.symbol]

        if ltp then
            has_ltp = true
            local invested = math.floor(e.qty * e.buy * 100 + 0.5) / 100
            local current  = math.floor(e.qty * ltp * 100 + 0.5) / 100
            local pnl      = math.floor((current - invested) * 100 + 0.5) / 100
            local pct      = math.floor((pnl / invested) * 10000 + 0.5) / 100
            local arrow    = pnl > 0 and "▲" or (pnl < 0 and "▼" or "—")
            local color    = pnl > 0 and "#4CAF50" or (pnl < 0 and "#F44336" or "#AAAAAA")
            total_invested = total_invested + invested
            total_current  = total_current  + current

            local stale_str = ""
            if date and date ~= today then
                stale_str = " [prev close]"
            end

            local date_str = date and ("  [" .. date .. " : " .. string.format("%.2f", ltp) .. stale_str .. "]") or ""

            html = html .. string.format(
                "<b>%s</b>%s" ..
                "<font color='%s'>  %s %s (%.2f%%)</font><br/>",
                e.symbol, date_str,
                color, arrow, fmt_pnl(pnl), pct
            )
        elseif errors[e.symbol] then
            html = html .. string.format(
                "<b>%s</b><font color='#F44336'>%s</font><br/>",
                e.symbol, errors[e.symbol]
            )
        else
            html = html .. string.format(
                "<b>%s</b><font color='#AAAAAA'> tap to fetch</font><br/>",
                e.symbol
            )
        end
    end

    if has_ltp and total_invested > 0 then
        local total_pnl = math.floor((total_current - total_invested) * 100 + 0.5) / 100
        local total_pct = math.floor((total_pnl / total_invested) * 10000 + 0.5) / 100
        local arrow     = total_pnl > 0 and "▲" or (total_pnl < 0 and "▼" or "—")
        local color     = total_pnl > 0 and "#4CAF50" or (total_pnl < 0 and "#F44336" or "#AAAAAA")
        html = html .. string.format(
            "<b>TOTAL</b><font color='%s'>%s %s &nbsp;(%.2f%%)</font>",
            color, arrow, fmt_pnl(total_pnl), total_pct
        )
    end

    files:write(DISPLAY_FILE, html)
    ui:show_text(html)
end

-- lifecycle

function on_resume()
    local saved = files:read(DISPLAY_FILE)
    if saved and saved ~= "" then
        ui:show_text(saved)
    else
        local p = load_portfolio()
        if #p == 0 then
            ui:show_text("No positions yet.<br/>Long-press to add a ticker.")
        else
            ui:show_text("Tap to refresh prices")
        end
    end
end

-- click handler

function on_click(idx)
    if STATE == "deleting" then
        if pending > 0 then
            STATE = "idle"
            ui:show_text("Please wait for fetch to complete.")
            return
        end
        local portfolio = load_portfolio()
        if idx and portfolio[idx] then
            local removed = portfolio[idx].symbol
            table.remove(portfolio, idx)
            save_portfolio(portfolio)
            files:write(DISPLAY_FILE, "")
            ltps[removed]   = nil
            dates[removed]  = nil
            errors[removed] = nil
            STATE = "idle"
            render()
        end
        return
    end

    if STATE ~= "idle" then return end

    local portfolio = load_portfolio()
    if #portfolio == 0 then
        ui:show_text("No positions.<br/>Long-press to add a ticker.")
        return
    end

    ltps    = {}
    dates   = {}
    errors  = {}
    pending = #portfolio
    ui:show_text("Fetching " .. pending .. " price(s)...")

    for i, e in ipairs(portfolio) do
        http:get(
            "https://query1.finance.yahoo.com/v8/finance/chart/"
            .. e.symbol .. "?interval=1m&range=1d",
            "t" .. i
        )
    end
end

-- network callbacks

function handle_result(idx, body, code)
    local portfolio = load_portfolio()
    local e = portfolio[idx]
    if e then
        if code == 200 then
            local ltp = jnum(body, "regularMarketPrice")
            local ts  = jnum(body, "regularMarketTime")
            if ltp then
                ltps[e.symbol] = tonumber(ltp)
                if ts then
                    dates[e.symbol] = os.date("%Y-%m-%d", tonumber(ts))
                end
            else
                errors[e.symbol] = "no price returned"
            end
        else
            errors[e.symbol] = "HTTP " .. tostring(code)
        end
    end
    pending = math.max(0, pending - 1)
    if pending == 0 then render() end
end

function handle_error(idx, err)
    local portfolio = load_portfolio()
    local e = portfolio[idx]
    if e then errors[e.symbol] = "connection failed" end
    pending = math.max(0, pending - 1)
    if pending == 0 then render() end
end

function on_network_result_t1(b,c)  handle_result(1,b,c)  end
function on_network_result_t2(b,c)  handle_result(2,b,c)  end
function on_network_result_t3(b,c)  handle_result(3,b,c)  end
function on_network_result_t4(b,c)  handle_result(4,b,c)  end
function on_network_result_t5(b,c)  handle_result(5,b,c)  end
function on_network_result_t6(b,c)  handle_result(6,b,c)  end
function on_network_result_t7(b,c)  handle_result(7,b,c)  end
function on_network_result_t8(b,c)  handle_result(8,b,c)  end
function on_network_result_t9(b,c)  handle_result(9,b,c)  end
function on_network_result_t10(b,c) handle_result(10,b,c) end
function on_network_result_t11(b,c) handle_result(11,b,c) end
function on_network_result_t12(b,c) handle_result(12,b,c) end
function on_network_result_t13(b,c) handle_result(13,b,c) end
function on_network_result_t14(b,c) handle_result(14,b,c) end
function on_network_result_t15(b,c) handle_result(15,b,c) end
function on_network_result_t16(b,c) handle_result(16,b,c) end
function on_network_result_t17(b,c) handle_result(17,b,c) end
function on_network_result_t18(b,c) handle_result(18,b,c) end
function on_network_result_t19(b,c) handle_result(19,b,c) end
function on_network_result_t20(b,c) handle_result(20,b,c) end
function on_network_error_t1(e)  handle_error(1,e)  end
function on_network_error_t2(e)  handle_error(2,e)  end
function on_network_error_t3(e)  handle_error(3,e)  end
function on_network_error_t4(e)  handle_error(4,e)  end
function on_network_error_t5(e)  handle_error(5,e)  end
function on_network_error_t6(e)  handle_error(6,e)  end
function on_network_error_t7(e)  handle_error(7,e)  end
function on_network_error_t8(e)  handle_error(8,e)  end
function on_network_error_t9(e)  handle_error(9,e)  end
function on_network_error_t10(e) handle_error(10,e) end
function on_network_error_t11(e) handle_error(11,e) end
function on_network_error_t12(e) handle_error(12,e) end
function on_network_error_t13(e) handle_error(13,e) end
function on_network_error_t14(e) handle_error(14,e) end
function on_network_error_t15(e) handle_error(15,e) end
function on_network_error_t16(e) handle_error(16,e) end
function on_network_error_t17(e) handle_error(17,e) end
function on_network_error_t18(e) handle_error(18,e) end
function on_network_error_t19(e) handle_error(19,e) end
function on_network_error_t20(e) handle_error(20,e) end

-- display long press menu

function on_long_click()
    if pending > 0 then
        ui:show_text("Please wait for fetch to complete first.")
        return
    end
    STATE = "main_menu"
    dialogs:show_dialog("Trade Tracker", "What would you like to do?", "Add trade", "Delete trade")
end

-- dialog state machine

function on_dialog_action(result)
    if result == -1 then STATE = "idle"; SELECTED_IDX = nil; return end

    if STATE == "main_menu" then
        if result == 1 then
            STATE = "adding"
            dialogs:show_edit_dialog(
                "Add Ticker",
                "Format: SYMBOL,quantity,bought_at(AAPL,10,150.00)<br/>Find the correct symbol at finance.yahoo.com",
                ""
            )
        elseif result == 2 then
            local portfolio = load_portfolio()
            if #portfolio == 0 then
                STATE = "idle"
                ui:show_text("No tickers to delete.")
                return
            end
            local btns = {}
            for _, e in ipairs(portfolio) do
                table.insert(btns, string.format("%s   qty:%.0f   buy:%.2f", e.symbol, e.qty, e.buy))
            end
            STATE = "deleting"
            ui:show_buttons(btns)
        end

    elseif STATE == "adding" then
        STATE = "idle"
        local input = tostring(result)
        local sym, qty_s, buy_s = input:match("^%s*([^,]+)%s*,%s*([^,]+)%s*,%s*([^,]+)%s*$")

        if not sym then
            ui:show_text("Invalid data. Expected: SYMBOL,qty,price (AAPL,10,150.00)")
            return
        end

        sym = trim(sym):upper()
        local qty = tonumber(trim(qty_s))
        local buy = tonumber(trim(buy_s))

        if not qty or not buy then
            ui:show_text("Invalid quantity or price. Both must be numbers.")
            return
        end
        if qty <= 0 then
            ui:show_text("Quantity must be greater than zero.")
            return
        end
        if buy <= 0 then
            ui:show_text("Buy price must be greater than zero.")
            return
        end
        if not sym:find("%.") then
            ui:show_text("Invalid symbol. Find the correct symbol at finance.yahoo.com")
            return
        end

        local portfolio = load_portfolio()

        local existing = nil
        for _, e in ipairs(portfolio) do
            if e.symbol == sym then existing = e; break end
        end

        if not existing and #portfolio >= MAX_TICKERS then
            ui:show_text("Maximum " .. MAX_TICKERS .. " tickers allowed.<br/>Delete one before adding a new one.")
            return
        end

        if existing then
            -- weighted average
            local total_invested = (existing.qty * existing.buy) + (qty * buy)
            local total_qty      = existing.qty + qty
            existing.qty = total_qty
            existing.buy = total_invested / total_qty
        else
            table.insert(portfolio, { symbol = sym, qty = qty, buy = buy })
        end

        save_portfolio(portfolio)
        files:write(DISPLAY_FILE, "")
        render()
    end
end