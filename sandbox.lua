function sandbox(func)
    local co = coroutine.create(func)
    local hook = function() coroutine.yield('resource used too many cycles') end

    debug.setupvalue(func, 1, _G)
    debug.sethook(co, hook, "", 100)

    coroutine.resume(co)
end

