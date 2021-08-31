-- name = "Battery info"

function on_resume()
  local batt_info = system:get_battery_info()
  local batt_strings = stringify_table(batt_info)
  ui:show_lines(batt_strings)
end

function stringify_table(tab)
  local new_tab = {}

  for k,v in pairs(tab) do
    table.insert(new_tab, k:capitalize()..": "..tostring(v))
  end

  return new_tab
end

function string:capitalize()
  return (self:gsub("^%l", string.upper))
end
