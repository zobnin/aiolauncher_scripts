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

function round(x, n)
    local n = math.pow(10, n or 0)
    local x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end
