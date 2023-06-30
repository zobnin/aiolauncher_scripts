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

function slice(tbl, s, e)
    local pos, new = 1, {}

    for i = s, e do
        new[pos] = tbl[i]
        pos = pos + 1
    end

    return new
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

function concat_tables(t1, t2)
    for _,v in ipairs(t2) do
        table.insert(t1, v)
    end
end

function serialize_table(tab, ind)
    ind = ind and (ind .. "   ") or "   "
    local nl = "\n"
    local str = "{" .. nl
    for k, v in pairs(tab) do
        local pr = (type(k)=="string") and ("[\"" .. k .. "\"] = ") or ""
        str = str .. ind .. pr
        if type(v) == "table" then
            str = str .. serialize(v, ind) .. ","
        elseif type(v) == "string" then
            str = str .. "\"" .. tostring(v) .. "\","
        elseif type(v) == "number" or type(v) == "boolean" then
            str = str .. tostring(v) .. ","
        else
            str = str .. "[[" .. tostring(v) .. "]],"
        end
    end
    str = str:gsub(".$","")
    str = str .. nl .. ind .. "}"
    return str
end

function round(x, n)
    local n = math.pow(10, n or 0)
    local x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function use(module, ...)
    for k,v in pairs(module) do
        if _G[k] then
            io.stderr:write("use: skipping duplicate symbol ", k, "\n")
        else
            _G[k] = module[k]
        end
    end
end


