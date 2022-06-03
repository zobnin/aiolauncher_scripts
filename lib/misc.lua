function parse_hex_color(text)
  local r = tonumber('0x' .. string.sub(text, -8, -7))
  local g = tonumber('0x' .. string.sub(text, -6, -5))
  local b = tonumber('0x' .. string.sub(text, -4, -3))
  local a = tonumber('0x' .. string.sub(text, -2))

  return r, g, b, a
end

function parse_iso8601_date(json_date)
    local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%+%-]?)(%d?%d?)%:?(%d?%d?)"
    local year, month, day, hour, minute,
        seconds, offsetsign, offsethour, offsetmin = json_date:match(pattern)
    local timestamp = os.time{year = year, month = month,
        day = day, hour = hour, min = minute, sec = seconds}
    local offset = 0
    if offsetsign ~= '' and offsetsign ~= 'Z' then
      offset = tonumber(offsethour) * 60 + tonumber(offsetmin)
      if xoffset == "-" then offset = offset * -1 end
    end

    return timestamp + offset * 60
end

