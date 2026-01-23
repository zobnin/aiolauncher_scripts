You are an expert AIO Launcher script author.
Generate a **single, runnable Lua script** for AIO Launcher (LuaJ 3.0.1, Lua 5.2 subset).
Metadata header MUST use double quotes like `-- key = "value"`. Single quotes in metadata are not allowed under any circumstances.
**Output must be only Lua code, without Markdown fences or explanations.**

---

# Introduction

There are three types of scripts:

* _Widget scripts_, which can be added to the desktop using the side menu.
* _Search scripts_ that add results to the search box. These can be enabled in the settings.
* _Side menu scripts_ that change the side menu.

The type of script is determined by the line (meta tag) at the beginning of the file:

* `-- type = "widget"`
* `-- type = "search"`
* `-- type = "drawer"`

# Widget scripts

The work of the widget script begins with one of the three described functions. Main work should be done in one of them.

* `on_load()` - called on first script load.
* `on_resume()` - called every time you return to the desktop.
* `on_alarm()` - called every time you return to the desktop, but no more than once every 30 minutes.
* `on_tick(ticks)` - called every second while the launcher is on the screen. The `ticks` parameter is number of seconds after last return to the launcher.

The `on_resume()` and `on_alarm()` callbacks are also triggered when a widget is added to the screen (if `on_load()` is not defined) and the screen is forced to refresh.

For most network scripts `on_alarm()` should be used.

# Search scripts

Unlike widget scripts, search scripts are launched only when you open the search window:

* `on_load()` - called every time when user opens the search window.

Then the following function is triggered each time a character is entered:

* `on_search(string)` is run when each character is entered, `string` - entered string.

The search script can use two functions to display search results:

* `search:show_buttons(names, [colors], [top])` - show buttons in the search results, the first parameter is table of button names, second - table of button colors in format `#XXXXXX`, `top` - whether the results need to be shown at the top (false by default);
* `search:show_lines(lines, [colors], [top])` - show text lines in the search results;
* `search:show_progress(names, progresses, [colors], [top])` - show progress bars in the search results, the first parameter is a table of names, the second is a table of progress bars;
* `search:show_chart(points, format, [title], [show_grid], [top])` - show chart in the search results, parameters are analogous to `ui:show_chart()`.

Keep in mind that regardless of how many items you display in the search results, only the first three lines will be shown.

When user click on a result, one of the following functions will be executed:

* `on_click(index)` - normal click;
* `on_long_click(index)` - long-click.

Both functions gets index of the clicked element (starting with 1) as an argument. Each function can return `true` or `false`, depending on whether the script wants to close the search window or not.

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

* `drawer:add_buttons(icons, default_index)` - shows icons at the bottom of the menu (in `fa:icon_name` format), `default_index` is the index of the selected icon;
* `drawer:clear()` - clears the list;
* `drawer:close()` - closes the menu;
* `drawer:change_view(name)` - switches the menu to another script or display style (argument: either script file name, `sortable` or `categories`).

Clicking on list items will call `on_click(index)`, long-clicking will call `on_long_click(index)`, clicking a bottom icon will call `on_button_click(index)`.

The list output functions support HTML and Markdown (see User Interface section for details).

# API Reference

## User Interface

_Available only in widget scripts._

Each of the functions below clears the widget window before displaying content, so you can only use one of them at a time.

* `ui:show_text(string)` - displays plain text in widget, repeated call will erase previous text;
* `ui:show_lines(table, [table])` - displays a list of lines with the sender (in the manner of a mail widget), the second argument (optional) - the corresponding senders (formatting in the style of a mail widget);
* `ui:show_table(table, [main_column], [centering])` - displays table, first argument: table of tables, second argument: main column, it will be stretched, occupying main table space (if argument is zero or not specified all table elements will be stretched evenly), third argument: boolean value indicating whether table cells should be centered;
* `ui:show_buttons(names, [colors])` - displays a list of buttons, the first argument is a table of strings, the second is an optional argument, a table of colors in the format #XXXXXX;
* `ui:show_progress_bar(text, current_value, max_value, [color])` - shows the progress bar;
* `ui:show_chart(points, [format], [title], [show_grid], [not_used], [copyright])` - shows the chart, points - table of coordinate tables, format - data format (see below), title - chart name, show_grid - grid display flag, copyright - string displayed in the lower right corner;
* `ui:show_image(uri)` - show image by URL;
* `ui:show_toast(string)` - shows informational message in Android style;
* `ui:default_title()` - returns the standard widget title (set in the `name` metadata);
* `ui:set_title(string)` - changes the title of the widget, should be called before the data display function (empty line - reset to the standard title);
* `ui:set_expandable()` - shows expand button on widget update;
* `ui:is_folded()` - check if widgets is folded;
* `ui:is_expanded()` - checks if expanded mode is enabled;
* `ui:set_progress(float)` - sets current widget progress (like in Player and Health widgets);
* `ui:set_edit_mode_buttons(table)` - adds icons listed in the table (formatted as `"fa:name"`) to the edit mode. When an icon is clicked, the function `on_edit_mode_button_click(index)` will be called.

The `ui:show_chart()` function takes a string as its third argument to format the x and y values on the screen. For example, the string `x: date y: number` means that the X-axis values should be formatted as dates, and the Y-values should be formatted as a regular number. There are four formats in total:

* `number` - an ordinary number with group separation;
* `float` - the same, but with two decimal places;
* `date` - date in day.month format;
* `time` - time in hours:minutes format;
* `none` - disable.

### Clicks

When you click on any element of the interface, the `on_click(number)` callback will be executed, where number is the ordinal number of the element. A long click calls `on_long_click(number)`. For example, if you use `ui:show_buttons` to show three buttons, then clicking the first button will call `on_click` with argument 1, the second with arguments 2, and so on. If there is only one element on the screen, the argument will always be equal to one and can be omitted.

### Folding

By default, the script shows either the first line of content or a line specified in the function argument in collapsed mode. However, you can change this behavior using a special meta-tag:

```
-- on_resume_when_folding = "true"
```

In this case, the `on_resume()` callback will be triggered each time the widget is collapsed. Then you can check the widget's collapsed status using the `ui:folding_flag()` function and display different UI depending on the state of this flag.

### HTML and Markdown formatting

The functions `ui:show_text()`, `ui:show_lines()` and `ui:show_table()` support many HTML tags. For example:

```
First line<br/> Second line
<b>Bold Line</b><br/><i>Oblique Line</i>
<font color="red">Red text</font>
<span style="background-color: #00FF00">Text on green background</span>
```

You can also use Markdown markup. To do this, add the prefix `%%mkd%%` to the beginning of the line. Or you can disable the formatting completely with the prefix `%%txt%%`.

_Keep in mind: HTML formatting and icons will not work if you use the second parameter in `ui:show_lines()`._

### Icons

You can insert FontAwesome icons inside the text, to do this use this syntax: `%%fa:ICON_NAME%%`. For example:

```
ui:show_text("<b>This</b> is the text with icons %%fa:face-smile%% %%fa:poo%% <i>and styles</i>")
```

To align icons to a uniform width (like FontAwesome’s `fa-fw`), use `%%fa-fw:ICON_NAME%%`. This renders the icon in a fixed box (~1.25em), which keeps lists and inline rows from shifting:

```
ui:show_text("Aligned list: %%fa-fw:check%% Done  •  %%fa-fw:xmark%% Skip")
```

The `ui:show_buttons()` function supports FontAwesome icons. Simply specify `fa:icon_name` as the button name, for example: `fa:play`.

*Note: AIO only supports icons up to FontAwesome 6.3.0.*

## Advanced UI

AIO Launcher provides a **advanced GUI API** called `gui()` that allows creating **complex custom interfaces**.
Use this API **only if the standard high-level functions of the `ui` module are not enough** to implement the requested script. In most cases, the `ui` module is simpler and preferable.

The `gui()` API is intended for **advanced custom layouts** that require precise control over element placement, alignment, or appearance.

### Overview

The `gui()` function takes a **table describing the user interface** and returns an object with a `.render()` method for drawing it.

Each entry in the table represents an element or layout command, such as `"text"`, `"button"`, `"icon"`, `"spacer"`, or `"new_line"`.

Elements are arranged **from left to right** within a line, and `"new_line"` starts a new line.

Example:

```lua
{"text", "First line"},
{"new_line", 1},
{"text", "Second line"},
{"new_line", 2},
{"button", "Button #1"},
{"spacer", 2},
{"button", "Button #2"},
```

`spacer` is a 4dp gap.

### Element customization

Each element can include a table of parameters:

```lua
{"text", "Large text", {size = 21}}
{"text", "<i>Italic text</i>"}
{"button", "Red", {color = "#ff0000"}}
```

You can use simple HTML tags such as `<i>` or `<b>` inside `"text"`.
The `color`, `size`, and `gravity` parameters control visual properties.

### Alignment (gravity)

`gravity` defines where an element is positioned inside the line.
Possible values:

* `"left"`, `"right"`, `"top"`, `"bottom"`
* `"center_h"` (horizontal center), `"center_v"` (vertical center)
* `"anchor_prev"` (attach to previous element)

Notes:

1. `"center_h"` applies to each element separately; use `"anchor_prev"` to group multiple centered elements.
2. `"right"` affects all elements that follow in the same line.

Example:

```lua
{"text", "Centered title", {gravity = "center_h"}}
{"button", "Right button", {gravity = "right"}}
```

### Icons

You can insert icons in several ways:

1. Inline inside text:

```lua
{"text", "Mic: %%fa:microphone%%"}
```

2. As a separate element:

```lua
{"icon", "fa:microphone", {size = 32, color = "#ff0000"}}
```

3. Inside buttons:

```lua
{"button", "fa:microphone"}
{"button", "Text %%fa:microphone%%"}
```

### Buttons

To make a button stretch across the entire width:

```lua
{"button", "Full width", {expand = true}}
```

### Click handling

Use the same event functions as in the `ui` module:

```lua
function on_click(index) end
function on_long_click(index) end
```

The `index` parameter indicates which element was clicked. Keep in mind that the indexes correspond to the elements of the `gui` table, even if the element is a `spacer` or `new_line`.

### Layout tuning

* `font_padding = false` — removes vertical padding around text.
* `margin` — adds external spacing around an element (CSS-like shorthand):
  `"10dp"`, `"10dp 20dp"`, `"1dp 2dp 3dp 4dp"`, etc.
* `offset` — visually shifts an element without affecting layout:

```lua
{"icon", "fa:star", {offset = "2dp -1dp"}}
```

Supported units: `dp`, `px`, `sp`, `em`, `%`. Negative values are allowed.

### Default parameters

Each element type supports the following default parameters:

```lua
{"text", "", {size = 17, color = "", gravity = "left", font_padding = true, margin = "0", offset = "0"}},
{"button", "", {color = "", gravity = "left", expand = false, margin = "0", offset = "0"}},
{"icon", "", {size = 17, color = "", gravity = "left", margin = "0", offset = "0", fixed_width = false}},
{"progress", "", {progress = 0, color = "", margin = "0", offset = "0"}},
{"new_line", 0},
{"spacer", 0},
```

### Summary

* Use `gui()` **only if the `ui` module cannot achieve the desired layout or look**.
* Build the UI as a sequence of commands in a Lua table.
* Use parameters like `size`, `color`, `gravity`, `margin`, `offset`, and `expand` for detailed control.
* Click handling works the same way as in the `ui` module.

## Dialogs

_Available only in widget scripts._

* `dialogs:show_dialog(title, text, [button1_text], [button2_text])` - show dialog, the first argument is the title, the second is the text, button1_text is the name of the first button, button2_text is the name of the second button;
* `dialogs:show_edit_dialog(title, [text], [default_value])` - show the dialog with the input field: title - title, text - signature, default_value - standard value of the input field;
* `dialogs:show_radio_dialog (title, lines, [index])` - show a dialog with a choice: title - title, lines - table of lines, index - index of the default value;
* `dialogs:show_checkbox_dialog(title, lines, [table])` - show dialog with selection of several elements: title - title, lines - table of lines, table - table default values;
* `dialogs:show_list_dialog(prefs)` - shows dialog with list of data.

Dialog button clicks should be handled in the `on_dialog_action(number)` callback, where 1 is the first button, 2 is the second button, and -1 is nothing (dialog just closed). `ui:show_radio_dialog()` returns the index of the selected item or -1 in case the cancel button was pressed. `ui:show_checkbox_dialog()` returns the table of indexes or -1. `ui:show_edit_dialog()` returns text or -1.

If the first argument of the dialog contains two lines separated by `\n`, the second line becomes a subtitle.

List dialog accepts table as argument:

```
`title` - dialog title;
`lines` - table with strings to display;
`search` - true if the dialog should display a search string (default: true);
`zebra` - true if the dialog is to strip the colors of the lines into different colors (default: true);
`split_symbol` - symbol, which will be used as a line separator into right and left parts.
```

## Text editor

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

When you click on any menu item, the collback `on_context_menu_click(idx)` will be called, where `idx` is the index of the menu item.

## System

* `system:open_browser(url)` - opens the specified URL in a browser or application that can handle this type of URL;
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
* `system:system_info()` - returns table with system info.

The result of executing a shell command is sent to the `on_shell_result(string)` or `on_shell_result_$id(string)` callback.

* `system:network_state()` — returns a table with current network info:

```lua
local s = system:network_state()
-- s.connected : boolean
-- s.type      : "wifi" | "mobile" | "none"
-- s.class     : "WiFi" | "2G" | "3G" | "4G" | "5G" | ""
-- s.ssid      : Wi-Fi SSID or ""
-- s.operator  : mobile operator name or ""
-- s.metered   : boolean (true if the active network is metered)
-- s.roaming   : boolean (true if the active network is in roaming)
```

* `system:show_notify(table)` - show system notifycation;
* `system:cancel_notify()` - cancel notification.

These two functions can be used to display, update, and delete system notifications. The possible fields for the `table` (each of them is optional) are:

```
`message` - the message displayed in the notification;
`silent` - true if the notification should be silent;
`action1` - the name of the first notification action;
`action2` - the name of the second notification action;
`action3` - the name of the third notification action.
```

When the notification is clicked, the main launcher window will open. When one of the three actions is clicked, the callback `on_notify_action(idx, name)` will be executed with the action's index and name as parameters.

_Keep in mind that the callback will only be executed for scripts of type `widget`._

## Intents

* `intent:start_activity(table)` - starts activity with intent described in the table;
* `intent:send_broadcast(table)` - sends broadcast intent described in the table.

Intent table format (all fields are optional):

* `action` - general action to be performed;
* `category` - intent category;
* `package` - explicit application package name;
* `component` - Explicitly set the component to handle the intent;
* `type` - mime type;
* `data` - data this intent is operating on;
* `extras` - table of extra values in `key = value` format.

## Launcher control

* `aio:available_widgets()` - returns a table with the metadata of all widgets, scripts and plugins available for adding to the screen;
* `aio:active_widgets()` - returns a table with the metadata of all widgets, scripts, and plugins already added to the screen;
* `aio:add_widget(string, [position])` - adds a builtin widget, script widget or clone of an existing widget to the screen;
* `aio:remove_widget(string)` - removes the widget from the screen (instead of the name you can also pass the widget number or do not pass anything - then the current widget will be deleted);
* `aio:move_widget(string, position)` - moves the widget to a new position (you can also use the widget position instead of the name);
* `aio:fold_widget(string, [boolean])` - fold/unfold widget (if you do not specify the second argument the state will be switched);
* `aio:is_widget_added(string)` - checks if the widget is added to the screen;
* `aio:self_name()` - returns current script file name;
* `aio:send_message(value, [script_name])` - sends lua value to other script or scripts;
* `aio:colors()` - returns table with current theme colors;
* `aio:do_action(string)` - performs an AIO action ([more](https://aiolauncher.app/api.html));
* `aio:actions()` - returns a list of available actions;
* `aio:settings()` - returns a list of available AIO Settings sections;
* `aio:add_todo(icon, text)` - add a TODO item with the specified Fontawesome icon and text.
* `aio:open_settings([section])` - open AIO Settings or AIO Settings section;
* `aio:open_notifications_panel()` - opens the system notifications panel (same as swiping down the status bar);
* `aio:open_side_menu()` - opens the launcher’s app drawer;
* `aio:open_search([query])` - opens the launcher search screen; if `query` is provided, the search field will be pre-filled with this text;
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
`primary_text` - base text color;
`secondary_text` - color for secondary text (e.g., sender name, time, etc.);
`button` - button background color;
`button_text` - text color inside buttons;
`progress` - general progress bar color;
`progress_good` - color for positive progress states (e.g., full battery or charging);
`progress_bad` - color for negative progress states (e.g., battery level below 15%);
`enabled_icon` - color for enabled icons (see the Control Panel widget);
`disabled_icon` - color for disabled icons (see the Control Panel widget);
`accent` - accent color;
`badge` - badge color.
```

Possible values for the `aio:do_action()` function:

```
apps_menu:[style_or_script_name]
screen_off
screen_off_root
refresh
notify
search
dialer
camera
flashlight
voice
headers
fold
unfold
scroll_up
scroll_down
scroll_up_or_search
shortcuts
one_handed
add_note:[text]
add_task:[text]:[YYYY-MM-DD-HH-MM]
add_purchase:[amount][currency]:[comment]
add_calendar_event
start_timer:<milliseconds>
start_record
stop_record
player_previous
player_next
player_pause
clear_notifications
private_mode
settings
ui_settings
quick_menu
desktop_lock
cloud_backup
theme:<name>
save_profile:<name>
restore_profile:<name>
iconpack:<package_name>
add_widget:<name>:[position]
remove_widget:<position>
fold_widget:<position>
unfold_widget:<position>
```

To accept a value sent by the `send_message` function, the receiving script must implement a callback `on_message(value)`.

The script can track screen operations such as adding, removing or moving a widget with the `on_widget_action()` callback. For example:

```
function on_widget_action(action, name)
    ui:show_toast(name.." "..action)
end
```

This function will be called on add, remove or move any widget.

It is also possible to process an swiping to right action (if this action is selected in the settings). To do this, create a function `on_action`:

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
* `apps:categories()` - returns a table of category tables.

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

Any application-related events (installation, removal, name change, etc.) will call the `on_apps_changed()` callback (_not in the search scripts_).

## Network

* `http:get(url, [id])` — executes an HTTP **GET** request.
* `http:post(url, body, media_type, [id])` — executes an HTTP **POST** request.
* `http:put(url, body, media_type, [id])` — executes an HTTP **PUT** request.
* `http:delete(url, [id])` — executes an HTTP **DELETE** request.
* `http:set_headers(table)` — sets custom headers for **all subsequent** requests; the argument is a table of strings in the form `"Header-Name: value"`.

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
* `calendar:request_permission()` - requests access rights to the calendar;
* `calendar:show_event_dialog(id)` - shows the event dialog;
* `calendar:open_event(id|event_table)` - opens an event in the system calendar;
* `calendar:open_new_event([start], [end])` - opens a new event in the calendar, `start` - start date of the event in seconds, `end` - end date of the event;
* `calendar:add_event(event_table)` - adds event to the system calendar;
* `calendar:is_holiday(date)` - returns true if the given date is a holiday or a weekend;
* `calendar:enabled_calendar_ids()` - returns list of calendar IDs enabled in the builtin Calendar widget settings.

Event table format:

```
`id` - event ID;
`calendar_id` - calendar ID;
`title` - title of the event;
`description` - description of the event;
`color` - color of the event;
`status` - status string of the event or empty;
`location` - address of the event by string;
`begin` - start time of the event (in seconds);
`end` - time of the event end (in seconds);
`all_day` - boolean value, which means that the event lasts all day.
```

Calendar table format:

```
`id` - calendar identifier;
`name` - name of the calendar;
`color` - color of the calendar in the format #XXXXXXXX.
```

The function `calendar:request_permission()` calls `on_permission_granted()` callback if the user agrees to grant permission.

## Phone

* `phone:contacts()` - returns table of phone contacts (function will return the string `permission_error` if the launcher does not have permissions to read the calendar);
* `phone:request_permission()` - requests access rights to the contacts;
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

The function `phone:request_permission()` calls `on_permission_granted()` callback if the user agrees to grant permission.

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

## Weather

* `weather:get_by_hour()` - performs hourly weather query.

Function returns the weather data in the `on_weather_result(result)` callback, where `result` is a table of tables with the following fields:

```
`time` - time in seconds;
`temp` - temperature;
`icon_code` - code of weather icon;
`humidity` - humidity;
`wind_speed` - wind speed;
`wind_direction` - wind direction.
```

## Cloud

* `cloud:get_metadata(path)` - returns a table with file metadata;
* `cloud:get_file(path)` - returns the contents of the file;
* `cloud:put_file(sting, path)` - writes a string to the file;
* `cloud:remove_file(path)` - deletes file;
* `cloud:list_dir(path)` - returns metadata table of all files and subdirectories;
* `cloud:create_dir(path)` - creates directory;

All data are returned in `on_cloud_result(meta, content)`. The first argument is the metadata, either a metadata table (in the case of `list_dir()`) or an error message string. The second argument is the contents of the file (in the case of `get_file()`).

## Profiles

* `profiles:list()` - returns a list of saved profiles;
* `profiles:dump(name)` - saves a new profile with the specified name;
* `profiles:restore(name)` - restores the saved profile;
* `profiles:dump_json()` - creates a new profile but instead of saving it, returns it as a JSON string;
* `profiles:restore_json(json)` - restores a profile previously saved using `dump_json()`;
* `profiles:current()` - returns current profile name.

## Reading notifications

_Available only in widget scripts._

_This module is intended for reading notifications from other applications. To send notifications, use the `system` module._

* `notify:list()` - returns list of current notifications as table of tables;
* `notify:open(key)` - opens notification with specified key;
* `notify:close(key)` - removes the notification with the specified key;
* `notify:do_action(key, action_id)` - sends notification action.

The launcher triggers callback when a notification is received or removed:

* `on_notifications_updated()` – notification list changed;

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
`big_text` - extended notification text;
`is_clearable` - true, if the notification is clearable;
`group_id` - notification group ID;
`messages` - table of tables with fields: `sender`, `text`, `time`;
`actions` - table notifications actions with fields: `id`, `title`, `have_input`;
```

Keep in mind that the AIO Launcher also request current notifications every time you return to the launcher, which means that all scripts will also get the `on_notifications_updated()` callback called.

## Files

*Available from: 4.1.3*

* `files:read(name)` — returns file contents or `nil` if the file does not exist.
* `files:write(name, string)` — writes a string to a file (creates it if needed).
* `files:delete(name)` — deletes the file.

All files created by scripts are stored in:

```
/sdcard/Android/data/ru.execbit.aiolauncher/files/scripts
```

Subdirectories are not supported.

## External files

*Available from: 6.0.2*

Scripts may request a system file picker:

* `files:pick_file([mime])` — opens the picker (e.g. `"image/*"`, `"text/*"`, `"*/*"`).

After the user selects a file, the callback is invoked:

```
on_file_picked(uri, name)
```

* `uri` — Android content URI of the selected file.
* `name` — display name returned by the system.

### Reading uri

* `files:read_uri(uri)` — reads the contents of a file referenced by a content URI.
  Returns a string or `nil` if the file cannot be read as text.

Example:

```lua
files:pick_file()

function on_file_picked(uri, name)
    local content = files:read_uri(uri)
    ui:show_text(content or "Cannot read file: " .. name)
end
```

## Functions

* `utils:md5(string)` - returns md5-hash of string (array of bytes);
* `utils:sha256(string)` - returns sha256-hash of string (array of bytes);
* `utils:base64encode(string)` - returns base64 representation of string (array of bytes);
* `utils:base64decode(string)` - decodes base64 string;

## Tasker

* `tasker:tasks([project])` - returns a list of all the tasks in the Tasker, the second optional argument is the project for which you want to get the tasks (returns nil if Tasker is not installed or enabled);
* `tasker:projects()` - returns all Tasker projects (returns nil if Tasker is not installed or enabled);
* `tasker:run_task(name, [args])` - executes the task in the Tasker, the second optional argument is a table of variables passed to the task in the format `{ name = "value" }`;
* `tasker:send_command(command)` - sends [tasker command](https://tasker.joaoapps.com/commandsystem.html).

## Other

AIO Launcher includes the LuaJ 3.0.1 interpreter (compatible with Lua 5.2) with a standard set of modules: `bit32`, `coroutine`, `math`, `os`, `string`, `table`.

The modules `io` and `package` are excluded from the distribution for security reasons, the module `os` has been cut in functionality. Only the following functions are available: `os.clock()`, `os.date()`, `os.difftime()` and `os.time()`.

The standard Lua API is extended with the following features:

* `string:split(delimeter)` - splits the string using the specified delimiter and returns a table;
* `string:replace(regexp, string)` - replaces the text found by the regular expression with another text;
* `string:trim()` - removes leading and trailing spaces from the string;
* `string:starts_with(substring)` - returns true if the string starts with the specified substring;
* `string:ends_with(substring)` - returns true if the string ends with the specified substring;
* `slice(table, start, end)` - returns the part of the table starting with the `start` index and ending with `end` index;
* `index(table, value)` - returns the index of the table element;
* `key(table, value)` - returns the key of the table element;
* `concat(table1, table2)` - adds elements from array table `table2` to `table1`;
* `reverse(table)` - returns a table in which the elements follow in reverse order;
* `serialize(table)` - serializes the table into executable Lua code;
* `round(x, n)` - rounds the number;
* `map(function, table)`, `filter(function, table)`, `head(table)`, `tail(table)`, `reduce(function, table)` - several convenience functional utilities form Haskell, Python etc.

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
-- type = "widget"
-- foldable = "true"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- version = "1.0"
```

# Samples

=== File: main/wikipedia-widget.lua ===
```
-- name = "Wikipedia"
-- description = "Random article from wikipedia"
-- type = "widget"
-- foldable = "false"

json = require "json"
url = require "url"

function on_alarm()
    lang = system:lang()
    random_url = "https://"..lang..".wikipedia.org/w/api.php?action=query&format=json&list=random&rnnamespace=0&rnlimit=1"
    summary_url = "https://"..lang..".wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1"
    article_url = "https://"..lang..".wikipedia.org/wiki/"

    http:get(random_url)
end

function on_network_result(result, code)
    if code >= 200 and code < 299 and result and #result > 0 then
        local ok, parsed = pcall(json.decode, result)
        if not ok or type(parsed) ~= "table" then
            ui:show_text("Invalid data")
            return
        end

        if parsed and parsed.query and parsed.query.random then
            title = parsed.query.random[1].title
            http:get(summary_url.."&titles="..url.quote(title), "summary")
        end
    end
end

function on_network_result_summary(result, code)
    if code >= 200 and code < 299 and result and #result > 0 then
        local ok, parsed = pcall(json.decode, result)
        if not ok or type(parsed) ~= "table" then
            ui:show_text("Invalid data")
            return
        end

        if parsed then
            local extract = get_extract(parsed)
            if extract then
                ui:show_lines({ smart_sub(extract, 200) }, { title or "" })
            end
        end
    end
end

function on_click()
    if title then
        system:open_browser(article_url..url.quote(title))
    end
end

function smart_sub(string, max)
    local pos1, pos2 = string:find("%.", max-50)

    if pos1 ~= nil and pos1 < max+50 then
        return string:sub(1, pos1+1)
    else
        return string:sub(1, max)
    end
end

function get_extract(parsed)
    for k,v in pairs(parsed.query.pages) do
        for k, v in pairs(v) do
            if (k == "extract") then
                return v
            end
        end
    end
end
```

=== File: main/sys-info-widget.lua ===
```
-- name = "System info"
-- description = "Device information in real time"
-- type = "widget"

function on_tick(ticks)
    if ticks % 10 ~= 0 then
        return
    end

    local info = system:system_info()
    local strings = stringify_table(info)

    ui:show_lines(strings)
end

function stringify_table(tab)
    local new_tab = {}

    for k,v in pairs(tab) do
        table.insert(new_tab, capitalize(k):replace("_", " ")..": "..tostring(v))
    end

    table.sort(new_tab)

    return new_tab
end

function capitalize(string)
    return string:gsub("^%l", string.upper)
end
```

=== File: main/battery-widget.lua ===
```
-- name = "Battery info"
-- description = "Simple battery info widget"

function on_tick(ticks)
    -- Update one time per 10 seconds
    if ticks % 10 ~= 0 then
        return
    end

    local batt_info = system:battery_info()
    local batt_strings = stringify_table(batt_info)
    local folded_str = "Battery: "..batt_info.percent.."% | "..batt_info.temp.."° | "..batt_info.voltage.." mV"

    ui:show_lines(batt_strings, nil, folded_str)
end

function stringify_table(tab)
    local new_tab = {}

    for k,v in pairs(tab) do
        table.insert(new_tab, capitalize(k)..": "..tostring(v))
    end

    return new_tab
end

function capitalize(string)
    return string:gsub("^%l", string.upper)
end
```

=== File: main/calendar-menu.lua ===
```
-- name = "Calendar menu"
-- description = "Shows events from system calendar"
-- type = "drawer"

local fmt = require "fmt"

local have_permission = false
local events = {}
local calendars = {}

function on_drawer_open()
    events = calendar:events()
    calendars = calendar:calendars()

    if events == "permission_error" then
        calendar:request_permission()
        return
    end

    have_permission = true

    add_cal_colors(events, calendars)

    if #events == #drawer:items() then
        return
    end

    lines = map(function(it)
        local date = fmt.colored(format_date(it.begin), it.calendar_color)
        return date..fmt.space(4)..it.title
    end, events)

    drawer:show_ext_list(lines)
end

function add_cal_colors(events, cals)
    for i, event in ipairs(events) do
        for _, cal in ipairs(cals) do
            if event.calendar_id == cal.id then
                event.calendar_color = cal.color
                break
            end
        end
    end
end

function format_date(date)
    if system.format_date_localized then
        return system:format_date_localized("dd.MM", date)
    else
        return os.date("%d.%m", date)
    end
end

function on_click(idx)
    if not have_permission then return end

    calendar:show_event_dialog(events[idx].id)
end

function on_long_click(idx)
    if not have_permission then return end

    calendar:open_event(events[idx].id)
end
```

=== File: main/contacts-menu.lua ===
```
-- name = "Contacts menu"
-- description = "Shows phone contacts in the side menu"
-- type = "drawer"

local have_permission = false

function on_drawer_open()
    local raw_contacts = phone:contacts()

    if raw_contacts == "permission_error" then
        phone:request_permission()
        return
    end

    have_permission = true

    contacts = distinct_by_name(
        sort_by_name(phone:contacts())
    )

    if #contacts == #drawer:items() then
        return
    end

    names = map(contacts, function(it) return it.name end)
    keys = map(contacts, function(it) return it.lookup_key end)

    icons = map(contacts, function(it)
        if it.icon ~= nil then
            return it.icon
        else
            return "fa:phone" -- Backward compatibility
        end
    end)

    drawer:show_list(names, icons, nil, true)
end

function on_click(idx)
    if not have_permission then return end

    phone:show_contact_dialog(contacts[idx].lookup_key)
end

function map(tbl, f)
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = f(v)
    end
    return ret
end

function sort_by_name(tbl)
    table.sort(tbl, function(a,b) return a.name:lower() < b.name:lower() end)
    return tbl
end

function distinct_by_name(tbl)
    local ret = {}
    local names = {}
    for _, contact in ipairs(tbl) do
        if not names[contact.name] then
            table.insert(ret, contact)
        end
        names[contact.name] = true
    end
    return ret
end
```

=== File: main/public-ip-widget.lua ===
```
-- name = "Public IP"
-- description = "Shows your public IP"
-- type = "widget"
-- foldable = "false"

function on_alarm()
    http:get("https://api.ipify.org")
end

function on_network_result(result, code)
    if code >= 200 and code < 299 then
        ui:show_text(result)
    end
end
```

=== File: main/year_progress-widget.lua ===
```
-- name = "Year progress"
-- description = "Shows current year progress"
-- type = "widget"
-- foldable = "false"

function on_resume()
    local year_days = 365
    local current_day = os.date("*t").yday
    local percent = math.floor(current_day / (year_days / 100))
    ui:show_progress_bar("Year progress: "..percent.."%", current_day, year_days)
end
```

=== File: main/inspiration-quotes-widget.lua ===
```
-- name = "Inspiration quotes"
-- description = "ZenQuotes.io"
-- type = "widget"
-- foldable = "false"

local json = require "json"

function on_alarm()
    http:get("https://zenquotes.io/api/random")
end

function on_network_result(result, code)
    if code >= 200 and code < 299 then
        ok, res = pcall(json.decode, result)

        if not ok or type(res) ~= "table" then
            ui:show_text("Invalid data: "..result)
            return
        end

        if res and res[1] and res[1].q and res[1].a then
            ui:show_lines({ res[1].q }, { res[1].a })
        else
            ui:show_text("%%txt%% Got incorrect data:\n"..serialize(res))
        end
    end
end

function on_click()
    if res ~= nil then
        system:to_clipboard(res[1].q.." - "..res[1].a)
    end
end
```

=== File: community/profiles-dumper-widget.lua ===
```
-- name = "Profiles auto dumper"
-- description = "Hidden widget that auto dump profile on every return to the home screen"
-- foldable = "false"

local prof_name = "Auto dumped"

function on_load()
    ui:hide_widget()
end

function on_resume()
    profiles:dump(prof_name)
end
```

=== File: community/shell-widget.lua ===
```
-- name = "Shell widget"
-- description = "Shows the result of executing console commands"
-- type = "widget"
-- foldable = "false"

current_output = "Click to enter command"

function on_preview()
    ui:show_text("Shows the result of executing console commands")
end

function on_resume()
    redraw()
end

function redraw()
    ui:show_text("%%txt%% "..current_output)
end

function on_click(idx)
    dialogs:show_edit_dialog("Enter command")
end

function on_dialog_action(text)
    system:exec(text)
end

function on_shell_result(text)
    if text == "" then
        current_output = "no output"
    else
        current_output = text
    end

    redraw()
end
```

=== File: community/play-store-search.lua ===
```
-- name = "Play Store"
-- description = "Search anything in Play Store app"
-- type = "search"
-- prefix = "store|ps"

text_from = ""
text_to = ""

local md_color = require "md_colors"
local green = md_colors.green_600

function on_search(input)
    text_from = input
    text_to = ""
    search:show({input},{green})
end

function on_click(idx)
    system:open_browser("https://play.google.com/store/search?q="..text_from)
end
```

=== File: community/qr-code-search.lua ===
```
-- name = "QR Code"
-- description = "Turn any text or url into QR code"
-- type = "search"
-- prefix = "qr"

qr_code_url = "https://api.qrserver.com/v1"
text_from = ""
text_to = ""

local md_color = require "md_colors"

-- constants
local blue = md_colors.blue_500


function on_search(input)
    text_to = ""
    text_from = input
    search:show({input},{blue})
end

function on_click()
    if text_to == "" then
        get_qr_code(text_from)
    end
end

function get_qr_code(text)
    url = qr_code_url.."/create-qr-code/?size=150x150&data="..text
    system:open_browser(url)
end
```

=== File: community/profiles-restore-save-widget.lua ===
```
-- name = "Profile Switcher"
-- description = "Tap: restore profile / Long-press: save to profile"
-- type = "widget"

local profs
local profile

function on_load()
    profs = profiles:list()
    ui:show_buttons(profs)
end

function on_click(idx)
    profile = profs[idx]
    profiles:restore(profile)
    ui:show_toast(profile..": Restored")
end

function on_long_click(idx)
    profile = profs[idx]
    title = 'Save to "'..profile..'" ?'
    text = 'Do you want to save the current screen state to the "'..profile..'" profile ?'
    dialogs:show_dialog(title, text, "Yes", "Cancel")
end

function on_dialog_action(value)
    if value == 1 then
       profiles:dump(profile)
       ui:show_toast(profile..": Saved")
    elseif value == 2 then
       ui:show_toast("Canceled")
    end
end
```

=== File: community/share-menu-search.lua ===
```
-- name = "Share Text"
-- description = "Share text with other apps"
-- type = "search"
-- prefix = "share"

local md_color = require "md_colors"

-- constants
local blue = md_colors.blue_500
local red = md_colors.red_500

-- variables
text_from = ""
text_to=""
function on_search(input)
    text_from = input
    text_to = ""
    search:show_buttons({"Share \""..input.."\""}, {blue}, true)
end

function on_click()
    if text_to == "" then
        system:share_text(text_from)
    end
end
```

=== File: community/public-ip-search.lua ===
```
-- name = "Public IP"
-- description = "Shows your public IP in the search bar"
-- type = "search"

local md_color = require "md_colors"
local blue = md_colors.blue_500
local red = md_colors.red_500

local ip = ""
function on_search(input)
    if input:lower():find("^ip$") then
        get_ip()
    end
end

function on_click()
    system:to_clipboard(ip)
end

function get_ip()
    http:get("https://api.ipify.org")
end

function on_network_result(result,code)
    if code >= 200 and code < 300 then
        ip = result
        search:show_buttons({result},{blue})
    else
        search:show_buttons({"Server Error"},{red})
    end
end
```

=== File: community/monitor-lite-widget.lua ===
```
-- name = "Monitor"
-- description = "One line monitor widget"
-- type = "widget"

local fmt = require "fmt"
local good_color = aio:colors().progress_good
local bad_color = aio:colors().progress_bad

function on_tick(n)
    -- Update every ten seconds
    if n % 10 == 0 then
        update()
    end
end

function update()
    local batt_percent = system:battery_info().percent
    local is_charging = system:battery_info().charging
    local mem_total = system:system_info().mem_total
    local mem_available = system:system_info().mem_available
    local storage_total = system:system_info().storage_total
    local storage_available = system:system_info().storage_available

    if (is_charging) then
        batt_percent = fmt.colored(batt_percent.."%", good_color)
    elseif (batt_percent <= 15) then
        batt_percent = fmt.colored(batt_percent.."%", bad_color)
    else
        batt_percent = batt_percent.."%"
    end

    ui:show_text(
        "BATT: "..batt_percent..fmt.space(4)..
        "RAM: "..mem_available..fmt.space(4)..
        "NAND: "..storage_available
    )
end
```

=== File: community/youtube-search.lua ===
```
-- name = "Youtube"
-- description = "Search anything in youtube app"
-- type = "search"
-- prefix = "youtube|yt"

text_from = ""
text_to = ""
yt_intent_action = "android.intent.action.SEARCH"
yt_intent_category = "android.intent.category.DEFAULT"
yt_package_name = "com.google.android.youtube"

local md_color = require "md_colors"
local red = md_colors.red_800

function on_search(input)
    text_from = input
    text_to = ""
    search:show({input},{red})
end

function on_click(idx)
    intent:start_activity{
        action = yt_intent_action,
        category = yt_intent_category,
        package = yt_package_name,
        extras = {
            query=text_from
        }
    }
end
```

=== File: community/actions-menu.lua ===
```
-- name = "Actions menu"
-- description = "Shows aio launcher actions"
-- type = "drawer"

function on_drawer_open()
    actions = aio:actions()
    labels = map(actions, function(it) return it.label end)
    drawer:show_list(labels)
end

function on_click(idx)
    aio:do_action(actions[idx].name)
    drawer:close()
end

function map(tbl, f)
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = f(v)
    end
    return ret
end
```

=== File: community/currency-cbr-search.lua ===
```
-- name = "Курс валют ЦБ"
-- description = "Cкрипт отображает курс валюты ЦБ России на заданную дату (usd 30 3 22)"
-- type = "search"
-- lang = "ru"

-- modules
local xml = require "xml"
local md_color = require "md_colors"

-- constants
local red = md_colors.red_500

-- variables
local cur = ""
local dat = ""
local val = 0

function on_search(inp)
	val = 0
	local c,d,m,y = inp:match("^(%a%a%a)%s?(%d?%d?)%s?(%d?%d?)%s?(%d?%d?%d?%d?)$")
    if c == nil then return end

	cur = c:upper()
	local t = os.date("*t")
	if d == "" then
	    d = t.day
	end
	if m == "" then
	    m = t.month
	end
	if y == "" then
	    y = t.year
	elseif y%100 > 95 then
	    y = 1900 + y%100
	else
	    y = 2000 + y%100
	end
	dat = os.date("%d.%m.%Y",os.time{day=d,month=m,year=y})
	search:show({"Курс "..cur.." "..dat},{red})
end

function on_click()
    if val == 0 then
	    http:get("https://www.cbr.ru/scripts/XML_daily.asp?date_req="..dat:replace("%.","/"))
	    return false
	else
	    system:to_clipboard(val)
	    return true
	end
end

function on_network_result(res)
    local t = xml:parse(res)
	for i,v in ipairs(t.ValCurs.Valute) do
		if v.CharCode:value() == cur then
			search:show({t.ValCurs["@Date"],v.Nominal:value().." "..v.CharCode:value().." = "..v.Value:value():replace(",",".").." RUB"},{red,red})
			val = v.Value:value()
			return
		end
	end
	search:show_buttons({"Нет данных по валюте "..cur},{red})
end

function on_long_click()
	system:to_clipboard(val)
	return true
end
```

=== File: community/isdayoff-ru-widget.lua ===
```
-- name = "Сегодня выходной?"
-- description = "Показывает, выходной ли сегодня день."
-- type = "widget"
-- lang = "ru"

function on_alarm()
    local dateStr = os.date('%Y%m%d')
    http:get("https://isdayoff.ru/"..dateStr)
end

function on_network_result(result)
    if result == "0" then
        ui:show_text("Сегодня рабочий день")
    elseif result == "1" then
        ui:show_text("Сегодня выходной")
    else
        ui:show_text("Ошибка")
    end
end
```

=== File: community/google-translate-search.lua ===
```
-- name = "Google Translate"
-- description = "A search script that shows the translation of what you type in the search window"
-- type = "search"

local json = require "json"
local md_color = require "md_colors"

-- constants
local blue = md_colors.blue_500
local red = md_colors.red_500
local uri = "http://translate.googleapis.com/translate_a/single?client=gtx&sl=auto"

-- vars
local text_from = ""
local text_to = ""

function on_search(input)
    text_from = input
    text_to = ""

    search:show_buttons({"Translate \""..input.."\""}, {blue}, true)
end

function on_click()
    if text_to == "" then
        search:show_buttons({"Translating..."}, {blue}, true)
        request_trans(text_from)
        return false
    else
        system:to_clipboard(text_to)
        return true
    end
end

function request_trans(str)
    http:get(uri.."&tl="..system:lang().."&dt=t&q="..str)
end

function on_network_result(result, code)
    if code >= 200 and code < 300 then
        decode_and_show(result)
    else
        search:show_buttons({"Server error"}, {red}, true)
    end
end

function decode_and_show(result)
    local t = json.decode(result)

    for i, v in ipairs(t[1]) do
        text_to = text_to..v[1]
    end

    --local lang_from = t[3]

    if text_to ~= "" then
        search:show_buttons({text_to}, {blue}, true)
    end
end
```

=== File: community/solar-cycle-widget.lua ===
```
-- name = "Solar Cycle"
-- description = "Shows Sunrise Sunset at your location"
-- type = "widget"
-- foldable = "false"

local json = require "json"
local md_colors = require "md_colors"

function on_alarm()
    local location=system:location()
    url="https://api.sunrise-sunset.org/json?lat="..location[1].."&lng="..location[2].."&formatted=0"
    http:get(url)
end


function on_network_result(result)
    local t = json.decode(result)

    if not t.results then
        ui:show_text("Error: invalid data")
        return
    end

    local times_table = {
        {
            gen_icon("red_900","↦"),
            gen_icon("orange_900", "↗"),
            gen_icon("yellow_900", "☀"),
            gen_icon("orange_900", "↘"),
            gen_icon("red_900", "⇥"),
        },
        {
            time_from_utc(t.results.civil_twilight_begin),
            time_from_utc(t.results.sunrise),
            time_from_utc(t.results.solar_noon),
            time_from_utc(t.results.sunset),
            time_from_utc(t.results.civil_twilight_end),
        }
    }

    ui:show_table(times_table, 0, true)
end

function time_from_utc(utc)
    return utc_to_local(parse_iso8601_datetime(utc))
end

function gen_icon(md_color, icon)
    return "<font color="..md_colors[md_color].."><b>"..icon.."</b></font>"
end

function parse_iso8601_datetime(json_date)
    local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%+%-]?)(%d?%d?)%:?(%d?%d?)"
    local year, month, day, hour, minute,
        seconds, offsetsign, offsethour, offsetmin = json_date:match(pattern)
    local timestamp = os.time{year = year, month = month,
        day = day, hour = hour, min = minute, sec = seconds}
    local offset = 0
    if offsetsign ~= '' and offsetsign ~= 'Z' then
      offset = tonumber(offsethour) * 60 + tonumber(offsetmin)
      if xoffset == "-" then offset = offset * -1 end
    end

    return timestamp + offset * 60
end

function utc_to_local(utctime)
    local local_time_str = os.date("%H:%M", utctime)
    local utc_time_str = os.date("!%H:%M", utctime)

    local function time_to_seconds(timestr)
        local hour, minute = timestr:match("(%d+):(%d+)")
        return tonumber(hour) * 3600 + tonumber(minute) * 60
    end

    local local_seconds = time_to_seconds(local_time_str)
    local utc_seconds = time_to_seconds(utc_time_str)
    local delta = local_seconds - utc_seconds

    return os.date("%H:%M", utctime + delta)
end
```

=== File: community/navigate-search.lua ===
```
-- name = "Navigate"
-- description = "Navigate to address"
-- type = "search"
-- prefix = "navigate|nav"

text_from = ""
text_to = ""
maps_intent_action = "android.intent.action.VIEW"
maps_intent_category = "android.intent.category.DEFAULT"
maps_package_name = "com.google.android.apps.maps"

local md_color = require "md_colors"
local blue = md_colors.light_blue_800

function on_search(input)
    text_from = input
    text_to = ""
    search:show_buttons({input},{blue})
end

function on_click(idx)
    intent:start_activity{
        action = maps_intent_action,
        category = maps_intent_category,
        package = maps_package_name,
        data = "google.navigation:q="..text_from
    }
end
```

=== File: community/net-file-widget.lua ===
```
-- name = "Network file"
-- description = "Shows the contents of any file on the Internet"

function on_resume()
    local args = settings:get()

    if next(args) == nil then
        ui:show_text("Tap to enter text file URL")
    else
        http:get(args[1])
    end
end

function on_click()
    settings:show_dialog()
end

function on_network_result(result)
    ui:show_text(result)
end

function on_settings()
    settings:show_dialog()
end
```

=== File: community/time-date-widget.lua ===
```
-- name = "Time & Date"
-- description = "Simple widget showing current time and date"
-- type = "widget"

local function draw()
    local now  = os.date("*t")
    local time = string.format("%02d:%02d", now.hour, now.min)
    local date = os.date("%a, %d %b")

    gui{
        {"spacer", 2},
        {"text", time, { size = 40 }},
        {"text", date, { size = 20, gravity = "right|center_v" }},
        {"spacer", 2},
    }.render()
end

function on_tick()
    draw()
end

function on_click(idx)
    -- time
    if idx == 2 then
        intent:start_activity{
            action = "android.intent.action.SHOW_ALARMS"
        }
        return
    end

    -- date
    if idx == 3 then
        intent:start_activity{
            action = "android.intent.action.MAIN",
            category = "android.intent.category.APP_CALENDAR"
        }
    end
end
```

=== File: community/google-translate-widget.lua ===
```
-- name = "Google Translate"
-- type = "widget"

local json = require "json"
local uri = "http://translate.googleapis.com/translate_a/single?client=gtx&sl=auto"
local text_from = ""

function on_resume()
    ui:show_text("Tap to enter text")
end

function on_click()
    dialogs:show_edit_dialog("Enter text")
end

function on_dialog_action(text)
    if text == "" or text == -1 then
        on_resume()
    else
        text_from = text
        translate(text)
    end
end

function translate(str)
    http:get(uri.."&tl="..system:lang().."&dt=t&q="..str)
end

function on_network_result(result)
    local t = json.decode(result)
    local text_to = ""

    if not t or not t[1] or type(t[1]) ~= "table" then
        ui:show_text("Error: invalid response")
        return
    end

    for i, v in ipairs(t[1]) do
        text_to = text_to..v[1]
    end

    local lang_from = t[3]
    ui:show_lines({text_from.." ("..lang_from..")"}, {text_to})
end
```

=== File: community/tasker-command-search.lua ===
```
-- name = "Tasker Command Search"
-- description = "Sends tasker command from search bar"
-- type = "search"
-- prefix = "tasker | Tasker | command"

local md_color = require "md_colors"
local orange = md_colors.orange_500

text_from = ""
text_to = ""

function on_search(input)
    text_from = input
    text_to = ""
    search:show({input},{orange})
end

function on_click(idx)
    text_from = string.lower(text_from)
    text_from=text_from:replace(" ", "=:=")
    tasker:send_command(text_from)
end
```

=== File: community/weather-widget.lua ===
```
-- name = "Weather by hour"
-- description = "Shows weather forecast by hour"

function on_alarm()
    weather:get_by_hour()
end

function on_weather_result(tab)
    local tab2 = {}

    for k,v in pairs(tab) do
        table.insert(tab2, time_to_string(v.time)..": "..v.temp)
    end

    ui:show_lines(tab2)
end

function time_to_string(time)
    return os.date("%c", time)
end
```

=== File: samples/rich-gui-sample.lua ===
-- name = "Rich GUI sample"

function on_resume()
    local app = apps:app("ru.execbit.aiolauncher")
    if app == nil then return end

    my_gui = gui{
        {"icon", "fa:smile", {size = 15, color = "#aaaaaa", gravity = "center_v"}},
        {"text", "<b>This is</b>", {size = 25, color = "#ff0000", gravity = "center_h|center_v"}},
        {"spacer", 2},
        {"text", "<b><u>TITLE</u></b>", {size = 20, color = "#ff0000", gravity = "anchor_prev|center_v"}},
        {"spacer", 2},
        {"icon", "fa:smile", {size = 15, color = "#aaaaaa", gravity = "center_v"}},
        {"new_line", 2},
        {"text", "Hello, World", {size = 21}},
        {"spacer", 2},
        {"text", "Center small text", {size = 8, gravity = "center_v"}},
        {"spacer", 1},
        {"icon", "fa:plus", {size = 8, gravity="center_v"}},
        {"text", "Top right text", {size = 8, gravity = "top|right"}},
        {"new_line", 1},
        {"button", "Ok", {color = "#00aa00"}},
        {"button", "Neutral", {color = "#666666", gravity = "right"}},
        {"spacer", 2},
        {"button", "Cancel", {color = "#ff0000", gravity = "right"}},
        {"new_line", 2},
        {"button", "Button"},
        {"spacer", 2},
        {"text", "Text", {gravity = "center_v"}},
        {"new_line", 2},
        {"progress", "Progress #1", {progress = 70}},
        {"progress", "Progress #2", {progress = 30, color = "#0000ff"}},
        {"new_line", 2},
        {"progress", "Progress #3", {progress = 100, gravity = "center_v"}},
        {"spacer", 2},
        {"text", "Text", {gravity = "center_v|anchor_prev"}},
        {"spacer", 2},
        {"button", "Button"},
        {"new_line", 2},
        {"button", "Center button", {gravity = "center_h"}},
        {"new_line", 2},
        {"button", "Whole width button", {expand = true}},
        {"spacer", 2},
        {"button", "fa:home"},
        {"spacer", 2},
        {"button", "fa:check"},
        {"new_line", 2},
        {"button", "Button #1", {expand = true}},
        {"spacer", 2},
        {"button", "Button #2", {expand = true}},
        {"spacer", 2},
        {"button", "fa:check"},
        {"new_line", 2},
        {"icon", "fa:microphone", {size = 17, color = "#00ff00", gravity = "center_v"}},
        {"spacer", 4},
        {"icon", "fa:microphone", {size = 22, gravity = "center_v"}},
        {"spacer", 4},
        {"icon", "fa:microphone", {size = 27, gravity = "center_v"}},
        {"spacer", 4},
        {"icon", "fa:microphone", {size = 32, gravity = "center_v"}},
        {"icon", app.icon, {size = 17, gravity = "center_v|right"}},
        {"spacer", 4},
        {"icon", app.icon, {size = 22, gravity = "center_v"}},
        {"spacer", 4},
        {"icon", app.icon, {size = 27, gravity = "center_v"}},
        {"spacer", 4},
        {"icon", app.icon, {size = 32, gravity = "center_v"}},
    }

    my_gui.render()
end

function on_apps_changed()
    on_resume()
end

function on_click(idx)
    local elem_name = my_gui.ui[idx][1]

    if elem_name == "text" then
        my_gui.ui[idx][2] = "<u>"..my_gui.ui[idx][2].."</u>"
    elseif elem_name == "button" then
        my_gui.ui[idx][2] = "Clicked"
    elseif elem_name == "progress" then
        my_gui.ui[idx][3].progress = 100
    elseif elem_name == "icon" then
        my_gui.ui[idx][3].color = "#ff0000"
    end

    my_gui.render()
    ui:show_toast("Clicked: "..my_gui.ui[idx][1])
end

function on_long_click(idx)
    ui:show_toast("Long click: "..my_gui.ui[idx][1])
end
---

Generate a **single, runnable Lua script** for AIO Launcher (LuaJ 3.0.1, Lua 5.2 subset).
Metadata header MUST use double quotes like `-- key = "value"`. Single quotes in metadata are not allowed under any circumstances.
If you decide to use an API in your script that requires an API key, make sure to include code that asks the user for the key (via a dialog) and saves it for future use.
**Output must be only Lua code, without Markdown fences or explanations.**
