# Introduction

Starting from version 4.0, AIO Launcher supports scripts written in the [Lua scripting language](https://en.wikipedia.org/wiki/Lua_(programming_language)). Scripts should be placed in the directory `/sdcard/Android/data/ru.execbit.aiolauncher/files/`.

There are two types of scripts:

* _Widget scripts_, which can be added to the desktop using the side menu.
* _Search scripts_ that add results to the search box. These can be enabled in the settings.

The type of script is determined by the line (meta tag) at the beginning of the file:

* `-- type = "widget"`
* `-- type = "search"`

*Read more about meta tags at the end of the document.*

# Changelog

* 4.0.0 - first version with scripts support;
* 4.1.0 - added `weather` and `cloud` modules;
* 4.1.3 - added `notify`, `files` and `utils` modules;
* 4.1.5 - extended `notify` module, added `folded_string` arg to `ui:show_lines`;
* 4.3.0 - search scripts support;
* 4.4.0 - markdown support;
* 4.4.1 - rich text editor support;
* 4.4.2 - added `fmt` and `html` utility modules;
* 4.4.4 - added `tasker` module;
* 4.4.6 - added `csv` module;
* 4.4.7 - added `intent` module;
* 4.5.0 - the `aio` module has been significantly expanded, also added `system:get_currency()` and `ui:show_list_dialog()`;
* 4.5.2 - added `anim` and `morph` packages, added `calendar:open_event()` function.

# Widget scripts

The work of the widget script begins with one of the three described functions. Main work should be done in one of them.

* `on_resume()` - called every time you return to the desktop.
* `on_alarm()` - called every time you return to the desktop, but no more than once every 30 minutes.
* `on_tick(ticks)` - called every second while the launcher is on the screen. The `ticks` parameter is number of seconds after last return to the launcher.

The `on_resume()` and `on_alarm()` callbacks are also triggered when a widget is added to the screen and the screen is forced to refresh.

For most network scripts `on_alarm()` should be used.

# Search scripts

Unlike widget scripts, search scripts are launched only when you open the search window. Then the following function is triggered each time a character is entered:

* `on_search(string)` is run when each character is entered, `string` - entered string.

The search script can use two functions to display search results:

* `search:show(strings, [colors])` - shows results BELOW all other results;
* `search:show_top(strings, [colors])` - shows results BEFORE all other results.

Both functions take a table with search results strings as the first argument. Second optional parameter: table with colors of results in format `#XXXXXX`.

When user click on a result, one of the following functions will be executed:

* `on_click(index)` - normal click;
* `on_long_click(index)` - long-click.

Both functions gets index of the clicked element (starting with 1) as an argument. Each function can return `true` or `false`, depending on whether the script wants to close the search window or not.

# API Reference

## User Interface

_Available only in widget scripts._

* `ui:show_text(string)` - displays plain text in widget, repeated call will erase previous text;
* `ui:show_lines(table, [table], [folded_string])` - displays a list of lines with the sender (in the manner of a mail widget), the second argument (optional) - the corresponding senders (formatting in the style of a mail widget), folded\_string (optional) - string to be shown in folded mode;
* `ui:show_table(table, [main_column], [centering], [folded_value])` - displays table, first argument: table of tables, second argument: main column, it will be stretched, occupying main table space (if argument is zero or not specified all table elements will be stretched evenly), third argument: boolean value indicating whether table cells should be centered, fourth argument: string or table to be shown in folded mode;
* `ui:show_buttons(names, [colors])` - displays a list of buttons, the first argument is a table of strings, the second is an optional argument, a table of colors in the format #XXXXXX;
* `ui:show_progress_bar(text, current_value, max_value, [color])` - shows the progress bar;
* `ui:show_chart(points, [format], [title], [show_grid], [folded_string], [copyright])` - shows the chart, points - table of coordinate tables, format - data format (see below), title - chart name, show\_grid - grid display flag, folded\_string - string for the folded state (otherwise the name will be shown), copyright - string displayed in the lower right corner;
* `ui:show_toast(string)` - shows informational message in Android style;
* `ui:get_default_title()` - returns the standard widget title (set in the `name` metadata);
* `ui:set_title()` - changes the title of the widget, should be called before the data display function (empty line - reset to the standard title);
* `ui:set_folding_flag(boolean)` - sets the flag of the folded mode of the widget, the function should be called before the data display functions;
* `ui:get_folding_flag()` - returns folding flag;
* `ui:get_colors()` - returns table with current theme colors;

When you click on any element of the interface, the `on_click(number)` callback will be executed, where number is the ordinal number of the element. A long click calls `on_long_click(number)`. For example, if you use `ui:show_buttons` to show three buttons, then clicking the first button will call `on_click` with argument 1, the second with arguments 2, and so on. If there is only one element on the screen, the argument will always be equal to one and can be omitted.

The `ui:show_chart()` function takes a string as its third argument to format the x and y values on the screen. For example, the string `x: date y: number` means that the X-axis values should be formatted as dates, and the Y-values should be formatted as a regular number. There are four formats in total:

* `number` - an ordinary number with group separation;
* `float` - the same, but with two decimal places;
* `date` - date in day.month format;
* `time` - time in hours:minutes format.

The functions `ui:show_text()`, `ui:show_lines()` and `ui:show_table()` support many HTML tags. For example:

```
First line<br/> Second line
<b>Bold Line</b><br/><i>Oblique Line</i>
<font color="red">Red text</font>
<span style="background-color: #00FF00">Text on green background</span>
```

You can also use Markdown markup. To do this, add the prefix `%%mkd%%` to the beginning of the line. Or you can disable the formatting completely with the prefix `%%txt%%`.

The `ui:show_buttons()` function supports Fontawesome icons. Simply specify `fa:icon_name` as the button name, for example: `fa:play`.

## Dialogs

_Available only in widget scripts._

* `ui:show_dialog(title, text, [button1_text], [button2_text])` - show dialog, the first argument is the title, the second is the text, button1\_text is the name of the first button, button2\_text is the name of the second button;
* `ui:show_edit_dialog(title, [text], [default_value])` - show the dialog with the input field: title - title, text - signature, default\_value - standard value of the input field;
* `ui:show_radio_dialog (title, lines, [index])` - show a dialog with a choice: title - title, lines - table of lines, index - index of the default value;
* `ui:show_checkbox_dialog(title, lines, [table])` - show dialog with selection of several elements: title - title, lines - table of lines, table - table default values;
* `ui:show_list_dialog(prefs)` - shows dialog with list of data.

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

_Avaialble from: 4.4.1_

* `ui:show_rich_editor(prefs)` - show complex editor dialog with undo support, lists, time, colors support. It can be used to create notes and tasks style widgets.

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
* `system:exec(string)` - executes a shell command;
* `system:su(string)` - executes a shell command as root;
* `system:get_location()` - returns the location in the table with two values (location request is NOT executed, the value previously saved by the system is used);
* `system:copy_to_clipboard(string)` - copies the string to the clipboard;
* `system:get_from_clipboard()` - returns a string from the clipboard:
* `system:vibrate(milliseconds)` - vibrate;
* `system:alarm_sound(seconds)` - make alarm sound;
* `system:share_text(string)` - opens the "Share" system dialog;
* `system:get_lang()` - returns the language selected in the system;
* `system:get_tz_offset()` - returns TimeZone offset in seconds;
* `system:get_currency()` - returns default currency code based on locale;
* `system:get_battery_info()` - returns table with battery info;
* `system:get_system_info()` - returns table with system info.

The result of executing a shell command is sent to the `on_shell_result(string)` callback.

## Intens

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

* `aio:get_available_widgets()` - returns a table with the metadata of all widgets, scripts and plugins available for adding to the screen (_available from: 4.5.0_);
* `aio:get_active_widgets()` - returns a table with the metadata of all widgets, scripts, and plugins already added to the screen (_available from: 4.5.0_);
* `aio:add_widget(string, [position])` - adds a builtin widget, script widget or clone of an existing widget to the screen;
* `aio:remove_widget(string)` - removes the widget from the screen (instead of the name you can also pass the widget number or do not pass anything - then the current widget will be deleted);
* `aio:move_widget(string, position)` - moves the widget to a new position (you can also use the widget position instead of the name) (_available from: 4.5.0_);
* `aio:fold_widget(string, [boolean])` - fold/unfold widget (if you do not specify the second argument the state will be switched) (_available from: 4.5.0_);
* `aio:is_widget_added(string)` - checks if the widget is added to the screen;
* `aio:get_self_name()` - returns current script file name (_available from: 4.5.0_);
* `aio:do_action(string)` - performs an AIO action ([more](https://aiolauncher.app/api.html));
* `aio:send_message(value, [script_name])` - sends lua value to other script or scripts (_avaialble from: 4.5.0_).

Format of table elements returned by `aio:get_available_widgets()`:

* `name` - internal name of the widget;
* `type` - widget type: `builtin`, `script` or `plugin`;
* `description` - widget description (usually empty for non-script widgets);
* `clonable` - true if the widget can have clones (examples: "My apps", "Contacts", "Mailbox" widgets);
* `enabled` - true if the widget is placed on the screen.

Format of table elements returned by `aio:get_active_widgets()`:

* `name` - internal name of the widget;
* `position` - position on the screen;
* `folded` - true if widget is folded.

To accept a value sent by the `send_message` function, the receiving script must implement a callback `on_message(value)`.

The script can track screen operations such as adding, removing or moving a widget with the `on_widget_action()` callback. For example:

```
function on_widget_action(action, name)
    ui:show_toast(name..." action)
end
```

This function will be called on add, remove or move any widget.

## Application management

* `apps:get_list([sort_by], [no_hidden])` - returns the package table of all installed applications, `sort_by` - sort option (see below), `no_hidden` - true if no hidden applications are needed;
* `apps:get_name(package)` - returns application name;
* `apps:get_color(package)` - returns the color of the application in #XXXXXXXX format;
* `apps:launch(package)` - launches the application;
* `apps:show_edit_dialog(package)` - shows edit dialog of the application.

Sorting options:

* `abc` - alphabetical (default);
* `launch_count` - by number of launches;
* `launch_time` - by launch time;
* `install_time` - by installation time.

Any application-related events (installation, removal, name change, etc.) will call the `on_apps_changed()` callback (_not in the search scripts_).

## Network

* `http:get(url, [id])` - executes an HTTP GET request, `id` - the request identifier string (see below);
* `http:post(url, body, media_type, [id])` - executes an HTTP POST request;
* `http:put(url, body, media_type, [id])` - executes an HTTP request;
* `http:delete(url, [id])` - executes an HTTP DELETE request;
* `http:set_headers(table)` - sets the headers for **all** subsequent network requests; the argument is a table with strings like "Cache-Control: no-cache".

These functions do not return any value, but instead call the `on_network_result(string, [code])` callback. The first argument is the body of the response, the second (optional) is the code (200, 404, etc.).

If `id` was specified in the request, then the function will call `on_network_result_$id(string, [code])` instead of the callback described above. That is, if the id is "server1", then the callback will look like `on_network_result_server1(string, [code])`.

If there is a problem with the network, the `on_network_error_$id` callback will be called. But it does not have to be processed.

## Calendar

* `calendar:get_events([start_date], [end_date], [cal_table])` - returns table of event tables of all calendars, start\_date - event start date, end\_date - event end date, cal\_table - calendar ID table;
* `calendar:get_calendars()` - returns table of calendars tables;
* `calendar:show_event_dialog(id)` - shows the event dialog;
* `calendar:open_ovent(id)` - opens an event in the system calendar.

Event table format:

* `id` - event ID;
* `calendar_id` - calendar ID;
* `title` - title of the event;
* `description` - description of the event;
* `location` - address of the event by string;
* `begin` - start time of the event (in seconds);
* `end` - time of the event end (in seconds);
* `all_day` - boolean value, which means that the event lasts all day.

Calendar table format:

* `id` - calendar identifier;
* `name` - name of the calendar;
* `color` - color of the calendar in the format #XXXXXXXX.

## Phone

* `phone:get_contacts()` - returns table of phone contacts;
* `phone:make_call(number)` - dial the number in the dialer;
* `phone:send_sms(number, [text])` - open SMS application and enter the number, optionally enter text;
* `phone:show_contact_dialog(id)` - open contact dialog;

Contacts table format:

* `id` - contact id;
* `lookup_key` - unique contact identifier;
* `name` - contact name;
* `number` - contact number.

## Weather

_Avaialble from: 4.1.0_

* `weather:get_by_hour()` - performs hourly weather query.

Function returns the weather data in the `on_weather_result(result)` callback, where `result` is a table of tables with the following fields:

* `time` - time in seconds;
* `temp` - temperature;
* `icon_code` - code of weather icon;
* `humidity` - humidity;
* `wind_speed` - wind speed;
* `wind_direction` - wind direction.

## Cloud

_Avaialble from: 4.1.0_

* `cloud:get_metadata(path)` - returns a table with file metadata;
* `cloud:get_file(path)` - returns the contents of the file;
* `cloud:put_file(sting, path)` - writes a string to the file;
* `cloud:remove_file(path)` - deletes file;
* `cloud:list_dir(path)` - returns metadata table of all files and subdirectories;
* `cloud:create_dir(path)` - creates directory;

All data are returned in `on_cloud_result(meta, content)`. The first argument is the metadata, either a metadata table (in the case of `list_dir()`) or an error message string. The second argument is the contents of the file (in the case of `get_file()`).

## Notifications

_Available only in widget scripts._
_Avaialble from: 4.1.3_

* `notify:get_current()` - requests current notifications from the launcher;
* `notify:open(key)` - opens notification with specified key;
* `notify:close(key)` - removes the notification with the specified key;
* `notify:do_action(key, action_id)` - sends notification action (_available from: 4.1.5_);
* `notify:consumed(key)` - mark notification as consumed so built-in Notifications widget will not show it;

The `notify:get_current()` function asks for all current notifications. The Launcher returns them one by one to the `on_notify_posted(table)` callback, where table is the table representing the notification. The same callback will be called when a new notification appears. When the notification is closed, the `on_notify_removed(table)` colbeck will be called.

Notification table format:

* `key` - a key uniquely identifying the notification;
* `time` - time of notification publication in seconds;
* `package` - name of the application package that sent the notification;
* `number` - the number on the notification badge, if any;
* `importance` - notification importance level: from 1 (low) to 4 (high), 3 - standard;
* `category` - notification category, for example `email`;
* `title` - notification title;
* `text` - notification text;
* `sub_text` - additional notification text;
* `big_text` - extended notification text;
* `is_clearable` - true, if the notification is clearable;
* `group_id` - notification group ID;
* `messages` - table of tables with fields: `sender`, `text`, `time` (_available from: 4.1.5_);
* `actions` - table notifications actions with fields: `id`, `title`, `have_input` (_available from: 4.1.5_);

Keep in mind that the AIO Launcher also calls `get_current()` every time you return to the launcher, which means that all scripts will also get notification information in the `on_notify_posted()` callback every time you return to the desktop.

## Files

_Avaialble from: 4.1.3_

* `files:read(name)` - returns file contents or `nil` if file does not exist;
* `files:write(name, string)` - writes `string` to file (creates file if file does not exist);
* `files:delete(name)` - deletes the file;

All files are created in the subdirectory `/sdcard/Android/data/ru.execbit.aiolauncher/files/scripts` without ability to create subdirectories.

## Settings

* `settings:get()` - returns the settings table in an array of words format;
* `settings:set(table)` - saves the settings table in an array of words format;
* `settings:get_kv()` - returns the settings table in `key=value` format;
* `settings:set_kv(table)` - saves settings table in the format `key=value`;
* `settings:show_dialog()` - show settings change dialog.

User can change settings through the dialog, which is available by clicking on the "gear" in the edit menu of the widget. If in the widget metadata there is a field `arguments_help`, its value will be shown in the edit dialog. If there is a field `arguments_default` - it will be used to get default arguments.

The standard edit dialog can be replaced by your own if you implement the `on_settings()` function.

## Animation and real time updates

_Available only in widget scripts._
_Avaialble from: 4.5.2_

The scripts API is designed in a way that every function that changes a widget's UI updates the entire interface. This approach makes the API as simple and convenient as possible for quick scripting, but it also prevents the creation of more complex scripts that change the UI state very often.

There are two modules to solve this problem: `morph` and `anim`. The first is used to change individual UI elements, the second is used to animate those elements.

* `morph:change_text(idx, text, [duration])` - changes element text with number `idx`, `duration` - animation duration in milliseconds;
* `morph:change_text_seq(idx, table, delay)` - sequentially changes text of element with number `idx`, `table` - table of lines which will be sequentially assigned to element with delay `delay`;
* `morph:change_outer_color(idx, color)` - changes "external" color (for example, button color) of element with index `idx`, `color` - color in format #XXXXXX;
* `morph:run_with_delay(delay, function) - populates specified Lua function with delay `delay`;
* `morph:cancel(idx)` - cancels a previously run change if it is not yet complete (e.g., delay or animation is not over).

* `anim:blink(idx)` - blinks UI element with index `idx`;
* `anim:move(x, y, [delay])` - moves element sideways by specified number of DP and returns back after delay;
* `anim:heartbeat(idx)` - animation of heartbeat;
* `anim:shake(idx)` - shake animation;
* `anim:cancel(idx)` - cancel the running animation.

## Functions

_Avaialble from: 4.1.3_

* `utils:md5(string)` - returns md5-hash of string (array of bytes);
* `utils:sha256(string)` - returns sha256-hash of string (array of bytes);
* `utils:base64encode(string)` - returns base64 representation of string (array of bytes);
* `utils:base64decode(string)` - decodes base64 string;

## Data processing

* `ajson:get_value(string, string)` - gets the specified value from JSON; the first argument is a JSON string, the second is an instruction to get the value.

Unlike classic JSON parsers, this function is not intended for parsing, but for retrieving single values. For example, there is the following JSON:

```
{
  "type": "success",
  "value": {
    "id": 344,
    "joke": "Aliens DO indeed exist. They just know better than to visit a planet that Chuck Norris is on.",
    "categories": []
  }
}
```

We need to extract string "joke" from it. From the JSON text, you can see that this string is contained within the "value" object, and this object itself is inside the main JSON object. In other words, to retrieve the required string, we need to "open" the main JSON object, then "open" the "value" object and find the string "joke" in it. In code, it will look like this:

```
joke = ajson:get_value(result, "object object:value string:joke")
```

The full text of the script may look like this:

```
function on_alarm()
    http:get("http://api.icndb.com/jokes/random")
end

function on_network_result(result)
    local joke = ajson:get_value(result, "object object:value string:joke")
    aio:show_text(joke)
end
```

Another example:

```
{
  "attachments": [
    {
      "fallback": "What’s Forest Gump’s Facebook password? 1forest1",
      "footer": "<https://icanhazdadjoke.com/j/7wciy59MJe|permalink> - <https://icanhazdadjoke.com|icanhazdadjoke.com>",
      "text": "What’s Forest Gump’s Facebook password? 1forest1"
    }
  ],
  "response_type": "in_channel",
  "username": "icanhazdadjoke"
}
```

To extract "text" value we need to use this code:

```
joke = ajson:get_value(result, "object array:attachments object:0 string:text")
```

Please note that the last element of the line should always be an instruction for extracting primitive data types:

* `string:name`
* `int:name`
* `double:name`
* `boolean:name`

To summarize: ajson works well (and very fast) when you need to retrieve one or two values. If you need to get a large amount of data (or all data) from JSON, then it is better to use the `json.lua` library (see below). It turns JSON into a set of easy-to-use nested Lua tables.

## Tasker

_Avaialble from: 4.4.4_

* `tasker:get_tasks([project])` - returns a list of all the tasks in the Tasker, the second optional argument is the project for which you want to get the tasks (returns nil if Tasker is not installed or enabled);
* `tasker:get_projects()` - returns all Tasker projects (returns nil if Tasker is not installed or enabled);
* `tasker:run_task(name, [args])` - executes the task in the Tasker, the second optional argument is a table of variables passed to the task in the format `{ "name" = "value" }`;
* `tasker:run_own_task(commands)` - constructs and performs the task on the fly.

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
* `slice(table, start, end)` - returns the part of the table starting with the `start` index and ending with `end` index;
* `get_index(table, value)` - returns the index of the table element;
* `get_key(table, value)` - returns the key of the table element;
* `concat_tables(table1, table2)` - adds elements from array table `table2` to `table1`;
* `round(x, n)` - rounds the number;

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

# Metadata

In order for AIO Launcher to correctly display information about the script in the script directory and correctly display the title, you must add metadata to the beginning of the script. For example:

```
-- name = "Covid info"
-- description = "Cases of illness and death from covid"
-- data_source = "https://covid19api.com"
-- arguments_help = "Specify the country code"
-- arguments_default = "RU"
-- type = "widget"
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

* The most convenient way to upload scripts to your smartphone is to use the `install-scripts.sh` script from this repository. This is a sh script for UNIX systems which loads all the scripts from the repository onto the (virtual) memory card of the smartphone using ADB. You can edit it to your liking.
* The easiest way to reload an updated widget script is to swipe the widget to the right and then press the "reload" button. The search scripts will be reloaded automatically next time you open the search window.
* Since version 4.3.0 AIO Launcher supports widget scripts hot reloading. To enable it, go to AIO Settings -> About and click on the version number 7 times. Then open AIO Settings -> Testing and enable the option "Hot reload scripts on resume". Now when you change the script, it will be automatically reloaded when you return to the desktop.
* Since version 4.4.2 AIO Launcher includes `debug` module with methods: `debug:log(text)`, `debug:toast(text)` and `debug:dialog(text)`.

# Contribution

If you want your scripts to be included in the repository and the official AIO Launcher kit - create a pull request or email me: zobnin@gmail.com. Also I am always ready to answer your questions and discuss extending the current API.
