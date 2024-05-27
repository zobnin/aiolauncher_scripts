local print_tab = {}

function print(str)
    table.insert(print_tab, str)
    ui:show_lines(print_tab)
end

function test_trim()
    assert(("  hello  "):trim() == "hello")
    assert(("no_spaces"):trim() == "no_spaces")
    assert((""):trim() == "")
    assert(("   "):trim() == "")
    print("test_trim passed")
end

function test_starts_with()
    assert(("hello"):starts_with("he") == true)
    assert(("hello"):starts_with("hello") == true)
    assert(("hello"):starts_with("hi") == false)
    assert((""):starts_with("he") == false)
    assert(("hello"):starts_with("") == true)
    print("test_starts_with passed")
end

function test_ends_with()
    assert(("hello"):ends_with("lo") == true)
    assert(("hello"):ends_with("hello") == true)
    assert(("hello"):ends_with("world") == false)
    assert((""):ends_with("lo") == false)
    assert(("hello"):ends_with("") == true)
    print("test_ends_with passed")
end

function test_split()
    local result = ("a,b,c"):split(",")
    assert(#result == 3 and result[1] == "a" and result[2] == "b" and result[3] == "c")
    result = ("a b c"):split(" ")
    assert(#result == 3 and result[1] == "a" and result[2] == "b" and result[3] == "c")
    result = ("a  b  c"):split("%s+")
    assert(#result == 3 and result[1] == "a" and result[2] == "b" and result[3] == "c")
    print("test_split passed")
end

function test_replace()
    assert(("hello world"):replace("world", "Lua") == "hello Lua")
    assert(("hello world world"):replace("world", "Lua") == "hello Lua Lua")
    assert((""):replace("world", "Lua") == "")
    print("test_replace passed")
end

function test_slice()
    local result = slice({1, 2, 3, 4, 5}, 2, 4)
    assert(#result == 3 and result[1] == 2 and result[2] == 3 and result[3] == 4)
    print("test_slice passed")
end

function test_index()
    assert(index({1, 2, 3}, 2) == 2)
    assert(index({1, 2, 3}, 4) == 0)
    print("test_index passed")
end

function test_key()
    assert(key({a = 1, b = 2, c = 3}, 2) == "b")
    assert(key({a = 1, b = 2, c = 3}, 4) == 0)
    print("test_key passed")
end

function test_concat()
    local t1 = {1, 2}
    local t2 = {3, 4}
    concat(t1, t2)
    assert(#t1 == 4 and t1[3] == 3 and t1[4] == 4)
    print("test_concat passed")
end

function test_contains()
    assert(contains({1, 2, 3}, 2) == true)
    assert(contains({1, 2, 3}, 4) == false)
    print("test_contains passed")
end

function test_reverse()
    local result = reverse({1, 2, 3})
    assert(#result == 3 and result[1] == 3 and result[2] == 2 and result[3] == 1)
    print("test_reverse passed")
end

function test_serialize()
    local result = serialize({a = 1, b = {c = 2}})
    assert(result:replace("\n", "") == '{  ["a"] = 1,  ["b"] = {    ["c"] = 2,    },  }')
    print("test_serialize passed")
end

function test_deep_copy()
    local original = {a = 1, b = {c = 2}}
    local copy = deep_copy(original)
    assert(copy.b.c == 2)
    copy.b.c = 3
    assert(original.b.c == 2)
    print("test_deep_copy passed")
end

function test_round()
    assert(round(1.2345, 2) == 1.23)
    assert(round(1.2345, 0) == 1)
    assert(round(-1.2345, 2) == -1.23)
    print("test_round passed")
end

function test_use()
    local module = {test_var = 42}
    use(module)
    assert(test_var == 42)
    print("test_use passed")
end

function test_for_each()
    local sum = 0
    for_each({1, 2, 3}, function(value) sum = sum + value end)
    assert(sum == 6)
    print("test_for_each passed")
end

function test_map()
    local result = map(function(x) return x * 2 end, {1, 2, 3})
    assert(#result == 3 and result[1] == 2 and result[2] == 4 and result[3] == 6)
    print("test_map passed")
end

function test_filter()
    local result = filter(function(x) return x % 2 == 0 end, {1, 2, 3, 4})
    debug:log(#result)
    assert(#result == 2 and result[2] == 2 and result[4] == 4)
    print("test_filter passed")
end

function test_skip()
    local result = skip({1, 2, 3, 4}, 2)
    assert(#result == 2 and result[1] == 3 and result[2] == 4)
    print("test_skip passed")
end

function test_take()
    local result = take({1, 2, 3, 4}, 2)
    assert(#result == 2 and result[1] == 1 and result[2] == 2)
    print("test_take passed")
end

function test_head()
    assert(head({1, 2, 3}) == 1)
    print("test_head passed")
end

function test_tail()
    local result = tail({1, 2, 3})
    assert(#result == 2 and result[1] == 2 and result[2] == 3)
    print("test_tail passed")
end

function test_foldr()
    local result = foldr(operator.mul, 1, {1, 2, 3, 4, 5})
    assert(result == 120)
    print("test_foldr passed")
end

function test_reduce()
    local result = reduce(operator.add, {1, 2, 3, 4})
    assert(result == 10)
    print("test_reduce passed")
end

function test_curry()
    local function add(x, y)
        return x + y
    end

    local function multiply(x, y)
        return x * y
    end

    local curried_add = curry(add, function(...) return ... end)
    local curried_multiply = curry(multiply, function(...) return ... end)

    assert(curried_add(3, 4) == 7)  -- 3 + 4 = 7
    assert(curried_add(10, 20) == 30)  -- 10 + 20 = 30

    assert(curried_multiply(3, 4) == 12)  -- 3 * 4 = 12
    assert(curried_multiply(10, 20) == 200)  -- 10 * 20 = 200

    print("test_curry passed")
end

function test_bind1()
    local mul5 = bind1(operator.mul, 5)
    assert(mul5(10) == 50)
    print("test_bind1 passed")
end

function test_bind2()
    local sub2 = bind2(operator.sub, 2)
    assert(sub2(5) == 3)
    print("test_bind2 passed")
end

function test_is()
    local is_table = is(type, "table")
    assert(is_table({}) == true)
    assert(is_table(42) == false)
    print("test_is passed")
end

function on_resume()
    test_trim()
    test_starts_with()
    test_ends_with()
    test_split()
    test_replace()
    test_slice()
    test_index()
    test_key()
    test_concat()
    test_contains()
    test_reverse()
    test_serialize()
    test_deep_copy()
    test_round()
    test_use()
    test_for_each()
    test_map()
    test_filter()
    test_skip()
    test_take()
    test_head()
    test_tail()
    test_foldr()
    test_reduce()
    test_bind1()
    test_bind2()
    test_curry()
    test_is()
end
