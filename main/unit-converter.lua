-- name = "Unit Converter"
-- description = "Simple unit converter"
-- type = "widget"
-- author = "Andrey Gavrilov"
-- version = "1.0"
-- foldable = "false"

local dialog_id = ""
local unit = "length"
local unit_from = "kilometer_km"
local unit_to = "meter_m"
local amount = 1
local sum
local f = {}

function on_alarm()
    redraw()
end

function redraw()
	local color = aio:colors()
	if unit == "temperature" then
		sum = round(f[units[unit][unit_from]..units[unit][unit_to]](amount),3)
	else
		sum = round(amount*units[unit][unit_from]/units[unit][unit_to],3)
	end
	local u_from = unit_from:split("_")[2]:replace("%."," ")
	local u_to = unit_to:split("_")[2]:replace("%."," ")
	local tab = {{"&nbsp;"..divide_number(amount," "),u_from,"<font color=\""..color.secondary_text.."\">&lt;=&gt;</font>",divide_number(sum," "),u_to,"<font color=\""..color.secondary_text.."\">"..unit.."</font>"}}
	ui:show_table(tab,5)
end

function on_settings()
	return
end

function on_click(idx)
    if idx == 1 then
        dialog_id ="amount"
        dialogs:show_edit_dialog("Enter amount", "", amount)
    elseif idx == 2 then
        dialog_id = "unit_from"
		dialogs:show_radio_dialog("Select unit",get_radio_tab(unit),get_radio_idx(unit_from))
	elseif idx == 3 then
		local unit_tmp = unit_from
		unit_from = unit_to
		unit_to = unit_tmp
		redraw()
	elseif idx == 4 then
		system:copy_to_clipboard(sum)
    elseif idx == 5 then
        dialog_id = "unit_to"
        dialogs:show_radio_dialog("Select unit",get_radio_tab(unit),get_radio_idx(unit_to))
    elseif idx == 6 then
		dialog_id = "unit"
        dialogs:show_radio_dialog("Select converter",get_radio_tab(""),get_radio_idx(unit))
    end
end

function on_dialog_action(data)
    if data == -1 then
        return
    end
    if dialog_id == "unit_from" then
        unit_from = get_radio_val(data)
    elseif dialog_id == "unit_to" then
        unit_to = get_radio_val(data)
    elseif dialog_id == "amount" then
		data = data:gsub(",",".")
        if amount == tonumber(data) then
            return
        end
        amount = data
		if unit ~= "temperature" then
			amount = amount:gsub("-","")
			if amount == "" or amount == "0" then
				amount = 1
			end
		end
		amount = tonumber(amount)
		if not amount then
			return
		end
    elseif dialog_id == "unit" then
        local new_unit = get_radio_val(data)
        if unit == new_unit then
            return
        end
        unit = get_radio_val(data)
        unit_from = get_key(units[unit],1)
        unit_to = get_key(units[unit],2)
    end
    redraw()
end

function divide_number(n, str)
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1'..str):reverse())..right
end

function get_radio_tab(src)
	local tab = {}
	if src == "" then
		for k,v in pairs(units) do
			table.insert(tab,k)
		end
	else
		for k,v in pairs(units[src]) do
		    local item = k:split("_")[1]:replace("%."," ")
			table.insert(tab,item)
		end
	end
	table.sort(tab)
    return tab
end

function get_radio_idx(val)
	if val == unit then
		return get_index(units,val)
	else
		return get_index(units[unit],val)
	end
end

function get_index(tab,key)
    local t = {}
    for k,v in pairs(tab) do
        table.insert(t,k)
    end
    table.sort(t)
    for i,v in ipairs(t) do
        if v == key then
            return i
        end
    end
    return 0
end

function get_key(tab,idx)
    local t = {}
    for k,v in pairs(tab) do
        table.insert(t,k)
    end
    table.sort(t)
    for i,v in ipairs(t) do
        if i == idx then
            return v
        end
    end
    return ""
end

function get_radio_val(idx)
    if dialog_id == "unit" then
        return get_key(units,idx)
    else
        return get_key(units[unit],idx)
    end
end

function f.cf(x)
	return x*9/5+32
end

function f.fc(x)
	return (x-32)*5/9
end

function f.ck(x)
	return x+273.15
end

function f.kc(x)
	return x-273.15
end

function f.fk(x)
	return (x-32)*5/9+273.15
end

function f.kf(x)
	return (x-273.15)*9/5+32
end

units = {
    length = {
        kilometer_km = 1e3,
        meter_m = 1,
        decimeter_dm = 1e-1,
        centimeter_cm = 1e-2,
        millimeter_mm = 1e-3,
        ["micrometer_µm"] = 1e-6,
        nanometer_nm = 1e-9,
        mile_mi = 1609.344,
        yard_yd = 0.9144,
        foot_ft = 0.3048,
        inch_in = 0.0254,
        ["nautical.mile_nmi"] = 1852
    },
    weight = {
        ton_t = 1e3,
        kilogram_kg = 1,
        gram_g = 1e-3,
        milligram_mg = 1e-6,
        ["microgram_µg"] = 1e-9,
        ["gross.ton_gt"] = 1016.0469063338,
        ["short.ton_st"] = 907.1847489906,
        stone_stn = 6.350293358152,
        pound_lb = 0.4535923744953,
        ounce_oz = 0.028349523084478
    },
    volume = {
        ["cubic.meter_cbm"] = 1e3,
        liter_l = 1,
        milliliter_ml = 1e-3,
        ["american.gallon_us.gal"] = 3.78541,
        ["american.fluid.quart_us.fl.qt"] = 0.946353,
        ["american.fluid.pint_us.fl.pt"] = 0.473176,
        ["american.cup_us.cup"] = 0.24,
        ["amirican.fluid.ounce_us.fl.oz"] = 0.0295735,
        ["american.tablespoon_us.tbsp"] = 0.0147868,
        ["american.teaspoon_us.tsp"] = 0.00492892,
        ["imperial.gallon_gal"] = 4.54609,
        ["imperial.quart_qt"] = 1.13652,
        ["imperial.pint_pt"] = 0.568261,
        ["imperial.cup_cup"] = 0.284131,
        ["imperial.fluid.ounce_fl.oz"] = 0.0284131,
        ["british.tablespoon_tbsp"] = 0.0177582,
        ["british.teaspoon_tsp"] = 0.00591939,
        ["cubic.foot_cbft"] = 28.316846368677,
        ["cubic.inch_cbin"] = 0.016387064025439,
        ["cubic.yard_cbyd"] = 764.55486927411
    },
    pressure = {
        pascal_pa = 1,
        atmosphere_at = 101324.99966284,
        bar_bar = 1e5,
        ["torr.mm.Hg_mm.Hg"] = 133.3223684,
        ["pound-force.per.square.inch_psi"] = 6894.76
    },
    square = {
        ["square.meter_sqm"] = 1,
        ["square.kilometer_sqkm"] = 1e6,
        ["square.mile_sqmi"] = 2589988.1005586,
        ["square.yard_sqyd"] = 0.83612739236948,
        ["square.foot_sqft"] = 0.092903043596609,
        ["square.inch_sqin"] = 0.00064516000000257,
        hectare_ha = 1e4,
        acre_ac = 4046.8564464278,
        are_a = 100
    },
    temperature = {
        ["celsius_°C"] = "c",
        ["fahrenheit_°F"] = "f",
        kelvin_K = "k"
    },
    energy = {
        joule_J = 1,
        kilojoule_kJ = 1e3,
        calorie_cal = 4.1868,
        kilocalorie_kcal = 4186.8,
        ["watt-hour_Wh"] = 3600,
        ["kilowatt-hour_kWh"] = 3.6e6,
        electronvolt_eV = 1.6022e-19,
        ["british.thermal.unit_BTU"] = 1055.06,
        ["american.therm_us.thm"] = 1.05506e8,
        ["foot-pound_ft-lb"] = 1.35582
    },
    power = {
        watt_W = 1,
        kilowatt_kW = 1e3,
        ["metric.ton.cooling_RT"] = 3861.1599472766,
        ["metric.horsepower_hp"] = 735.49962489519
    },
    digital = {
        bit_b = 0.125,
        byte_B = 1,
        kilobyte_kB = 1e3,
        megabyte_MB = 1e6,
        gigabyte_GB = 1e9,
        terabyte_TB = 1e12,
        kibibyte_KiB = 2^10,
        mebibyte_MiB = 2^20,
        gibibyte_GiB = 2^30,
        tebibyte_TiB = 2^40
    },

    angle = {
        gon_g = 0.9,
        degree_deg = 1,
        radian_rad = 180/math.pi,
        minute_min = 1/60,
        second_sec = 1/3600
    },
    period = {
        second_sec = 1,
        minute_min = 60,
        hour_h = 3600,
        day_d = 86400,
        week_w = 604800,
        month_m = 30.4167*86400,
        year_y = 365*86400,
        decade_dec = 3650*86400,
        century_c = 36500*86400,
        millisecond_ms = 1e-3,
        microsecond_mcs = 1e-6,
        nanosecond_ns = 1e-9
    }
}
