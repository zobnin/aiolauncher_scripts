math = require "math"
use(math)

function pprint(obj)
    if type(obj) == "string" or type(obj) == "number" or type(obj) == "boolean" then
        print(obj)
    else
        print("")
    end
end