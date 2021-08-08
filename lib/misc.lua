function parseHexColor(text)
  local r = tonumber('0x' .. string.sub(text, -8, -7))
  local g = tonumber('0x' .. string.sub(text, -6, -5))
  local b = tonumber('0x' .. string.sub(text, -4, -3))
  local a = tonumber('0x' .. string.sub(text, -2))

  return r, g, b, a
end

