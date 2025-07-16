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

### 5.7.1

* Added `tags` field to the app table
* Added `system:tz()` method

### 5.7.0

* Added `ui:show_image(uri)` method
* Many changes in the `notify` module

### 5.6.1

* Added `ui:set_expandable()` and `ui:is_expanded()` methods

### 5.6.0

* Added `ui:set_edit_mode_buttons()` method
* Added size argument to `widgets:request_updates()` method

[Full changelog](CHANGELOG.md)

# Widget scripts

The work of the widget script begins with one of the three described functions. Main work should be done in one of them.

* `on_load()` - called on first script load (_starting with AIO Launcher 5.2.3_).
* `on_resume()` - called every time you return to the desktop.
* `on_alarm()` - called every time you return to the desktop, but no more than once every 30 minutes.
* `on_tick(ticks)` - called every second while the launcher is on the screen. The `ticks` parameter is number of seconds after last return to the launcher.

The `on_resume()` and `on_alarm()` callbacks are also triggered when a widget is added to the screen (if `on_load()` is not defined) and the screen is forced to refresh.

For most network scripts `on_alarm()` should be used.

# Search scripts

Unlike widget scripts, search scripts are launched only when you open the search window:

* `on_load()` - called every time when user opens the search window (_starting with AIO Launcher 5.2.3_).

Then the following function is triggered each time a character is entered:

* `on_search(string)` is run when each character is entered, `string` - entered string.

The search script can use two functions to display search results:

* `search:show_buttons(names, [colors], [top])` - show buttons in the search results, the first parameter is table of button names, second - table of button colors in format `#XXXXXX`, `top` - whether the results need to be shown at the top (false by default);
* `search:show_lines(lines, [colors], [top])` - show text lines in the search results;
* `search:show_progress(names, progresses, [colors], [top])` - show progress bars in the search results, the first parameter is a table of names, the second is a table of progress bars (from 1 to 100);
* `search:show_chart(points, format, [title], [show_grid], [top])` - show chart in the search results, parameters are analogous to `ui:show_chart()`.

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

_AIO Launcher also offers a way to create more complex UIs: [instructions](README_RICH_UI.md)_

* `ui:show_text(string)` - displays plain text in widget, repeated call will erase previous text;
* `ui:show_lines(table, [table], [folded_string])` - displays a list of lines with the sender (in the manner of a mail widget), the second argument (optional) - the corresponding senders (formatting in the style of a mail widget), folded\_string (optional) - string to be shown in folded mode;
* `ui:show_table(table, [main_column], [centering], [folded_value])` - displays table, first argument: table of tables, second argument: main column, it will be stretched, occupying main table space (if argument is zero or not specified all table elements will be stretched evenly), third argument: boolean value indicating whether table cells should be centered, fourth argument: string or table to be shown in folded mode;
* `ui:show_buttons(names, [colors])` - displays a list of buttons, the first argument is a table of strings, the second is an optional argument, a table of colors in the format #XXXXXX;
* `ui:show_progress_bar(text, current_value, max_value, [color])` - shows the progress bar;
* `ui:show_chart(points, [format], [title], [show_grid], [folded_string], [copyright])` - shows the chart, points - table of coordinate tables, format - data format (see below), title - chart name, show\_grid - grid display flag, folded\_string - string for the folded state (otherwise the name will be shown), copyright - string displayed in the lower right corner;
* `ui:show_image(uri)` - show image by URL;
* `ui:show_toast(string)` - shows informational message in Android style;
* `ui:default_title()` - returns the standard widget title (set in the `name` metadata);
* `ui:set_title()` - changes the title of the widget, should be called before the data display function (empty line - reset to the standard title);
* `ui:set_folding_flag(boolean)` - sets the flag of the folded mode of the widget, the function should be called before the data display functions;
* `ui:folding_flag()` - returns folding flag;
* `ui:set_expandable()` - shows expand button on widget update;
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

You can insert FontAwesome icons inside the text, to do this use this syntax: `%%fa:ICON_NAME%%. For example:

```
ui:show_text("<b>This</b> is the text with icons %%fa:face-smile%% %%fa:poo%% <i>and styles</i>")
```

The `ui:show_buttons()` function supports Fontawesome icons. Simply specify `fa:icon_name` as the button name, for example: `fa:play`.

_Note: AIO only supports icons up to Fontawesome 6.3.0._

## Dialogs

_Available only in widget scripts._

* `dialogs:show_dialog(title, text, [button1_text], [button2_text])` - show dialog, the first argument is the title, the second is the text, button1\_text is the name of the first button, button2\_text is the name of the second button;
* `dialogs:show_edit_dialog(title, [text], [default_value])` - show the dialog with the input field: title - title, text - signature, default\_value - standard value of the input field;
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

_Avaialble from: 4.4.1_

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

## Meta widgets

_Avaialble from: 4.7.0_

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

The result of executing a shell command is sent to the `on_shell_result(string)` or `on_shell_result_$id(string)` (_starting from AIO 5.7.5_) callback.

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

* `aio:available_widgets()` - returns a table with the metadata of all widgets, scripts and plugins available for adding to the screen (_available from: 4.5.0_);
* `aio:active_widgets()` - returns a table with the metadata of all widgets, scripts, and plugins already added to the screen (_available from: 4.5.0_);
* `aio:add_widget(string, [position])` - adds a builtin widget, script widget or clone of an existing widget to the screen;
* `aio:remove_widget(string)` - removes the widget from the screen (instead of the name you can also pass the widget number or do not pass anything - then the current widget will be deleted);
* `aio:move_widget(string, position)` - moves the widget to a new position (you can also use the widget position instead of the name) (_available from: 4.5.0_);
* `aio:fold_widget(string, [boolean])` - fold/unfold widget (if you do not specify the second argument the state will be switched) (_available from: 4.5.0_);
* `aio:is_widget_added(string)` - checks if the widget is added to the screen;
* `aio:self_name()` - returns current script file name (_available from: 4.5.0_);
* `aio:send_message(value, [script_name])` - sends lua value to other script or scripts (_avaialble from: 4.5.0_);
* `aio:colors()` - returns table with current theme colors;
* `aio:do_action(string)` - performs an AIO action ([more](https://aiolauncher.app/api.html));
* `aio:actions()` - returns a list of available actions;
* `aio:settings()` - returns a list of available AIO Settings sections;
* `aio:open_settings([section])` - open AIO Settings or AIO Settings section;
* `aio:add_todo(icon, text)` - add a TODO item with the specified Fontawesome icon and text.

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

* `http:get(url, [id])` - executes an HTTP GET request, `id` - the request identifier string (see below);
* `http:post(url, body, media_type, [id])` - executes an HTTP POST request;
* `http:put(url, body, media_type, [id])` - executes an HTTP request;
* `http:delete(url, [id])` - executes an HTTP DELETE request;
* `http:set_headers(table)` - sets the headers for **all** subsequent network requests; the argument is a table with strings like "Cache-Control: no-cache".

These functions do not return any value, but instead call the `on_network_result(string, [code])` callback. The first argument is the body of the response, the second (optional) is the code (200, 404, etc.).

If `id` was specified in the request, then the function will call `on_network_result_$id(string, [code])` instead of the callback described above. That is, if the id is "server1", then the callback will look like `on_network_result_server1(string, [code])`.

If there is a problem with the network, the `on_network_error_$id` callback will be called. But it does not have to be processed.

## Calendar

* `calendar:events([start_date], [end_date], [cal_table])` - returns table of event tables of all calendars, start\_date - event start date, end\_date - event end date, cal\_table - calendar ID table (function will return the string `permission_error` if the launcher does not have permissions to read the calendar);
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

## Tasks

_Avaialble from: 4.8.0_

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

_Avaialble from: 4.8.0_

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

_Avaialble from: 4.1.0_

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

_Avaialble from: 4.1.0_

* `cloud:get_metadata(path)` - returns a table with file metadata;
* `cloud:get_file(path)` - returns the contents of the file;
* `cloud:put_file(sting, path)` - writes a string to the file;
* `cloud:remove_file(path)` - deletes file;
* `cloud:list_dir(path)` - returns metadata table of all files and subdirectories;
* `cloud:create_dir(path)` - creates directory;

All data are returned in `on_cloud_result(meta, content)`. The first argument is the metadata, either a metadata table (in the case of `list_dir()`) or an error message string. The second argument is the contents of the file (in the case of `get_file()`).

## Profiles

_Avaialble from: 5.3.6._

* `profiles:list()` - returns a list of saved profiles;
* `profiles:dump(name)` - saves a new profile with the specified name;
* `profiles:restore(name)` - restores the saved profile;
* `profiles:dump_json()` - creates a new profile but instead of saving it, returns it as a JSON string;
* `profiles:restore_json(json)` - restores a profile previously saved using `dump_json()`.

## AI

_Avaialble from: 5.3.5._

_Requires subscription._

* `ai:complete(text)` - send message to the AI;
* `ai:translate(text, lang)` - translate text to the language with code `lang` (`en`, `de`, `es` etc).

All functions return an answer in the callback `on_ai_answer`. For example:

```
function on_alarm()
    ai:complete("Who are you?")
end

function on_ai_answer(answer)
    ui:show_text(answer)
end
```

_Keep in mind that the launcher imposes certain limitations on the use of this module. If you use it too frequently, you will receive an `error: rate limit` instead of a response. Additionally, an error will be returned if the request includes too much text._

## Reading notifications

_Available only in widget scripts._

_Avaialble from: 4.1.3._

_This module is intended for reading notifications from other applications. To send notifications, use the `system` module._

* `notify:list()` - returns list of current notifications as table of tables;
* `notify:open(key)` - opens notification with specified key;
* `notify:close(key)` - removes the notification with the specified key;
* `notify:do_action(key, action_id)` - sends notification action (_available from: 4.1.5_).

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
`messages` - table of tables with fields: `sender`, `text`, `time` (_available from: 4.1.5_);
`actions` - table notifications actions with fields: `id`, `title`, `have_input` (_available from: 4.1.5_);
```

Keep in mind that the AIO Launcher also request current notifications every time you return to the launcher, which means that all scripts will also get the `on_notifications_updated()` callback called.

## Files

_Avaialble from: 4.1.3_

* `files:read(name)` - returns file contents or `nil` if file does not exist;
* `files:write(name, string)` - writes `string` to file (creates file if file does not exist);
* `files:delete(name)` - deletes the file;

All files are created in the subdirectory `/sdcard/Android/data/ru.execbit.aiolauncher/files/scripts` without ability to create subdirectories.

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

## Animation and real time updates

_Available only in widget scripts._

_Avaialble from: 4.5.2_

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

_Avaialble from: 4.1.3_

* `utils:md5(string)` - returns md5-hash of string (array of bytes);
* `utils:sha256(string)` - returns sha256-hash of string (array of bytes);
* `utils:base64encode(string)` - returns base64 representation of string (array of bytes);
* `utils:base64decode(string)` - decodes base64 string;

## Tasker

_Avaialble from: 4.4.4_

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

* The most convenient way to upload scripts to your smartphone is to use the `install-scripts.sh` script from this repository. This is a sh script for UNIX systems which loads all the scripts from the repository onto the (virtual) memory card of the smartphone using ADB. You can edit it to your liking.
* The easiest way to reload an updated widget script is to swipe the widget to the right and then press the "reload" button. The search scripts will be reloaded automatically next time you open the search window.
* Since version 4.3.0 AIO Launcher supports widget scripts hot reloading. To enable it, go to AIO Settings -> About and click on the version number 7 times. Then open AIO Settings -> Testing and enable the option "Hot reload scripts on resume". Now when you change the script, it will be automatically reloaded when you return to the desktop.
* Since version 4.4.2 AIO Launcher includes `debug` module with methods: `debug:log(text)`, `debug:toast(text)` and `debug:dialog(text)`;
* Since version 4.8.0 you can use `--testing = "true"` meta tag. In this case, launcher will gray out the script and place it at the end of the list in the side menu.

# Contribution

If you want your scripts to be included in the repository and the official AIO Launcher kit - create a pull request or email me: zobnin@gmail.com. Also I am always ready to answer your questions and discuss extending the current API.
