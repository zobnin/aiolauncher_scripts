-- name = "AΙΟ widgets list"
-- type = "widget"
-- description = "Shows widgets returned by aio:available_widgets() function"
--foldable = "true"
-- author = "Theodor Galanis"
-- version = "1"

function on_resume()
    actions = aio:available_widgets()
    local labels = ""
    
      labels = map(actions, function(it) return it.label end)
      names = map(actions, function(it) return it.name end)
    ui:show_lines(names, labels)
   end
   
   function map(tbl, f)
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = f(v)
    end
    return ret
    end