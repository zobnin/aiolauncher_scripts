# Introduction

Starting from version 4.0, AIO Launcher supports scripts written in the [Lua scripting language](https://en.wikipedia.org/wiki/Lua_(programming_language)). Scripts should be placed in the directory `/sdcard/Android/data/ru.execbit.aiolauncher/files/`.

There are three types of scripts:

* _Widget scripts_, which can be added to the desktop using the side menu.
* _Search scripts_ that add results to the search box. These can be enabled in the settings.
* _Side menu scripts_ that change the side menu.

The type of script is determined by the line (meta tag) at the beginning of the file:

* `-- type = "widget"`
* `-- type = "search"`
* `-- type = "drawer"`

*Read more about meta tags at the end of the document.*

# Links

* [Step-by-step guide to writing scripts for AIO Launcher](README_INTRO.md)
* [AIO Scripting Telegram Group](https://t.me/aio_scripting)
* [AIO Script Store app](https://play.google.com/store/apps/details?id=ru.execbit.aiostore)
* [Lua Guide](https://www.lua.org/pil/contents.html)
* [Many Lua samples](http://lua-users.org/wiki/SampleCode)

# Changelog

### 7.6.1

* Rich UI supports `image` and `chart` elements alongside text and buttons, with sizes in dp and indexed click/long-click callbacks
* Added [rich-gui-media-sample.lua](samples/rich-gui-media-sample.lua)
* Added `ui:show_slider()` and the `slider` Rich UI element; the released value is delivered to `on_slider_change(index, value)`

### 7.5.0

* Added structured Android widget inspection with `bridge:snapshot()`, `bridge:snapshot_json()`, and render-local `bridge:click_handle()` actions
* Added an ADB-driven workflow for coding agents to capture real Android widgets, replay state transitions, validate wrappers, and verify installed scripts; the inspector endpoint is available in release builds and protected by Android's privileged `DUMP` permission
* Replaced the separate ADB installation helpers with `manage-scripts.sh` for validation and individual or full installation and removal

### 7.4.0

* Added `intent:open_uri()`, `intent:open_app_settings()`, and `intent:open_system_settings()` helpers
* Added split network helpers: `system:internet_state()`, `system:active_network_state()`, `system:wifi_state()`, `system:mobile_state()`, and `system:bluetooth_state()`; `system:network_state()` is deprecated

[Full changelog](CHANGELOG.md)

# Widget scripts

The work of the widget script begins with one of the three described functions. Main work should be done in one of them.

* `on_load()` - called on first script load (_starting with AIO Launcher 5.2.3_).
* `on_resume()` - called every time you return to the desktop.
* `on_alarm()` - called every time you return to the desktop, but no more than once every 30 minutes.
* `on_tick(ticks)` - called every second while the launcher is on the screen. The `ticks` parameter is number of seconds after last return to the launcher.

The `on_resume()` and `on_alarm()` callbacks are also triggered when a widget is added to the screen and when the screen is forced to refresh. Do not rely on `on_load()` suppressing them; keep loading callbacks idempotent.

For most network scripts `on_alarm()` should be used.

# Search scripts

Unlike widget scripts, search scripts are launched only when you open the search window:

* `on_load()` - called every time when user opens the search window (_starting with AIO Launcher 5.2.3_).

Then the following function is triggered each time a character is entered:

* `on_search(string)` is run when each character is entered, `string` - entered string.

The search script can use four functions to display search results:

* `search:show_buttons(names, [colors], [top])` - show rich text buttons in the search results, the first parameter is table of button names, second - table of button colors in format `#XXXXXX`, `top` - whether the results need to be shown at the top (false by default). Button labels support HTML, Markdown, and icon markup described in the Icons section;
* `search:show_lines(lines, [colors], [top])` - show rich text lines in the search results. Lines support HTML, Markdown, and icon markup described in the Icons section;
* `search:show_progress(names, progresses, [colors], [top])` - show progress bars in the search results, the first parameter is a table of rich text labels, the second is a table of progress bars;
* `search:show_chart(points, format, [title], [show_grid], [top])` - show chart in the search results, parameters are analogous to `ui:show_chart()`. The optional title is rich text.

Keep in mind that regardless of how many items you display in the search results, only the first three lines will be shown.

When user click on a result, one of the following functions will be executed:

* `on_click(index)` - normal click;
* `on_long_click(index)` - long-click.

Both functions gets index of the clicked element (starting with 1) as an argument. Each function can return `true` or `false`, depending on whether the script wants to close the search window or not.

## Chat mode in search scripts

Search scripts can switch the search UI into a chat mode and handle a question-answer loop.

* `search:chat_start([label], [initial_message], [icon])` - enable chat mode. `label` sets the chat header. `initial_message` (optional) is shown as the first assistant message. `icon` (optional) is a FontAwesome icon name like `fa:comment` and is used for the chat FAB button.
* `search:chat_stop()` - disable chat mode and return to normal search results.

The chat callback:

* `on_chat(messages)` - called when user submits a message in chat mode. `messages` is a table of message tables, each with:
  * `role` - `"user"`, `"assistant"`, `"system"`, or `"error"`;
  * `content` - message text;
  * `context` - optional extra context string.

Return value of `on_chat`:

* a string (single assistant reply), or
* a table of strings (multiple assistant replies), or
* a table of message tables `{ role = "...", content = "...", context = "..." }` to append multiple messages with explicit roles.

To exit chat mode on a command, call `search:chat_stop()`.

If you want the script to respond only to search queries that have a word in the beginning (prefix), use the appropriate meta tag. For example:

```
-- prefix="youtube|yt"
```

If you put such a tag at the beginning of your script, its `on_search()` function will only be called if a user types something like "youtube funny video" or "yt funny video". The prefix itself will be removed before being passed to the function.

# Side menu scripts

With side menu scripts, you can display your own list in the menu. The script can be selected by pulling the menu down.

The script starts with the following function:

* `on_drawer_open()`

In this function, you must prepare a list and display it using one of the following functions:

* `drawer:show_list(lines, [icons], [badges], [show_alphabet])` - shows lines, optionally you can specify a table of icons (in `fa:icon_name` format), a table of lines to be displayed in badges and pass a boolean value: whether to show the alphabet;
* `drawer:show_ext_list(lines, [max_lines)` - shows multiline lines, optionally you can specify the maximum number of lines of each element (default is 5).

The following functions are also available:

* `drawer:add_buttons(icons, default_index)` - shows icons at the bottom of the menu (in raw `fa:icon_name` format, not `%%fa:icon_name%%`), `default_index` is the index of the selected icon;
* `drawer:clear()` - clears the list;
* `drawer:close()` - closes the menu;
* `drawer:change_view(name)` - switches the menu to another script or display style (argument: either script file name, `sortable` or `categories`).

Clicking on list items will call `on_click(index)`, long-clicking will call `on_long_click(index)`, clicking a bottom icon will call `on_button_click(index)`.

The list output functions support HTML and Markdown (see User Interface section for details).

# API Reference

## User Interface

_Available only in widget scripts._

_AIO Launcher also offers a way to create more complex UIs: [instructions](README_RICH_UI.md)_

Content renderers (`show_text`, `show_lines`, `show_table`, `show_buttons`, `show_progress_bar`, `show_slider`, `show_chart`, and `show_image`) replace the widget content. To combine images, charts, sliders, text, and controls, use one [Rich UI definition](README_RICH_UI.md#images-and-charts). Toasts, context menus, and title/settings methods do not replace the content.

* `ui:show_text(string)` - displays rich text in widget, repeated call will erase previous text;
* `ui:show_lines(table, [table])` - displays a list of rich text lines with the sender (in the manner of a mail widget), the second argument (optional) - the corresponding senders (formatting in the style of a mail widget);
* `ui:show_table(table, [main_column], [centering])` - displays rich text table, first argument: table of tables, second argument: main column, it will be stretched, occupying main table space (if argument is zero or not specified all table elements will be stretched evenly), third argument: boolean value indicating whether table cells should be centered;
* `ui:show_buttons(names, [colors])` - displays a list of rich text buttons, the first argument is a table of strings, the second is an optional argument, a table of colors in the format #XXXXXX. Button labels support HTML, Markdown, and icon markup described in the Icons section;
* `ui:show_progress_bar(text, current_value, max_value, [color])` - shows the progress bar with a rich text label;
* `ui:show_slider(text, value, [min_value], [max_value])` - shows a draggable integer slider with a rich text label (an empty label gives the slider the whole width); `min_value` and `max_value` default to 0 and 100. When the user releases the slider, `on_slider_change(1, value)` is called (see [Clicks](#clicks));
* `ui:show_chart(points, [format], [title], [show_grid], [not_used], [copyright])` - shows the chart, points - table of coordinate tables, format - data format (see below), title - rich text chart name, show\_grid - grid display flag, copyright - rich text string displayed in the lower right corner;
* `ui:show_image(uri, [height_dp])` - show an image from a URL or URI; a positive height is in dp; omitting the height or passing `0` uses automatic height;
* `ui:show_toast(string)` - shows rich text informational message in Android style;
* `ui:default_title()` - returns the standard widget title (set in the `name` metadata);
* `ui:set_title(string)` - changes the rich text title of the widget, should be called before the data display function (empty line - reset to the standard title);
* `ui:set_expandable()` - shows expand button on widget update;
* `ui:is_folded()` - check if widgets is folded;
* `ui:is_expanded()` - checks if expanded mode is enabled;
* `ui:set_progress(float)` - sets current widget progress (like in Player and Health widgets);
* `ui:set_edit_mode_buttons(table)` - adds icons listed in the table (formatted as raw `"fa:name"`, not `"%%fa:name%%"`) to the edit mode. When an icon is clicked, the function `on_edit_mode_button_click(index)` will be called.

The `ui:show_chart()` function takes a string as its second argument to format the x and y values on the screen. For example, the string `x:date y:number` means that the X-axis values should be formatted as dates, and the Y-values should be formatted as a regular number. There are five formats in total:

* `number` - an ordinary number with group separation;
* `float` - the same, but with two decimal places;
* `date` - localized day/month from Unix milliseconds;
* `time` - local hours:minutes from Unix milliseconds;
* `none` - disable.

Do not put spaces after the colons in axis formats. Convert timestamps in seconds to milliseconds for `date`/`time`. These rules also apply to `chart` elements in `gui`.

### Clicks

When you click on any element of the interface, the `on_click(number)` callback will be executed, where number is the ordinal number of the element. A long click calls `on_long_click(number)`. For example, if you use `ui:show_buttons` to show three buttons, then clicking the first button will call `on_click` with argument 1, the second with arguments 2, and so on. Standalone images and charts use index `0`. Rich UI uses the 1-based position in the full definition, including spacer and new-line commands.

Sliders do not call `on_click`. When the user releases a slider, `on_slider_change(number, value)` is called once with the element number (`1` for `ui:show_slider`) and the new integer value. There is no callback while the thumb is still moving. Store the value in a script variable and use it the next time you render the widget, otherwise the next render will move the slider back to the old value.

```lua
local volume = 5

function on_resume()
    ui:show_slider("Volume", volume, 0, 15)
end

function on_slider_change(index, value)
    volume = value
    ui:show_toast("Volume: " .. value)
end
```

### Folding

By default, the script shows either the first line of content or a line specified in the function argument in collapsed mode. However, you can change this behavior using a special meta-tag:

```
-- on_resume_when_folding = "true"
```

In this case, the `on_resume()` callback will be triggered each time the widget is collapsed. Then you can check the widget's collapsed status using the `ui:folding_flag()` function and display different UI depending on the state of this flag.

### HTML and Markdown formatting

Text fields across the UI API support many HTML tags, including `ui:show_text()`, `ui:show_lines()`, `ui:show_table()` cells, `ui:show_buttons()`, `ui:show_progress_bar()`, `ui:show_chart()` titles/copyright, and `ui:set_title()`. For example:

```
First line<br/> Second line
<b>Bold Line</b><br/><i>Oblique Line</i>
<font color="red">Red text</font>
<span style="background-color: #00FF00">Text on green background</span>
```

You can also use Markdown markup. To do this, add the prefix `%%mkd%%` to the beginning of the line. Or you can disable the formatting completely with the prefix `%%txt%%`.

### Icons

You can insert FontAwesome icons inside any rich text field, including button labels. To do this use this syntax: `%%fa:ICON_NAME%%`. For example:

```
ui:show_text("<b>This</b> is the text with icons %%fa:face-smile%% %%fa:poo%% <i>and styles</i>")
```

To align icons to a uniform width (like FontAwesome’s `fa-fw`), use `%%fa-fw:ICON_NAME%%`. This renders the icon in a fixed box (\~1.25em), which keeps lists and inline rows from shifting:

```
ui:show_text("Aligned list: %%fa-fw:check%% Done  •  %%fa-fw:xmark%% Skip")
```

Inline icon markup is rich-text markup, not a general icon id. Use `%%fa:ICON_NAME%%`, `%%fa-fw:ICON_NAME%%`, and `%%weather:ICON_CODE:day|night%%` in text fields such as `ui:show_text()`, `ui:show_lines()`, `ui:show_table()` cells, `ui:show_buttons()`, `search:show_lines()`, `search:show_buttons()`, progress labels, chart titles, drawer list text, dialog text/buttons, toasts, and rich UI text/button elements.

Dedicated icon parameters and icon-only controls use raw icon ids, not inline markup: `drawer:add_buttons()`, `ui:set_edit_mode_buttons()`, and rich UI icon elements. If you want an icon-only `ui:show_buttons()` or `search:show_buttons()` button, specify a raw id as the whole button name, for example `fa:play` or `weather:1:day`. For labeled buttons, prefer inline markup such as `%%fa-fw:play%% Play`.

*Note: AIO only supports icons up to FontAwesome 6.3.0.*

Weather condition icons use AIO Launcher's dedicated weather icon font, not FontAwesome. To insert a weather icon inside text, use this syntax:

```
ui:show_text("%%weather:1:day%% Sunny")
ui:show_text("%%weather:1:night%% Clear night")
```

When rendering real weather data from `weather:get_by_hour(id)`, use `weather:icon(icon_code, [is_day])` and wrap the returned id with double percent signs:

```
local icon = weather:icon(hour.icon_code)
ui:show_text("%%" .. icon .. "%% " .. temp_text)
```

Do not use FontAwesome icons such as `fa:sun`, `fa:cloud`, or `%%fa-fw:cloud-rain%%` for actual weather conditions.

## Dialogs

* `dialogs:show_dialog(title, text, [button1_text], [button2_text])` - show dialog, the first argument is the title, the second is the text, button1\_text is the name of the first button, button2\_text is the name of the second button;
* `dialogs:show_edit_dialog(title, [text], [default_value])` - show the dialog with the input field: title - title, text - signature, default\_value - standard value of the input field;
* `dialogs:show_radio_dialog (title, lines, [index])` - show a dialog with a choice: title - title, lines - table of lines, index - index of the default value;
* `dialogs:show_checkbox_dialog(title, lines, [table])` - show dialog with selection of several elements: title - title, lines - table of lines, table - table default values;
* `dialogs:show_list_dialog(prefs)` - shows dialog with list of data.

Dialog button clicks should be handled in the `on_dialog_action(number)` callback, where 1 is the first button, 2 is the second button, and -1 is nothing (dialog just closed). `dialogs:show_radio_dialog()` returns the index of the selected item or -1 in case the cancel button was pressed. `dialogs:show_checkbox_dialog()` returns the table of indexes or -1. `ui:show_edit_dialog()` returns text or -1.

If the first argument of the dialog contains two lines separated by `\n`, the second line becomes a subtitle.

Dialog titles, subtitles, button labels, and lines in `show_radio_dialog`, `show_checkbox_dialog`, and `show_list_dialog` support rich text and icon markup: `%%fa:ICON_NAME%%`, `%%fa-fw:ICON_NAME%%`, and `%%weather:ICON_CODE:day|night%%`. Use `%%fa-fw:%%` when all rows start with an icon to keep labels horizontally aligned.

List dialog accepts table as argument:

```
`title` - dialog title;
`lines` - table with strings to display;
`search` - true if the dialog should display a search string (default: true);
`zebra` - true if the dialog is to strip the colors of the lines into different colors (default: true);
`split_symbol` - symbol, which will be used as a line separator into right and left parts.
```

## Text editor

_Available from: 4.4.1_

* `dialogs:show_rich_editor(prefs)` - show complex editor dialog with undo support, lists, time, colors support. It can be used to create notes and tasks style widgets.

Dialog accepts table as argument:

```
`text` - default text to show in the editor;
`new` - boolean value indicating that it is new note/task/etc;
`list` - boolean velue indicating that text should be shown as list with checkboxes;
`date` - date of the note/task/etc creation;
`due_date` - task completion date;
`colors` - a table of colors from which the user can choose;
`color` - default color`;
`checkboxes` - up to three checkboxes to display under text;
```

The values of these fields affect the appearance of the dialog. Any of these fields can be omitted.

When user closes the dialog by pressing one of the buttons at the bottom of the dialog (Save or Cancel), the `on_dialog_action` colbeck will be called, the parameter for which will be either -1 in case of pressing Cancel. Or a table of the following content:

```
`text` - text;
`color` - selected color;
`due_date` - selected task completion date;
`checked` - table of selected checkboxes;
`list` - boolean velue indication that text should be shown as list with checkboxes;
```

## Context menu

_Available only in widget scripts._

* `ui:show_context_menu(table)` - function shows the context menu. Function takes a table of tables with icons and menu item names as its argument. For example, the following code will prepare a context menu of three items:

```
ui:show_context_menu({
    { "share", "Menu item 1" },
    { "copy",  "Menu item 2" },
    { "trash", "Menu item 3" },
})
```

Here `share`, `copy` and `trash` are the names of the icons, which can be found at [Fontawesome](https://fontawesome.com/).

When you click on any menu item, the callback `on_context_menu_click(idx)` will be called, where `idx` is the index of the menu item.

## Meta widgets

_Available from: 4.7.0_

* `ui:build(table)` - constructs a widget from pieces of other AIO widgets.

The function takes a command table of this format as a parameter:

```
`battery` - battery progress bar;
`ram` - ram progress bar;
`nand` - nand progress bar;
`traffic` - traffic progress bar;
`screen` - screen time progress bar;
`alarm` - next alarm info;
`clock` - current time;
`notes [NUM]` - last NUM notes;
`tasks [NUM]` - last NUM tasks;
`calendar [NUM]` - last NUM calendar events;
`calendarw` - weekly calendar;
`exchage [NUM] [FROM] [TO]` - exchange rate FROM currency TO currency;
`player` - player controls;
`weather [NUM]` - weather forecast for NUM days;
`worldclock [TIME_ZONE]` - time in the given TIME_ZONE;
`notify [NUM]` - last NUM notifications;
`dialogs [NUM]` - last NUM dialogs;
`calculator` - calculator;
`feed [NUM]` - news feed;
`control` - control panel;
`stopwatch` - stopwatch;
`finance [NUM]` - finance tickers;
`financechart` - finance chart;
`contacts [NUM]` - contacts (number of lines);
`apps [NUM]` - frequent apps (number of lines);
`appbox [NUM]` - my apps (number of lines);
`applist [NUM]` - apps list (number of lines);
`appfolders [NUM]` - app folders;
`appcategories [NUM]` - app categries;
`timer` - timers;
`mailbox [NUM]` - mail widget;
`dialer` - dialer;
`recorder` - recorder;
`telegram` - telegram messages;
`smartspacer` - SmartSpacer;
`widgetscontainer` - widgets container;
`tips` - tips;
`text [TEXT]` - just shows TEXT;
`space [NUM]` - NUM of spaces.
```

[Sample](samples/build_ui_sample.lua).

## System

* `system:open_browser(url)` - opens the specified web URL in a browser or application that can handle this type of URL. For app links, Android settings, and other non-web intents, prefer the `intent` module helpers below;
* `system:exec(string, [id])` - executes a shell command;
* `system:su(string, [id])` - executes a shell command as root;
* `system:location()` - returns the location in the table with two values (location request is NOT executed, the value previously saved by the system is used);
* `system:request_location()` - queries the current location and returns it to the `on_location_result` callback;
* `system:to_clipboard(string)` - copies the string to the clipboard;
* `system:clipboard()` - returns a string from the clipboard:
* `system:vibrate(milliseconds)` - vibrate;
* `system:alarm_sound(seconds)` - make alarm sound;
* `system:share_text(string)` - opens the "Share" system dialog;
* `system:lang()` - returns the language selected in the system;
* `system:tz()` - returns TimeZone string (example: Africa/Cairo);
* `system:tz_offset()` - returns TimeZone offset in seconds;
* `system:currency()` - returns default currency code based on locale;
* `system:format_date_localized(format, date)` - returns localized date string (using java formatting);
* `system:battery_info()` - returns table with battery info;
* `system:system_info()` - returns table with system info;
* `system:brightness_state()` - returns current screen brightness state;
* `system:network_state()` - deprecated legacy active/default network snapshot; use the split methods below for new scripts;
* `system:internet_state()` - returns internet capability/validation for the active network;
* `system:active_network_state()` - returns active/default network transport details;
* `system:wifi_state()` - returns honest Wi-Fi visibility state;
* `system:mobile_state()` - returns honest cellular visibility state;
* `system:bluetooth_state()` - returns honest Bluetooth limitation state;
* `system:show_notify(table)` - show system notification;
* `system:cancel_notify()` - cancel notification.

The result of executing a shell command is sent to the `on_shell_result(string)` or `on_shell_result_$id(string)` (_starting from AIO 5.7.5_) callback.

Battery info table:

```
`present` - `true` if a battery is present;
`charging` - `true` if the battery is charging;
`source` - charging source string;
`percent` - battery charge percent;
`health` - battery health string;
`technology` - battery technology string;
`temp` - battery temperature in Celsius;
`voltage` - battery voltage;
`power_saver` - `true` if power saver mode is enabled.
```

System info table:

```
`device` - device name;
`connection` - current network class;
`android_version` - Android version;
`aio_version` - AIO Launcher version;
`mem_total` - total RAM as a human-readable string;
`mem_available` - available RAM as a human-readable string;
`storage_total` - total internal storage as a human-readable string;
`storage_available` - available internal storage as a human-readable string;
`sdcard_total` - total external storage as a human-readable string;
`sdcard_available` - available external storage as a human-readable string.
```

Brightness state table:

```
`level` - current brightness level;
`max` - maximum brightness level;
`percent` - brightness percent from 0 to 100;
`fraction` - brightness fraction from 0.0 to 1.0;
`is_auto` - `true` if automatic brightness is enabled;
`sensor_available` - `true` if the device has a light sensor.
```

Network state helpers:

`system:network_state()` is deprecated. It describes only the active/default network and must not be used to infer whether Wi-Fi, mobile data, SIM, or Bluetooth is turned off. New scripts should use the split helpers below.

```lua
local internet = system:internet_state()
-- internet.connected : boolean, active network has INTERNET capability
-- internet.validated : boolean, Android verified real internet access
-- internet.transport : "wifi" | "cellular" | "ethernet" | "vpn" | "bluetooth" | "unknown" | "none"
-- internet.metered   : boolean
-- internet.roaming   : boolean

local net = system:active_network_state()
-- net.type           : "wifi" | "cellular" | "ethernet" | "vpn" | "bluetooth" | "unknown" | "none"
-- net.class          : "WiFi" | "2G" | "3G" | "4G" | "5G" | "Ethernet" | "VPN" | "Bluetooth" | ""
-- net.name           : Wi-Fi SSID or cellular operator only when available for the active network
-- net.name_available : boolean
-- net.connected      : boolean, active network has INTERNET capability
-- net.validated      : boolean, Android verified real internet access
-- net.metered        : boolean
-- net.roaming        : boolean

local wifi = system:wifi_state()
-- wifi.state          : "active" | "not_active" | "unknown"
-- wifi.ssid           : SSID only when active and available
-- wifi.ssid_available : boolean
-- wifi.can_toggle     : false
-- wifi.settings       : "wifi"
-- wifi.limitation     : "toggle_restricted"

local mobile = system:mobile_state()
-- mobile.state              : "active" | "not_active" | "unknown"
-- mobile.class              : "2G" | "3G" | "4G" | "5G" only when active
-- mobile.operator           : operator only when active and available
-- mobile.operator_available : boolean
-- mobile.can_toggle         : false
-- mobile.settings           : "network"
-- mobile.limitation         : "toggle_restricted"

local bt = system:bluetooth_state()
-- bt.state      : "unknown"
-- bt.can_toggle : false
-- bt.settings   : "bluetooth"
-- bt.limitation : "not_exposed"
```

`state = "not_active"` means the radio is not the active/default network, not that it is turned off. Scripts cannot toggle Wi-Fi, Bluetooth, mobile data, or choose a data SIM through these APIs; open Android settings instead.

`system:show_notify(table)` and `system:cancel_notify()` can be used to display, update, and delete system notifications. The possible fields for the `table` (each of them is optional) are:

```
`message` - the message displayed in the notification;
`silent` - true if the notification should be silent;
`action1` - the name of the first notification action;
`action2` - the name of the second notification action;
`action3` - the name of the third notification action.
```

When the notification is clicked, the main launcher window will open. When one of the three actions is clicked, the callback `on_notify_action(idx, name)` will be executed with the action's index and name as parameters.

_Keep in mind that the callback will only be executed for scripts of type `widget`._

## Usage statistics

_Available from: 7.2.0_

The `usage` module reads Android app usage statistics.

* `usage:state()` - returns permission/support state;
* `usage:request_permission([callback_name])` - opens Usage Access settings and optionally calls `callback_name(granted)`;
* `usage:stats([options])` - returns app usage statistics.

`usage:stats()` returns the string `permission_error` when Usage Access is not granted.

Usage Access settings do not provide an Android result callback. If `callback_name` is supplied, AIO calls it with the current permission state; scripts should also re-check `usage:state()` from `on_resume()` after the user returns from settings.

State table:

```
`supported` - `true` if usage stats are supported on this Android version;
`has_permission` - `true` if Usage Access is granted.
```

Options for `usage:stats(options)`:

```
`start_time` - start of the range as Unix time in seconds (default: start of today);
`end_time` - end of the range as Unix time in seconds (default: now);
`limit` - maximum number of apps to return, from 1 to 50 (default: 10).
```

Stats table:

```
`supported` - `true` if usage stats are supported;
`has_permission` - `true` if Usage Access is granted;
`start_time` - actual range start in seconds;
`end_time` - actual range end in seconds;
`screen_time_ms` - screen time in milliseconds;
`screen_time_seconds` - screen time in seconds;
`total_app_time_ms` - total visible app time in milliseconds;
`total_app_time_seconds` - total visible app time in seconds;
`apps` - table of app usage rows.
```

App usage row format:

```
`package` - app package name;
`package_name` - same package name, kept for convenience;
`name` - app display name;
`time_ms` - visible time in milliseconds;
`time_seconds` - visible time in seconds;
`percent` - app share of total visible app time.
```

## Traffic counters

_Available from: 7.2.0_

The `traffic` module reads network traffic counters used by the Traffic widget.

* `traffic:state()` - returns support and permission state;
* `traffic:request_permission([callback_name])` - requests required permissions and optionally calls `callback_name(granted)`;
* `traffic:counters([options])` - returns traffic counters.

`traffic:counters()` returns the string `permission_error` when the required permissions are not granted.

Traffic counters need Usage Access and phone state permission. `traffic:request_permission()` may open Usage Access settings; re-check `traffic:state()` from `on_resume()` after the user returns.

State table:

```
`supported` - `true` if traffic counters are supported on this Android version;
`has_permission` - `true` if all required permissions are granted;
`has_usage_permission` - `true` if Usage Access is granted;
`has_phone_permission` - `true` if phone state permission is granted.
```

Options for `traffic:counters(options)`:

```
`sim_id` - SIM id to use, or -1 for device totals;
`billing_day` - first day of the billing period, 1..31.
```

Counters table:

```
`supported` - `true` if traffic counters are supported;
`has_permission` - `true` if all required permissions are granted;
`has_usage_permission` - `true` if Usage Access is granted;
`has_phone_permission` - `true` if phone state permission is granted;
`today_used_bytes` - traffic used today;
`period_used_bytes` - traffic used in the current billing period;
`month_used_bytes` - same value as `period_used_bytes`;
`limit_bytes` - configured traffic limit in bytes;
`billing_day` - billing day used for the calculation;
`sim_id` - SIM id used for the calculation;
`is_online` - `true` if a network connection is active.
```

## Intents

* `intent:start_activity(table)` - starts activity with intent described in the table;
* `intent:send_broadcast(table)` - sends broadcast intent described in the table.
* `intent:open_uri(uri)` - opens a normal URI or deep link with Android `ACTION_VIEW`. Use it for `https:`, `mailto:`, `tel:`, `geo:`, `market:`, and known app links. Do not use Android `intent:#Intent;...` strings here;
* `intent:open_app_settings(package)` - opens the Android app-info/settings screen for the given package, for example `intent:open_app_settings("com.whatsapp")`;
* `intent:open_system_settings(name)` - opens a supported Android settings screen by simple name: `settings`, `wifi`, `bluetooth`, `network`, `mobile_network`, `location`, `display`, `sound`, `accessibility`, `battery`, `battery_saver`, `notifications`, `apps`, `manage_apps`, `date`, `security`, `storage`, `nfc`, or `usage_access`;

Intent table format (all fields are optional):

* `action` - general action to be performed;
* `category` - intent category;
* `package` - explicit application package name;
* `component` - Explicitly set the component to handle the intent;
* `type` - mime type;
* `data` - data this intent is operating on;
* `flags` - integer Android intent flag bitmask, or a table of integer flag values to combine;
* `extras` - table of extra values in `key = value` format.

## Launcher control

* `aio:available_widgets()` - returns a table with the metadata of all widgets, scripts and plugins available for adding to the screen (_available from: 4.5.0_);
* `aio:active_widgets()` - returns a table with the metadata of all widgets, scripts, and plugins already added to the screen (_available from: 4.5.0_);
* `aio:add_widget(string, [position])` - adds a builtin widget, script widget or clone of an existing widget to the screen;
* `aio:remove_widget(string)` - removes the widget from the screen (instead of the name you can also pass the widget number or do not pass anything - then the current widget will be deleted);
* `aio:move_widget(string, position)` - moves the widget to a new position (you can also use the widget position instead of the name) (_available from: 4.5.0_);
* `aio:fold_widget(string, [boolean])` - fold/unfold widget (if you do not specify the second argument the state will be switched) (_available from: 4.5.0_);
* `aio:is_widget_added(string)` - checks if the widget is added to the screen;
* `aio:self_name()` - returns current script file name (_available from: 4.5.0_);
* `aio:send_message(value, [script_name], [offline])` - sends lua value to other script or scripts; if `offline` is true and the target search/drawer script is not active, the last message will be stored and delivered when the script starts (only works when `script_name` is provided);
* `aio:colors()` - returns table with current theme colors;
* `aio:do_action(string)` - performs an AIO action ([more](https://aiolauncher.app/api.html));
* `aio:actions()` - returns a list of available actions;
* `aio:settings()` - returns a list of available AIO Settings sections;
* `aio:add_todo(icon, text)` - add a TODO item with the specified Fontawesome icon and text;
* `aio:open_settings([section])` - open AIO Settings or AIO Settings section;
* `aio:open_notifications_panel()` - opens the system notifications panel (same as swiping down the status bar);
* `aio:open_side_menu()` - opens the launcher’s app drawer;
* `aio:open_search([query])` - opens the launcher search screen; if `query` is provided, the search field will be pre-filled with this text;
* `aio:show_toast(string)` - shows informational message in Android style;
* `aio:launcher_info()` - returns basic information about the AIO Launcher build:

```lua
local info = aio:launcher_info()
-- info.package    : package name (e.g. "ru.execbit.aiolauncher")
-- info.version    : version name (e.g. "6.0.1")
-- info.code       : version code (longVersionCode)
-- info.build_type : build type (e.g. "release", "debug", "beta")
-- info.beta       : true if this is not a "release" build
```

Format of table elements returned by `aio:available_widgets()`:

```
`name` - internal name of the widget;
`label` - title of the widget;
`type` - widget type: `builtin`, `script` or `plugin`;
`description` - widget description (usually empty for non-script widgets);
`clonable` - true if the widget can have clones (examples: "My apps", "Contacts", "Mailbox" widgets);
`enabled` - true if the widget is placed on the screen.
```

Format of table elements returned by `aio:active_widgets()`:

```
`name` - internal name of the widget;
`label` - widget visible name;
`position` - position on the screen;
`folded` - true if widget is folded.
```

Format of table elements returned by `aio:actions()`:

```
`name` - action name;
`short_name` - action short name;
`label` - action name visible to the user;
`args` - action arguments if any.
```

Format of table elements returned by `aio:colors()`:

```
`primary_text` – base text color;
`secondary_text` – color for secondary text (e.g., sender name, time, etc.);
`button` – button background color;
`button_text` – text color inside buttons;
`progress` – general progress bar color;
`progress_good` – color for positive progress states (e.g., full battery or charging);
`progress_bad` – color for negative progress states (e.g., battery level below 15%);
`enabled_icon` – color for enabled icons (see the Control Panel widget);
`disabled_icon` – color for disabled icons (see the Control Panel widget);
`accent` – accent color;
`badge` – badge color.
```

To accept a value sent by the `send_message` function, the receiving script must implement a callback `on_message(value)`.

The script can track screen operations such as adding, removing or moving a widget with the `on_widget_action()` callback. For example:

```
function on_widget_action(action, name)
    ui:show_toast(name.." "..action)
end
```

This function will be called on add, remove or move any widget.

It is also possible to process an swipe to right action (if this action is selected in the settings). To do this, create a function `on_action`:

```
function on_action()
    ui:show_toast("Action fired!")
end
```

To change the action of the settings icon in the widget's edit menu, you can add the on_settings() function to the script. It will be called every time the user presses the icon.

```
function on_settings()
    ui:show_toast("Settings icon clicked!")
end
```

## Application management

* `apps:apps([sort_by])` - returns the table of tables of all installed applications;
* `apps:app(package_name)` - return the table of the given application;
* `apps:launch(package)` - launches the application;
* `apps:show_edit_dialog(package)` - shows edit dialog of the application;
* `apps:categories()` - returns a table of category tables;
* `apps:set_hidden(package, hidden)` - hides or unhides an application;
* `apps:set_category(package, category_id)` - moves an application to a category;
* `apps:set_name(package, name)` - changes custom application name;
* `apps:set_color(package, color)` - changes custom application color;
* `apps:set_tags(package, tags)` - changes application tags, where `tags` is a table of strings;
* `apps:list([sort_by], [no_hidden])` - deprecated compatibility shortcut that returns package names only.

The format of the app table:

```
`pkg` - name of the app package (if it is cloned app or Android for Work app package name will also contain user id, like that: `com.example.app:123`);
`name` - name of the application;
`color` - application color;
`hidden` - true if the application is hidden;
`suspended` - true if the application is suspended;
`category_id` - category ID;
`tags` - array of tags;
`badge` - number on the badge;
`icon` - icon of the application in the form of a link (can be used in the side menu scripts).
```

The format of the category table:

```
`id` - category id (id above 1000 are custom categories);
`name` - category name;
`icon` - category icon;
`color` - category color;
`hidden` - the category is hidden by the user.
```

Sorting options:

* `abc` - alphabetical (default);
* `launch_count` - by number of launches;
* `launch_time` - by launch time;
* `install_time` - by installation time.

`apps:set_hidden()`, `apps:set_category()`, `apps:set_name()`, `apps:set_color()`, and `apps:set_tags()` return a status table:

```
`ok` - `true` on success, `false` on error;
`error` - error string when `ok` is `false` (for example: `app_not_found`).
```

Any application-related events (installation, removal, name change, etc.) will call the `on_apps_changed()` callback (_not in the search scripts_).

## Network

* `http:get(url, [id])` — executes an HTTP **GET** request.
* `http:post(url, body, media_type, [id])` — executes an HTTP **POST** request.
* `http:put(url, body, media_type, [id])` — executes an HTTP **PUT** request.
* `http:delete(url, [id])` — executes an HTTP **DELETE** request.
* `http:set_headers(table)` — sets custom headers for **all subsequent** requests; the argument is a table of strings in the form `"Header-Name: value"`.
* `http:set_certificate_verification(enabled)` — enables or disables HTTPS certificate verification for **all subsequent** requests. Verification is enabled by default. Disabling it is unsafe and should only be used for local devices, self-signed certificates, or debugging.

These functions do not return values directly. After a request finishes, one of the callbacks below will be invoked.

### Response callbacks

If no `id` was provided, the callback is:

```
on_network_result(body, code, headers)
```

If an `id` was provided, the callback name becomes:

```
on_network_result_<id>(body, code, headers)
```

Callback parameters:

* **body** — string containing the response body;
* **code** — HTTP status code (200, 404, etc.);
* **headers** — Lua table containing response headers.

Header names are lowercase (`"content-type"`, `"location"`).
If a header has multiple values, they are joined with `", "`.

### Error callbacks

If a network error occurs, one of the following callbacks is invoked:

```
on_network_error(error_message)
```

or, if an `id` was provided:

```
on_network_error_<id>(error_message)
```

Handling this callback is optional.

## Calendar

* `calendar:events([start_date], [end_date], [cal_table])` - returns table of event tables of all calendars, start_date - event start date, end_date - event end date, cal_table - calendar ID table (function will return the string `permission_error` if the launcher does not have permissions to read the calendar);
* `calendar:calendars()` - returns table of calendars tables;
* `calendar:request_permission([callback_name])` - requests access rights to the calendar and optionally calls `callback_name(granted)`;
* `calendar:show_event_dialog(id|event_table)` - shows the event dialog;
* `calendar:open_event(id)` - opens an event in the system calendar;
* `calendar:open_new_event([start], [end])` - opens a new event in the calendar, `start` - start date of the event in seconds, `end` - end date of the event;
* `calendar:add_event(event_table)` - legacy method that adds an event to the system calendar and returns the created event id, or `permission_error`;
* `calendar:create_event(event_table)` - creates an event and returns a status table with `id`;
* `calendar:update_event(event_table)` - updates an event and returns a status table;
* `calendar:delete_event(id)` - deletes an event and returns a status table;
* `calendar:share_event(id)` - opens the system share sheet for an event and returns a status table;
* `calendar:is_holiday(date)` - returns true if the given date is a holiday or a weekend;
* `calendar:enabled_calendar_ids()` - returns list of calendar IDs enabled in the builtin Calendar widget settings.

Event table format:

Since AIO Launcher 7.2.0, event time fields are named `begin_time` and `end_time`. Older versions used `begin` and `end`.

```
`id` - event ID;
`calendar_id` - calendar ID;
`title` - title of the event;
`description` - description of the event;
`color` - color of the event;
`status` - status string of the event or empty (`tentative`, `confirmed`, `canceled`);
`location` - address of the event by string;
`begin_time` - start time of the event (in seconds);
`end_time` - time of the event end (in seconds);
`all_day` - boolean value, which means that the event lasts all day.
```

`calendar:create_event()` requires `calendar_id`, `begin_time`, and `end_time`; optional text fields such as `title` and `description` default to empty strings. `calendar:update_event()` requires `id` and updates the fields that are present in the table.

Calendar table format:

```
`id` - calendar identifier;
`name` - name of the calendar;
`color` - color of the calendar in the format #XXXXXXXX.
```

Status table returned by `calendar:create_event()`, `calendar:update_event()`, `calendar:delete_event()`, and `calendar:share_event()`:

```
`ok` - `true` on success, `false` on error;
`id` - created event id, only for `calendar:create_event()`;
`error` - error string when `ok` is `false` (for example: `permission_error`).
```

If `calendar:request_permission()` is called without a callback name, it calls `on_permission_granted()` after the user grants permission. If a callback name is supplied, the callback receives one boolean argument:

```lua
calendar:request_permission("on_calendar_permission")

function on_calendar_permission(granted)
    ui:show_toast("Calendar permission: " .. tostring(granted))
end
```

## Phone

* `phone:contacts()` - returns table of phone contacts (function will return the string `permission_error` if the launcher does not have permissions to read contacts);
* `phone:request_permission([callback_name])` - requests access rights to contacts and optionally calls `callback_name(granted)`;
* `phone:make_call(number)` - dial the number in the dialer;
* `phone:send_sms(number, [text])` - open SMS application and enter the number, optionally enter text;
* `phone:show_contact_dialog(id|lookup_key)` - open contact dialog;
* `phone:open_contact(id)` - open contact in the contacts app.

Contacts table format:

```
`id` - contact id;
`lookup_key` - unique contact identifier;
`name` - contact name;
`number` - contact number;
`icon` - contact icon in the form of a link (can be used in the side menu scripts).
```

If `phone:request_permission()` is called without a callback name, it calls `on_permission_granted()` after the user grants permission. If a callback name is supplied, the callback receives one boolean argument.

Upon the first launch of the application, contacts may not yet be loaded, so in the scripts, you can use the `on_contacts_loaded()` callback, which will be called after the contacts are fully loaded.

## Countries

* `countries:get(code)` - returns country by 2-letter ISO code (case-insensitive) or nil;
* `countries:get_by_alpha3(code)` - returns country by 3-letter ISO code or nil;
* `countries:get_by_name(name)` - returns first match by name (partial, case-insensitive) or nil;
* `countries:search(query)` - returns list of matching countries (sorted by name);
* `countries:by_region(region)` - returns list of countries in a region (sorted by name);
* `countries:by_dial_code(code)` - returns list of countries by dial code (e.g., "+1" or "1");
* `countries:regions()` - returns list of region names (sorted);
* `countries:count()` - returns total number of countries;
* `countries:all()` - returns full list of countries.

Country table format:

```
`name` - country name;
`alpha2` - 2-letter ISO code;
`alpha3` - 3-letter ISO code;
`country_code` - numeric country code;
`iso_3166` - ISO 3166-2 code;
`region` - region name;
`sub_region` - sub-region name;
`intermediate_region` - intermediate region name;
`region_code` - region code;
`sub_region_code` - sub-region code;
`intermediate_region_code` - intermediate region code;
`dial_code` - international dial code;
`geonameid` - GeoNames ID;
`capital` - capital city;
`currency` - currency name;
`language_codes` - comma-separated language codes;
`area_km2` - area in square kilometers;
`gdp` - GDP in USD;
`bounding_box` - table with bounding box coordinates.
```

Bounding box format:

```
`sw_lat` - southwest latitude;
`sw_lon` - southwest longitude;
`ne_lat` - northeast latitude;
`ne_lon` - northeast longitude.
```

Notes:

* Country codes are case-insensitive
* Search queries support partial matching
* All arrays are sorted by country name
* Empty strings are returned for missing optional fields
* The database contains 240+ countries and territories

## Tasks

_Available from: 4.8.0_

* `tasks:load()` - loads tasks;
* `tasks:add(task_table)` - adds the task described in the table;
* `tasks:remove(task_id)` - removes the task with the specified ID;
* `tasks:save(task_table)` - saves the task;
* `tasks:show_editor(task_id)` - shows the task editing dialog.

Once the tasks are loaded, the `on_tasks_loaded()` function will be executed.

The format of the task table:

```
`id` - task ID;
`text` - text;
`date` - date of creation;
`due_date` - deadline;
`completed_date` - task completion date;
`high_priority` - flag of high priority;
`notification` - flag of notification display;
`is_today` - is it today's task?
```

## Notes

_Available from: 4.8.0_

* `notes:load()` - loads notes;
* `notes:add(note_table)` - adds the note described in the table;
* `notes:remove(note_id)` - removes the note with the specified ID;
* `notes:save(note_table)` - saves the note;
* `notes:colors()` - returns a list of colors (index is the color ID);
* `notes:show_editor(note_id)` - shows the note editing dialog.

Once the notes are loaded, the `on_notes_loaded()` function will be executed.

The format of the note table:

```
`id` - note ID;
`text` - text;
`color` - note color ID;
`position` - note position on the screen.
```

## Timers

_Available from: 6.3.0_

* `timer:start(milliseconds)` - starts a timer for the specified duration in milliseconds;
* `timer:stop_all()` - stops all active timers;
* `timer:list()` - returns a table of timers;
* `timer:is_active()` - returns `true` if at least one timer is active.

Timer table format:

```
`total_ms` - timer duration in milliseconds;
`current_ms` - remaining time in milliseconds;
`active` - `true` if timer is running;
`auto_destroy` - `true` if timer will be removed automatically after finish.
```

`timer:start(...)` returns a status table:

```
`ok` - `true` on success, `false` on error;
`error` - error string when `ok` is `false` (for example: `invalid_duration`).
```

There is no API for stopping or deleting one specific timer from scripts. Use
`timer:stop_all()` when a script needs a stop action.

## Player

_Available from: 6.3.0_

* `player:state()` - returns current media player state;
* `player:has_permission()` - returns `true` if notification listener permission is granted;
* `player:open_permission_settings()` - opens Android notification listener settings;
* `player:play_pause()` - toggles play/pause;
* `player:next()` - skips to next track;
* `player:prev()` - skips to previous track;
* `player:stop()` - stops playback;
* `player:open_app()` - opens the current player application;
* `player:seek(seconds)` - seeks relative to the current position by the specified number of seconds;
* `player:seek_plus_15s()` - seeks forward by 15 seconds;
* `player:seek_minus_15s()` - seeks backward by 15 seconds;
* `player:custom_actions()` - returns available custom media actions;
* `player:custom_action(id)` - runs a custom media action by id;
* `player:can_like()` - returns `true` if the current player exposes a like action;
* `player:is_liked()` - returns `true` if the current media item is liked;
* `player:like()` - runs the player like action.

Player state table format:

```
`is_playing` - `true` if media is playing now;
`package` - package name of active player app (or empty string);
`song` - current track title (or empty string);
`custom_actions_count` - number of available custom media actions;
`can_like` - `true` if a like action is available;
`is_liked` - `true` if the current media item is liked.
```

Custom action table format:

```
`id` - action id, starting from 1;
`title` - action display title;
`action` - raw Android action string.
```

`player:seek()`, `player:custom_action()`, and `player:like()` return a status table:

```
`ok` - `true` on success, `false` on error;
`error` - error string when `ok` is `false` (for example: `action_not_found`, `unavailable`).
```

## Currencies

_Available from: 6.3.0_

* `currencies:supported()` - returns a list of supported currency codes (`"USD"`, `"EUR"`, etc.);
* `currencies:rate(from, to, [amount])` - returns converted amount or `nil` if rate is unavailable;
* `currencies:refresh([id])` - updates rates asynchronously.

`currencies:rate(...)` notes:

* `from` and `to` should be 3-letter currency codes;
* `amount` defaults to `1.0`;
* if rate is not found, function returns `nil`.

`currencies:refresh(...)` callback:

* without id: `on_currencies_result(result)`
* with id: `on_currencies_result_<id>(result)`

Result table format:

```
`ok` - `true` on success;
`updated_count` - number of loaded rates;
`last_update` - last update timestamp in seconds;
`error` - error message when `ok` is `false`.
```

## Finance

_Available from: 6.3.0_

* `finance:price(symbol)` - returns current ticker price as number or `nil` if unavailable;
* `finance:search(query, [id])` - searches symbols asynchronously;
* `finance:company(symbol, [id])` - loads company info asynchronously;
* `finance:chart(symbol, [id])` - loads chart data asynchronously.

Callbacks:

* `on_finance_search[_<id>](result)`
* `on_finance_company[_<id>](result)`
* `on_finance_chart[_<id>](result)`

Callback result format:

```
`ok` - `true` on success;
`data` - payload for search/company/chart;
`error` - error message when `ok` is `false`.
```

## Recorder

_Available from: 6.3.0_

* `recorder:request_permission([callback_name])` - requests microphone recording permission and optionally calls `callback_name(granted)`;
* `recorder:state()` - returns recorder state;
* `recorder:list()` - returns list of recordings;
* `recorder:start()` - starts recording;
* `recorder:stop_all()` - stops all active recordings;
* `recorder:stop_record(id)` - stops one active recording;
* `recorder:play(id)` - starts playback of a recording;
* `recorder:stop_play(id)` - stops playback of a recording;
* `recorder:delete(id)` - deletes a recording;
* `recorder:share(id)` - opens the system share sheet for a recording;
* `recorder:transcribe(id)` - transcribes a recording asynchronously;
* `recorder:rename(id, name)` - renames recording;
* `recorder:set_color(id, color)` - changes recording color.

Recorder state table format:

```
`has_permission` - `true` if microphone recording permission is granted;
`active` - `true` if recorder is active (recording or playing);
`records_count` - number of available records.
```

Recording item format:

```
`id` - recording id (string, based on start time);
`name` - display name;
`duration` - duration in milliseconds;
`recorded` - `true` if recording is completed;
`recording` - `true` if currently recording;
`playing` - `true` if currently playing;
`color` - color id/int.
```

Mutating methods (`start`, `stop_record`, `play`, `stop_play`, `delete`, `share`, `rename`, `set_color`) return status table:

```
`ok` - `true` on success;
`error` - error code/message when `ok` is `false` (for example: `permission_denied`, `record_not_found`).
```

`recorder:transcribe(id)` returns the result in this callback:

```lua
function on_recorder_transcription(id, text, error)
    if error then
        ui:show_toast("Transcription failed: " .. error)
    else
        ui:show_text(text)
    end
end
```

If `recorder:request_permission()` is called without a callback name, it calls `on_permission_granted()` after the user grants permission. If a callback name is supplied, the callback receives one boolean argument.

## News

_Available from: 7.1.1_

The `news` module loads the same regional and world news sources that are used by Today.

* `news:regional()` - loads regional news;
* `news:world()` - loads world news;
* `news:all()` - loads both regional and world news.

All three functions are asynchronous and return results in the same callback: `on_news_result(items)`.
The `items` table is sorted by date, newest first.

News item format:

```
`time` - Unix timestamp in seconds;
`title` - headline string;
`text` - summary/description string;
`url` - article URL string, can be nil;
`source` - localized source label;
`scope` - `"regional"` or `"world"`.
```

Example:

```
local rows = {}

function on_alarm()
    news:all()
end

function on_news_result(items)
    rows = {}
    local lines = {}

    if type(items) ~= "table" or #items == 0 then
        ui:show_text("No news")
        return
    end

    for _, item in ipairs(items) do
        local title = tostring(item.title or "")
        if title ~= "" then
            table.insert(lines, title)
            table.insert(rows, item)
        end
    end

    ui:show_lines(lines)
end

function on_click(index)
    local item = rows[index]
    if item and item.url then
        system:open_browser(item.url)
    end
end
```

## Weather

_Available from: 4.1.0_

* `weather:get_by_hour([id])` - performs hourly weather query and delivers the result to `on_weather_result(result)` or, when `id` is passed, to `on_weather_result_<id>(result)`;
* `weather:icon(icon_code, [is_day])` - returns an AIO weather icon id such as `weather:1:day` or `weather:1:night`. The optional `is_day` boolean controls day/night glyphs; when omitted, AIO uses the current day/night state.

Callbacks:

* `on_weather_result(result)` - result of `weather:get_by_hour()` calls without an id;
* `on_weather_result_<id>(result)` - result of `weather:get_by_hour(id)` calls with an id;

Hourly weather row format:

```
`time` - time in seconds;
`temp` - temperature in Celsius;
`icon_code` - code of weather icon;
`humidity` - humidity;
`pressure` - pressure;
`wind_speed` - wind speed;
`wind_direction` - wind direction;
`city` - city name.
```

Use `weather:icon()` to render `icon_code` with AIO's weather icon font:

```
function on_load()
    weather:get_by_hour("weather_demo")
end

function on_weather_result_weather_demo(result)
    if not result or #result == 0 then
        ui:show_text("No weather data")
        return
    end

    local hour = result[1]
    local icon = weather:icon(hour.icon_code)
    local temp = math.floor((hour.temp or 0) + 0.5) .. " C"
    ui:show_text("%%" .. icon .. "%% " .. temp)
end
```

In rich UI layouts, the returned icon id can also be used as an icon element:

```
{"icon", weather:icon(hour.icon_code), {size = 24}}
```

## Cloud

_Available from: 4.1.0_

* `cloud:get_metadata(path)` - returns a table with file metadata;
* `cloud:get_file(path)` - returns the contents of the file;
* `cloud:put_file(string, path)` - writes a string to the file;
* `cloud:remove_file(path)` - deletes file;
* `cloud:list_dir(path)` - returns metadata table of all files and subdirectories;
* `cloud:create_dir(path)` - creates directory;

All data are returned in `on_cloud_result(meta, content)`. The first argument is the metadata, either a metadata table (in the case of `list_dir()`) or an error message string. The second argument is the contents of the file (in the case of `get_file()`).

## Profiles

_Available from: 5.3.6._

* `profiles:list()` - returns a list of saved profiles;
* `profiles:dump(name)` - saves a new profile with the specified name;
* `profiles:restore(name)` - restores the saved profile;
* `profiles:remove(name)` - removes a saved profile and returns `true` on success;
* `profiles:dump_json()` - creates a new profile but instead of saving it, returns it as a JSON string;
* `profiles:restore_json(json)` - restores a profile previously saved using `dump_json()`;
* `profiles:current()` - returns current profile name.

## AI

_Available from: 5.3.5._

_Requires subscription._

* `ai:complete(text, [id])` - send message to the AI. If `id` is supplied, the result is returned with the same request id in `on_ai_result(id, text, error)`;
* `ai:translate(text, lang)` - translate text to the language with code `lang` (`en`, `de`, `es` etc);
* `ai:transcribe(uri, [file_name], [id])` - transcribe an audio file by `content://` or `file://` URI. The optional `file_name` helps AIO detect the audio type (`.m4a`, `.3gp`, `.mp3`, `.wav`). If `id` is supplied, the result is returned with the same request id in `on_ai_result(id, text, error)`.

When `ai:complete()` is called without `id`, and when `ai:translate()` is used, the answer is returned in the legacy callback `on_ai_answer`. For example:

```
function on_alarm()
    ai:complete("Who are you?")
end

function on_ai_answer(answer)
    ui:show_text(answer)
end
```

The request-id based functions return the result in `on_ai_result(id, text, error)`. `text` is `nil` on failure, and `error` is a string error code or message.

```
function on_alarm()
    ai:complete("Summarize today's notifications in one sentence", "summary")
end

function on_ai_result(id, text, error)
    if error then
        ui:show_text("AI error: " .. error)
        return
    end

    ui:show_text(text)
end
```

To transcribe an audio file selected by the user:

```
function on_load()
    files:pick_file("audio/*")
end

function on_file_picked(uri, name)
    ai:transcribe(uri, name, "voice")
end

function on_ai_result(id, text, error)
    if id ~= "voice" then return end
    ui:show_text(error or text)
end
```

_Keep in mind that the launcher imposes certain limitations on the use of this module. If you use it too frequently, the legacy callback will receive `error: rate limit`, and `on_ai_result()` will receive `rate limit` in its `error` argument. Additionally, an error will be returned if the request includes too much text or the audio file is too large._

## Reading notifications

_Available only in widget scripts._

_Available from: 4.1.3._

_This module is intended for reading notifications from other applications. To send notifications, use the `system` module._

* `notify:list()` - returns list of current notifications as table of tables;
* `notify:has_permission()` - returns `true` if notification listener permission is granted;
* `notify:open_permission_settings()` - opens Android notification listener settings;
* `notify:open(key)` - opens notification with specified key;
* `notify:close(key)` - removes the notification with the specified key;
* `notify:snooze(key, millis)` - snoozes the notification;
* `notify:do_action(key, action_id)` - sends notification action (_available from: 4.1.5_);
* `notify:reply(key, action_id, text)` - sends text to a notification action with remote input and returns a status table.

The launcher triggers callback when a notification is received or removed:

* `on_notifications_updated()` - notification list changed;

Notification table format:

```
`key` - a key uniquely identifying the notification;
`time` - time of notification publication in seconds;
`package` - name of the application package that sent the notification;
`number` - the number on the notification badge, if any;
`importance` - notification importance level: from 1 (low) to 4 (high), 3 - standard;
`category` - notification category, for example `email`;
`title` - notification title;
`text` - notification text;
`sub_text` - additional notification text;
`info_text` - notification info text;
`summary_text` - notification summary text;
`big_text` - extended notification text;
`is_clearable` - true, if the notification is clearable;
`group_id` - notification group ID;
`messages` - table of tables with fields: `sender`, `text`, `time` (_available from: 4.1.5_);
`actions` - table notifications actions with fields: `id`, `title`, `have_input` (_available from: 4.1.5_);
```

Use `action.id` from the notification action table as `action_id` for `notify:do_action()` and `notify:reply()`.

`notify:reply()` returns a status table:

```
`ok` - `true` on success, `false` on error;
`error` - error string when `ok` is `false` (for example: `notification_not_found`, `remote_input_not_found`).
```

Keep in mind that the AIO Launcher also request current notifications every time you return to the launcher, which means that all scripts will also get the `on_notifications_updated()` callback called.

## Files

*Available from: 4.1.3*

* `files:read(name)` - returns file contents or `nil` if the file does not exist;
* `files:write(name, string)` - writes a string to a file (creates it if needed);
* `files:delete(name)` - deletes the file;
* `files:list()` - returns a table of script files;
* `files:stat(name)` - returns metadata for a script file.

All files created by scripts are stored in:

```
/sdcard/Android/data/ru.execbit.aiolauncher/files/scripts
```

Subdirectories are not supported. Slashes in file names are stripped to the last path component.

File metadata table format:

```
`name` - file name;
`size` - file size in bytes, or 0 if it does not exist;
`last_modified` - last modification time as Unix time in seconds, or 0 if it does not exist;
`is_dir` - `true` if the file is a directory;
`exists` - `true` if the file exists, only returned by `files:stat()`.
```

## External files

*Available from: 6.0.2*

Scripts may request a system file picker:

* `files:pick_file([mime])` - opens the picker (e.g. `"image/*"`, `"text/*"`, `"*/*"`);
* `files:create_file([mime], [name])` - opens the system create-file dialog;
* `files:read_uri(uri)` - reads text from a file referenced by a content URI;
* `files:write_uri(uri, string)` - writes text to a file referenced by a content URI.

`pick_file` and `create_file` share one system result channel. Only one script can
have an active request at a time. A successful launch returns `nil`. A concurrent
request returns `"file_picker_busy"` without replacing the active script's
callback; `"file_picker_unavailable"` means that the picker could not be opened.

After the user selects a file, the callback is invoked:

```
on_file_picked(uri, name)
```

After the user creates a file, the callback is invoked:

```
on_file_created(uri, name)
```

Callback parameters:

* `uri` - Android content URI of the selected or created file.
* `name` - display name returned by the system.

If the user dismisses the picker, the corresponding callback is still invoked
with `uri == nil` and an empty `name`.

Example:

```lua
files:pick_file("text/*")

function on_file_picked(uri, name)
    local content = files:read_uri(uri)
    ui:show_text(content or "Cannot read file: " .. name)
end

function export_text()
    files:create_file("text/plain", "aio-export.txt")
end

function on_file_created(uri, name)
    files:write_uri(uri, "Hello from AIO Launcher")
end
```

## Rich UI

Starting with version 5.2.1, AIO Launcher includes an API that allows for displaying a more complex interface than what the high-level functions of the `ui` module allowed. For example, you can display text of any size, center it, move it up and down, display buttons on the left and right sides of the screen, draw icons of different sizes, and much more. Essentially, you can replicate the appearance of any built-in AIO widget.

[Detailed instructions](README_RICH_UI.md)

## App widgets

Starting from version 5.2.0, AIO Launcher supports interaction with app widgets through scripts. This means that you can create a wrapper for any app's widget that will fully match the appearance and style of AIO. You can also use this API if you need to retrieve information from other applications, such as the balance on your mobile phone account or your car's parking spot. If the application has a widget providing such information, you will be able to access it.

[Detailed instructions](README_APP_WIDGETS.md)

## Settings

_Deprecated in 4.7.4. Use Preferences module._

* ~~`settings:get()` - returns the settings table in an array of words format;~~
* ~~`settings:set(table)` - saves the settings table in an array of words format;~~
* ~~`settings:get_kv()` - returns the settings table in `key=value` format;~~
* ~~`settings:set_kv(table)` - saves settings table in the format `key=value`;~~
* ~~`settings:show_dialog()` - show settings change dialog.~~

~~User can change settings through the dialog, which is available by clicking on the "gear" in the edit menu of the widget. If in the widget metadata there is a field `arguments_help`, its value will be shown in the edit dialog. If there is a field `arguments_default` - it will be used to get default arguments.~~

~~The standard edit dialog can be replaced by your own if you implement the `on_settings()` function.~~

## Preferences

The `prefs` module is designed to permanently store the script settings. It is a simple Lua table which saves to disk all the data written to it.

You can use it just like any other table with the exception that it cannot be used as a raw array.

Sample:

```
prefs = require "prefs"

function on_load()
  if prefs.foo == nil then prefs.foo = "bar" end
end

function on_resume()
    prefs.new_key = "Hello"
    ui:show_lines{prefs.new_key}
end
```

The `new_key` will be present in the table even after the AIO Launcher has been restarted.

The `show_dialog()` method automatically creates a window of current settings from fields defined in prefs. The window will display all fields with a text key and a value of one of three types: string, number, or boolean. All other fields of different types will be omitted. Fields whose names start with an underscore will also be omitted. Script will be reloaded on settings save.

Starting from version 5.5.2, you can change the order of fields in the dialog by simply specifying the order in `prefs._dialog_order`. For example:

```
prefs._dialog_order = "message,start_time,end_time"
```

Note: the `prefs` module is intended for storing settings as key-value pairs. For storing data, it’s better to use direct file saving through the `files` module.

## Animation and real time updates

_Available only in widget scripts._

_Available from: 4.5.2_

The scripts API is designed in a way that every function that changes a widget's UI updates the entire interface. This approach makes the API as simple and convenient as possible for quick scripting, but it also prevents the creation of more complex scripts that change the UI state very often.

There are two modules to solve this problem: `morph` and `anim`. The first is used to change individual UI elements, the second is used to animate those elements.

* `morph:change_text(idx, text, [duration])` - changes element text with number `idx`, `duration` - animation duration in milliseconds;
* `morph:change_text_seq(idx, table, delay)` - sequentially changes text of element with number `idx`, `table` - table of lines which will be sequentially assigned to element with delay `delay`;
* `morph:change_outer_color(idx, color)` - changes "external" color (for example, button color) of element with index `idx`, `color` - color in format #XXXXXX;
* `morph:run_with_delay(delay, function)` - populates specified Lua function with delay `delay`;
* `morph:cancel(idx)` - cancels a previously run change if it is not yet complete (e.g., delay or animation is not over).
* `anim:blink(idx)` - blinks UI element with index `idx`;
* `anim:move(idx, x, y, [delay])` - moves element sideways by specified number of DP and returns back after delay;
* `anim:heartbeat(idx)` - animation of heartbeat;
* `anim:shake(idx)` - shake animation;
* `anim:cancel(idx)` - cancel the running animation.

## Functions

_Available from: 4.1.3_

* `utils:md5(string)` - returns md5-hash of string (array of bytes);
* `utils:sha256(string)` - returns sha256-hash of string (array of bytes);
* `utils:base64encode(string)` - returns base64 representation of string (array of bytes);
* `utils:base64decode(string)` - decodes base64 string;

## Tasker

_Available from: 4.4.4_

* `tasker:tasks([project])` - returns a list of all the tasks in the Tasker, the second optional argument is the project for which you want to get the tasks (returns nil if Tasker is not installed or enabled);
* `tasker:projects()` - returns all Tasker projects (returns nil if Tasker is not installed or enabled);
* `tasker:run_task(name, [args])` - executes the task in the Tasker, the second optional argument is a table of variables passed to the task in the format `{ name = "value" }`;
* `tasker:run_own_task(commands)` - constructs and performs the task on the fly;
* `tasker:send_command(command)` - sends [tasker command](https://tasker.joaoapps.com/commandsystem.html).

The `run_own_task` function takes as a parameter a list of Tasker commands in the following format:

```
COMMAND1 ARG1 ARG2 ARG3 ...;
COMMAND2 ARG2 ARG2 ARG3 ...;
...
```

The command itself can be specified either as a command ID or as a name (names can be found [here](https://tasker.joaoapps.com/code/ActionCodes.java)). Unfortunately Tasker has no formal documentation on these commands, so you will have to rely on examples in this repository and Google search.

After task is done, the `on_tasker_result(boolean)` function will be called with the result of the command (successful or not).

If you want to pass data from the task to the script, you can use the broadcast intent `ru.execbit.aiolauncher.COMMAND` by adding the following line to the extra:

```
cmd:script:SCRIPT_FILE_NAME:DATA_STRING
```

Here `SCRIPT_FILE_NAME` is the name of the script or `*` if you want to pass data to all scripts. The `DATA_STRING` is the string with the data.

On the script side, you can accept this data in the `on_command(string)` callback.

**Note**: for these APIs to work you need to enable external control in Tasker: Tasker -> Preferences -> Misc -> Allow External Access. Also you need to enable external control of the launcher itself: AIO Settings -> Tasker -> Remote API.

## Other

AIO Launcher includes the LuaJ 3.0.1 interpreter (compatible with Lua 5.2) with a standard set of modules: `bit32`, `coroutine`, `math`, `os`, `string`, `table`.

The modules `io` and `package` are excluded from the distribution for security reasons, the module `os` has been cut in functionality. Only the following functions are available: `os.clock()`, `os.date()`, `os.difftime()` and `os.time()`.

The standard Lua API is extended with the following features:

* `string:split(delimeter)` - splits the string using the specified delimiter and returns a table;
* `string:replace(regexp, string)` - replaces the text found by the regular expression with another text;
* `string:trim()` - removes leading and trailing spaces from the string;
* `string:starts_with(substring)` - returns true if the string starts with the specified substring;
* `string:ends_with(substring)` - returns true if the string ends with the specified substring;
* `string:contains(substring)` - returns true if the string contains the specified literal substring; the substring is not treated as a Lua pattern;
* `slice(table, start, end)` - returns the part of the table starting with the `start` index and ending with `end` index;
* `index(table, value)` - returns the index of the table element;
* `key(table, value)` - returns the key of the table element;
* `concat(table1, table2)` - adds elements from array table `table2` to `table1`;
* `reverse(table)` - returns a table in which the elements follow in reverse order;
* `serialize(table)` - serializes the table into executable Lua code;
* `round(x, n)` - rounds the number;
* `map(function, table)`, `filter(function, table)`, `head(table)`, `tail(table)`, `reduce(function, table)` - several convenience functional utilities form Haskell, Python etc.

The method table used by receiver calls such as `text:trim()` is launcher-owned and protected. Each script still has its own `string` table, but assigning `string.custom_method` or declaring `function string:custom_method()` affects only that table and does not add a receiver method. Define custom helpers as local functions instead. The built-in string extensions listed above remain available through receiver calls.

AIO Launcher also includes:

* [md_colors](lib/md_colors.lua) - Material Design color table module ([help](https://materialui.co/colors));
* [url](lib/url.lua) - functions for encoding/decoding URLs from the Lua Penlight library;
* [html](lib/html.lua) - HTML parser;
* [fmt](lib/fmt.lua) - HTML formatting module;
* [utf8](https://gist.github.com/Stepets/3b4dbaf5e6e6a60f3862) - UTF-8 module from Lua 5.3;
* [json.lua](https://github.com/rxi/json.lua) - JSON parser;
* [csv.lua](lib/csv.lua) - CSV parser;
* [Lua-Simple-XML-Parser](https://github.com/Cluain/Lua-Simple-XML-Parser) - XML parser (see example `xml-test.lua`).
* [luaDate](https://github.com/Tieske/date) - time functions;
* [LuaFun](https://github.com/luafun/luafun) - high-performance functional programming library for Lua;
* [checks](lib/checks.lua) - check the types of function arguments;

# Metadata

In order for AIO Launcher to correctly display information about the script in the script directory and correctly display the title, you must add metadata to the beginning of the script. For example:

```
-- name = "Covid info"
-- icon = "fontawesome_icon_name"
-- description = "Cases of illness and death from covid"
-- data_source = "https://covid19api.com"
-- type = "widget"
-- foldable = "true"
-- private_mode = "false"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
```

# Backward compatibiliy

AIO Launcher mantains backward compatibility with existing APIs. But if you want to use API functions which appeared later than 4.0.0 you'd better use a special meta tag which will hide your script on all previous versions of the application.

For example, let's say you want to use the `weather` module that appeared in version 4.1.3. In this case, add the following line to the script's metadata:

```
-- aio_version = "4.1.3"
```

You can also check the presence of a particular API function this way (note the use of a dot instead of a colon):

```
if ui.show_list_dialog then
    ui:show_text("list dialog is supported")
else
    ui:show_text("list dialog is not supported")
end

```

# Debugging

Some tips on writing and debugging scripts:

* Use `./manage-scripts.sh install SCRIPT` and `./manage-scripts.sh remove SCRIPT` to manage one script through ADB. The `install-all` command replaces the installed set with all configured repositories, while `remove-all` removes it. Pass `-s SERIAL` before the command when more than one device is connected.
* When you change the script, it will be automatically reloaded when you return to the desktop. The search scripts will be reloaded automatically next time you open the search window.
* Since version 4.4.2 AIO Launcher includes `debug` module with methods: `debug:log(text)`, `debug:toast(text)` and `debug:dialog(text)`;
* Since version 4.8.0 you can use `--testing = "true"` meta tag. In this case, launcher will gray out the script and place it at the end of the list in the side menu.

# Contribution

If you want your scripts to be included in the repository and the official AIO Launcher kit - create a pull request or email me: zobnin@gmail.com. Also I am always ready to answer your questions and discuss extending the current API.
