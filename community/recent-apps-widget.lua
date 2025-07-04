-- name = "Recent Apps"
-- description = "Gets the apps in the recent apps (app overview) screen. Tap to open the app or long press to remove it.\nREQUIRES ROOT and Android 11 or higher."
-- type = "widget"
-- author = "Abi"
-- version = "3.3"
-- foldable = "false"

local entries = {}

function on_resume()
	system:su('dumpsys activity recents')
end

function on_shell_result(raw)
	local start = raw:find("Visible recent tasks")
	if not start then
		ui:show_text("No recent apps")
		return
	end
	local trimmed = raw:sub(start)

	local blocks = {}
	local pat = "%* RecentTaskInfo #%d+:"
	local pos = 1
	while true do
		local s,e = trimmed:find(pat, pos)
		if not s then break end
		local ns,_ = trimmed:find(pat, e+1)
		if ns then
			blocks[#blocks+1] = trimmed:sub(s, ns-1)
			pos = ns
		else
			blocks[#blocks+1] = trimmed:sub(s)
			break
		end
	end

	entries = {}
	for _, block in ipairs(blocks) do
		local id = block:match("id=(%d+)")
		local has = block:match("hasTask=(%a+)")
		local last = block:match("lastActiveTime=(%d+)")
		local full = block:match("cmp=([%w%.]+/[%w%._]+)")
		local pkg = full and full:match("^([^/]+)")

		if id and has and last and pkg then
			entries[#entries+1] = {
				id = tonumber(id),
				hasTask = (has == "true"),
				lastActiveTime = tonumber(last),
				packageName = pkg,
				appName = get_name_or_color(pkg, "name"),
				appColor = get_name_or_color(pkg, "color"),
		}
		end
	end

	if #entries == 0 then
		ui:show_toast("No recent apps parsed")
		return
	end

	do
		local names, colors = {}, {}
		for i, e in ipairs(entries) do
			names[i] = e.appName
			colors[i] = e.appColor
		end
		ui:show_buttons(names, colors)
	end
end

function on_click(idx)
	local pkg = entries[idx] and entries[idx].packageName
	if pkg then
		apps:launch(pkg)
	else
		ui:show_toast("No package at index "..tostring(idx))
	end
end

function on_long_click(idx)
	local e = entries[idx]
	if not e then
		ui:show_toast("No app at index "..tostring(idx))
		return
	end

	system:su("am stack remove " .. entries[idx].id)
	system:su('dumpsys activity recents')
end

function to_hex_rgb(argb)
	if argb < 0 then argb = 4294967296 + argb end
	local r = math.floor((argb / 65536) % 256)
	local g = math.floor((argb / 256) % 256)
	local b = math.floor(argb % 256)
	return string.format("#%02X%02X%02X", r, g, b)
end

function get_name_or_color(pkg, nameorcolor)
	local info = apps:app(pkg)
	if not info then
		if nameorcolor == "name" then
			return "???"
		elseif nameorcolor == "color" then
			return "#FFFFFF"
		else
			return nil
		end
	end

	if nameorcolor == "name" then
		return info.name or "???"
	elseif nameorcolor == "color" then
		return to_hex_rgb(info.color or 0xFFFFFF)
	else
		return nil
	end
end
