-- name = "System info"

ticks = -1

function on_tick()
  -- Update one time per 10 seconds
  ticks = ticks + 1
  if ticks % 10 ~= 0 then
    return
  end

  ticks = 0

  local info = system:get_system_info()
  local strings = stringify_table(info)

  ui:show_lines(strings)
end

function stringify_table(tab)
  local new_tab = {}

  for k,v in pairs(tab) do
    table.insert(new_tab, capitalize(k):replace("_", " ")..": "..tostring(v))
  end

  return new_tab
end

function capitalize(string)
  return string:gsub("^%l", string.upper)
end
