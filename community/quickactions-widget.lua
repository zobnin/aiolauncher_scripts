-- name = "Quick Actions"
-- type = "widget"
-- description = "Launcher selected actions widget"
-- arguments_help = "Long click button for options, open widget settings for list of buttons"
--foldable = "true"
-- author = "Theodor Galanis"
-- version = "2.0"

md_colors = require "md_colors"

local icons = { "fa:pen", "fa:edit", "fa:indent", "fa:bars", "fa:sliders-h", "fa:redo", "fa:power-off", "fa:bring-forward", "fa:eraser", "fa:tools", "fa:layer-minus", "fa:layer-group", "fa:user-shield", "fa:lock", "fa:chevron-down", "fa:chevron-up", "fa:notes-medical", "fa:circle-r", "fa:envelope", "fa:square-full", "fa:microphone", "fa:search"}

local names = {"Menu", "Quick Menu", "Side Menu", "Widget Titles", "Settings", "Refresh launcher", "Restart launcher", "Notifications",  "Clear Norifications", "Control center", "Fold all widgets", "Unfold all widgets", "Private mode", "Screen off", "Scroll down", "Scroll up", "Add note", "Record", "Send mail", "Show recents", "Assistant",  "Search"}

local colors = { md_colors.purple_800,  md_colors.purple_600, md_colors.amber_900, md_colors.orange_900, md_colors.blue_900, md_colors.deep_purple_800, md_colors.red_900, md_colors.green_900, md_colors.green_700, md_colors.blue_800, md_colors.pink_300, md_colors.pink_A200, md_colors.green_600, md_colors.grey_800, md_colors.teal_700, md_colors.teal_800, md_colors.lime_800, md_colors.red_800, md_colors.deep_orange_900, md_colors.deep_purple_700, md_colors.blue_700, md_colors.blue_grey_700}

  local  actions = { "quick_menu", "quick_apps_menu", "apps_menu", "headers", "settings", "refresh", "restart", "notify", "clear_notifications", "quick_settings", "fold", "unfold", "private_mode", "screen_off", "scroll_down", "scroll_up", "add_note", "start_record", "send_mail", "show_recents",  "voice", "search"}

local pos = 0

function on_resume()
  if next(settings:get()) == nil then
    set_default_args()
    set_default_cols()
  end
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
  ui:show_checkbox_dialog("Select actions", names, get_checkbox_idx())
end

--utilities--

function redraw()
  local buttons,colors = get_buttons()
  local checkbox_idx = get_checkbox_idx()
  local action = actions[checkbox_idx[pos]]
aio:do_action(action)
  ui:show_buttons(buttons, colors)
end

function set_default_args()
  local args = {}
  for i = 1, #actions do
    table.insert(args, i)
  end
  settings:set(args)
end

function set_default_cols()
  local cols = {}
  for i = 1, #colors do
    table.insert(cols, i)
  end
  settings:set(cols)
end

function get_checkbox_idx()
  local tab = settings:get()
  for i = 1, #tab do
    tab[i] = tonumber(tab[i])
  end
  return tab
end

function get_buttons()
  local buttons,bcolors = {},{}
  local checkbox_idx = get_checkbox_idx()
  for i = 1, #checkbox_idx do
  table.insert(buttons, icons[checkbox_idx[i]])
  table.insert(bcolors, colors[checkbox_idx[i]])
   end
  return buttons,bcolors
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