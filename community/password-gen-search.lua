-- name = "Password generator"
-- description = "30-character password generator"
-- type = "search"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"

local pass = ""

function on_search(str)
    if str:lower():find(string.lower("password")) then
        pass = gen_pass()
        search:show_buttons{pass}
    end
end

function gen_pass()
    local chars = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V','W', 'X', 'Y', 'Z', 'a','b','c','d', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '!', '"','#','$','%','&',"'",'(',')','*','+',',','-','.','/','1','2','3','4','5','6','7','8','9','0',':',';','<','=','>','?','@','[',']','^','_','`','{','}'}

    math.randomseed(os.clock()*100000000000)

    pass = ""
    for i=1, 30, 1 do
        pass = pass..chars[math.random(1, #chars)]
    end

    return pass
end

function on_click()
    system:to_clipboard(pass)
end
