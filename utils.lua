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
