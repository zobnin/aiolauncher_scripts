-- Standard AIO Launcher library

function string:split(sep)
    if sep == nil then
        sep = "%s"
    end

    local t={}

    for str in string.gmatch(self, "([^"..sep.."]+)") do
        table.insert(t, str)
    end

    return t
end

function string:replace(from, to)
    return self:gsub(from, to)
end

function get_index(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end

    return 0
end

function get_key(tab, val)
    for index, value in pairs(tab) do
        if value == val then
            return index
        end
    end
    
    return 0
end

function round(x, n)
    local n = math.pow(10, n or 0)
    local x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end
