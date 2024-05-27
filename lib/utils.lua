-- Standard AIO Launcher library

function string:trim()
    if #self == 0 then return self end

    return self:match("^%s*(.-)%s*$")
end

function string:starts_with(start_str)
    if #self == 0 or #self < #start_str then return false end
    if start_str == nil or start_str == "" then return true end

    return self:sub(1, #start_str) == start_str
end

function string:ends_with(end_str)
    if #self == 0 or #self < #end_str then return false end
    if end_str == nil or end_str == "" then return true end

    return self:sub(-#end_str) == end_str
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

function index(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end

    return 0
end

function key(tab, val)
    for index, value in pairs(tab) do
        if value == val then
            return index
        end
    end

    return 0
end

function concat(t1, t2)
    for _,v in ipairs(t2) do
        table.insert(t1, v)
    end
end

function contains(table, val)
    for i=1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

function reverse(tab)
    for i = 1, math.floor(#tab/2) do
        tab[i], tab[#tab-i+1] = tab[#tab-i+1], tab[i]
    end
    return tab
end

function serialize(tab, ind)
    ind = ind and (ind .. "  ") or "  "
    local nl = "\n"
    local str = "{" .. nl
    for k, v in pairs(tab) do
        local pr = (type(k)=="string") and ("[\"" .. k .. "\"] = ") or ""
        str = str .. ind .. pr
        if type(v) == "table" then
            str = str .. serialize(v, ind) .. ",\n"
        elseif type(v) == "string" then
            str = str .. "\"" .. tostring(v) .. "\",\n"
        elseif type(v) == "number" or type(v) == "boolean" then
            str = str .. tostring(v) .. ",\n"
        else
            str = str .. "[[" .. tostring(v) .. "]],\n"
        end
    end
    str = str:gsub(".$","")
    str = str .. nl .. ind .. "}"
    return str
end

function deep_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deep_copy(orig_key)] = deep_copy(orig_value)
        end
        setmetatable(copy, deep_copy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
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
            print("use: skipping duplicate symbol ", k, "\n")
        else
            _G[k] = module[k]
        end
    end
end

function for_each(tbl, callback)
    for index, value in ipairs(tbl) do
        callback(value, index, tbl)
    end
end

-- Deprecated
function get_index(tab, val)
    return index(tab, val)
end

-- Deprecated
function get_key(tab, val)
    return key(tab, val)
end

-- Deprecated
function concat_tables(t1, t2)
    concat(t1, t2)
end

-- Functional Library
--
-- @file    functional.lua
-- @author  Shimomura Ikkei
-- @date    2005/05/18
--
-- @brief    porting several convenience functional utilities form Haskell,Python etc..

-- map(function, table)
-- e.g: map(double, {1,2,3})    -> {2,4,6}
function map(func, tbl)
    local newtbl = {}
    for i,v in pairs(tbl) do
        newtbl[i] = func(v)
    end
    return newtbl
end

-- filter(function, table)
-- e.g: filter(is_even, {1,2,3,4}) -> {2,4}
function filter(func, tbl)
    local newtbl= {}
    for i,v in pairs(tbl) do
        if func(v) then
            newtbl[i]=v
        end
    end
    return newtbl
end

-- skip(table, N)
-- e.g: skip({1,2,3,4}, 2) -> {3,4}
function skip(tbl, N)
    local result = {}
    for i = N+1, #tbl do
        table.insert(result, tbl[i])
    end
    return result
end

-- take(table, N)
-- e.g: take({1,2,3,4}, 2) -> {1,2}
function take(tbl, N)
    local result = {}
    for i = 1, N do
        if tbl[i] == nil then
            break
        end
        table.insert(result, tbl[i])
    end
    return result
end

-- head(table)
-- e.g: head({1,2,3}) -> 1
function head(tbl)
    return tbl[1]
end

-- tail(table)
-- e.g: tail({1,2,3}) -> {2,3}
--
-- XXX This is a BAD and ugly implementation.
-- should return the address to next porinter, like in C (arr+1)
function tail(tbl)
    if #tbl < 1 then
        return nil
    else
        local newtbl = {}
        local i = 2
        while (i <= #tbl) do
            table.insert(newtbl, i-1, tbl[i])
            i = i + 1
        end
        return newtbl
    end
end

-- foldr(function, default_value, table)
-- e.g: foldr(operator.mul, 1, {1,2,3,4,5}) -> 120
function foldr(func, val, tbl)
    for i,v in pairs(tbl) do
        val = func(val, v)
    end
    return val
end

-- reduce(function, table)
-- e.g: reduce(operator.add, {1,2,3,4}) -> 10
function reduce(func, tbl)
    return foldr(func, head(tbl), tail(tbl))
end

-- curry(f,g)
-- e.g: printf = curry(io.write, string.format)
--          -> function(...) return io.write(string.format(unpack(arg))) end
function curry(f, g)
    return function (...)
        return f(g(table.unpack({...})))
    end
end

-- bind1(func, binding_value_for_1st)
-- bind2(func, binding_value_for_2nd)
-- @brief
--      Binding argument(s) and generate new function.
-- @see also STL's functional, Boost's Lambda, Combine, Bind.
-- @examples
--      local mul5 = bind1(operator.mul, 5) -- mul5(10) is 5 * 10
--      local sub2 = bind2(operator.sub, 2) -- sub2(5) is 5 -2
function bind1(func, val1)
    return function (val2)
        return func(val1, val2)
    end
end
function bind2(func, val2) -- bind second argument.
    return function (val1)
        return func(val1, val2)
    end
end

-- is(checker_function, expected_value)
-- @brief
--      check function generator. return the function to return boolean,
--      if the condition was expected then true, else false.
-- @example
--      local is_table = is(type, "table")
--      local is_even = is(bind2(math.mod, 2), 1)
--      local is_odd = is(bind2(math.mod, 2), 0)
is = function(check, expected)
    return function (...)
        if (check(table.unpack({...})) == expected) then
            return true
        else
            return false
        end
    end
end

-- operator table.
-- @see also python's operator module.
operator = {
    mod = math.mod;
    pow = math.pow;
    add = function(n,m) return n + m end;
    sub = function(n,m) return n - m end;
    mul = function(n,m) return n * m end;
    div = function(n,m) return n / m end;
    gt  = function(n,m) return n > m end;
    lt  = function(n,m) return n < m end;
    eq  = function(n,m) return n == m end;
    le  = function(n,m) return n <= m end;
    ge  = function(n,m) return n >= m end;
    ne  = function(n,m) return n ~= m end;

}

-- enumFromTo(from, to)
-- e.g: enumFromTo(1, 10) -> {1,2,3,4,5,6,7,8,9}
-- TODO How to lazy evaluate in Lua? (thinking with coroutine)
enumFromTo = function (from,to)
    local newtbl = {}
    local step = bind2(operator[(from < to) and "add" or "sub"], 1)
    local val = from
    while val <= to do
        table.insert(newtbl, table.getn(newtbl)+1, val)
        val = step(val)
    end
    return newtbl
end

-- make function to take variant arguments, replace of a table.
-- this does not mean expand the arguments of function took,
-- it expand the function's spec: function(tbl) -> function(...)
function expand_args(func)
    return function(...) return func(arg) end
end
