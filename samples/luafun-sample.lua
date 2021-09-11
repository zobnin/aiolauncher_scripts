require 'fun'()

function on_resume()
    --ui:show_text(sum(filter(function(x) return x % 16 == 0 end, range(10000))))

    local tab = {}
    each(function(x) table.insert(tab, x) end, map(function(x) return 2 * x end, range(4)))
    ui:show_lines(tab)
end
