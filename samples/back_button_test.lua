local names = { "Test", "Blah", "Works?", "Or not?" }
local colors = { "#FF5733", "#33FF57", "#3357FF", "#FF33A1" }

function on_resume()
 ui:show_toast("Called!")
 shuffle(names)
 shuffle(colors)
 ui:show_buttons(names, colors)
end

function on_click(idx)
 apps:launch("org.telegram.messenger")
end

function shuffle(t)
 for i = #t, 2, -1 do
  local j = math.random(1, i)
  t[i], t[j] = t[j], t[i]
 end
end

