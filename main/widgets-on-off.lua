-- name = "Widgets switcher"
-- description = "Turns screen widgets on and off when buttons are pressed"
-- type = "widget"
-- arguments_help = "Don't change the arguments directly, use the long click menu."
-- author = "Andrey Gavrilov"
-- version = "2.0"

--constants--

local widgets = {"weather","weatheronly","clock","alarm","worldclock","monitor","traffic","player","apps","appbox","applist","contacts","notify","dialogs","dialer","timer","stopwatch","mail","notes","tasks", "health", "feed","telegram","twitter","calendar","exchange","finance","bitcoin","control","recorder","calculator","empty","bluetooth","map","remote"}

local icons = {"fa:user-clock","fa:sun-cloud","fa:clock","fa:alarm-clock","fa:business-time","fa:network-wired","fa:exchange","fa:play-circle","fa:robot","fa:th","fa:list","fa:address-card","fa:bell","fa:comment-alt-minus","fa:phone-alt","fa:chess-clock","fa:stopwatch","fa:at","fa:sticky-note","fa:calendar-check", "fa:heart-pulse", "fa:rss-square","fa:paper-plane","fa:dove","fa:calendar-alt","fa:euro-sign","fa:chart-line","fa:coins","fa:wifi","fa:microphone-alt","fa:calculator-alt","fa:eraser","fa:head-side-headphones","fa:map-marked-alt","fa:user-tag"}

local names = {"Clock & weather","Weather","Clock","Alarm","Worldclock","Monitor","Traffic","Player","Frequent apps","My apps","App list","Contacts","Notify","Dialogs","Dialer","Timer","Stopwatch","Mail","Notes","Tasks", "Health", "Feed","Telegram","Twitter","Calendar","Exchange","Finance","Bitcoin","Control panel","Recorder","Calculator","Empty widget","Bluetooth","Map","User widget"}

--variables--

local pos = 0

function on_resume()
  if next(settings:get()) == nil then
    set_default_args()
  end
  ui:set_folding_flag(true)
  local buttons,colors = get_buttons()
  ui:show_buttons(buttons, colors)
end

function on_click(idx)
  pos = idx
  redraw()
end

function on_long_click(idx)
  pos = idx
  local tab = settings:get()
  ui:show_context_menu({{"angle-left",""},{"ban",""},{"angle-right",""},{icons[get_checkbox_idx()[idx]]:gsub("fa:",""),names[get_checkbox_idx()[idx]]}})
end

function on_context_menu_click(menu_idx)
    if menu_idx == 1 then
        move(-1)
    elseif menu_idx == 2 then
        remove()
    elseif menu_idx == 3 then
        move(1)
    elseif menu_idx == 4 then
        redraw()
    end
end

function on_dialog_action(data)
  if data == -1 then
      return
  end
  settings:set(data)
  on_resume()
end

function on_settings()
  ui:show_checkbox_dialog("Select widgets", names, get_checkbox_idx())
end

--utilities--

function redraw()
  local buttons,colors = get_buttons()
  local checkbox_idx = get_checkbox_idx()
  local widget = widgets[checkbox_idx[pos]]
  if aio:is_widget_added(widget) then
    aio:remove_widget(widget)
    colors[pos] = "#909090"
  else
    aio:add_widget(widget)
    colors[pos] = "#1976d2"
  end
  ui:show_buttons(buttons, colors)
end

function set_default_args()
  local args = {}
  for i = 1, #widgets do
    table.insert(args, i)
  end
  settings:set(args)
end

function get_checkbox_idx()
  local tab = settings:get()
  for i = 1, #tab do
    tab[i] = tonumber(tab[i])
  end
  return tab
end

function get_buttons()
  local buttons,colors = {},{}
  local checkbox_idx = get_checkbox_idx()
  for i = 1, #checkbox_idx do
    table.insert(buttons, icons[checkbox_idx[i]])
    if aio:is_widget_added(widgets[checkbox_idx[i]]) then
      table.insert(colors, "#1976d2")
    else
      table.insert(colors, "#909090")
    end
  end
  return buttons,colors
end

function move(x)
  local tab = settings:get()
  if (pos == 1 and x < 0) or (pos == #tab and x > 0) then
    return
  end
  local cur = tab[pos]
  local prev = tab[pos+x]
  tab[pos+x] = cur
  tab[pos] = prev
  settings:set(tab)
  local buttons,colors = get_buttons()
  ui:show_buttons(buttons, colors)
end

function remove()
  local tab = settings:get()
  table.remove(tab,pos)
  settings:set(tab)
  local buttons,colors = get_buttons()
  ui:show_buttons(buttons, colors)
end
