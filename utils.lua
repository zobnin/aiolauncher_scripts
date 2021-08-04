function get_args_kv()
    local keys = {}
    local values = {}
    local args = aio:get_args()
    
    for idx = 1, #args, 1 do
        local arg = sx.split(args[idx], ":")
        keys[idx] = arg[1]
        values[idx] = arg[2]
    end

    return { keys, values }
end

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

function round(x, n)
    local n = math.pow(10, n or 0)
    local x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function table:get_index(val)
    for index, value in ipairs(self) do
        if value == val then
            return index
        end
    end

    return -1
end
