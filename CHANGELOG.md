### 5.5.4

* Added `icon` meta tag
* Added `private_mode` meta tag
* Added `calendar:enabled_calendar_ids()` method

### 5.5.1

* Added `calendar:is_holiday()` method

### 5.5.0

* Added `aio:add_todo()` method

### 5.3.5

* Added `ai` module

### 5.3.1

* Added `string:trim()`, `string:starts_with()` and `string:ends_with()` methods

### 5.3.0

* Added `prefs:show_dialog` method
* Added `system:show_notify()` and `system:cancel_notify()` methods
* Added support for SVG icons to the Rich UI API

### 5.2.3

* Added `on_load()` callback
* Added `on_resume_when_folding` meta tag

### 5.2.1

* Added support for complex UIs
* Added `ui:set_progress()` function

### 5.2.0

* Added `widgets` module to app widgets interaction

### 5.1.0

* Added `add_purchase` action
* Added `on_contacts_loaded()` callback

### 4.9.4

* The `aio:actions()` function now also returns arguments format for each action
* Added function `system:format_date_localized()`

### 4.9.2

* The `apps` module now has an `app()` function that returns selected app table
* You can use `%%fa:ICON_NAME%%` tag in the any text to show FontAwesome icon inside the text

### 4.9.0

* The `apps` module now has an `apps()` function that returns a table with app details, including the app icon;
* The `phone:contacts()` function now returns an icon that can be used in the side menu;
* The `apps:request_icons()` and `phone:request_icons()` functions are deprecated.

### 4.8.0

* Side menu scripts support;
* New modules: `tasks` and `notes`;
* The `ui:colors()` can be called as `aio:colors()`;
* The `apps` and `phone` modules now returns icons;
* The `apps` modules now returns also Android for Work and cloned apps;
* The `apps` module now allows you to sort apps by category;
* The `phone` and `calendar` modules now have functions for requesting access rights;
* Added `phone:open_contact() function;
* Added `aio:actions()` function that returns a table of AIO Launcher actions;
* Added `calendar:open_new_event()` function that shows the system calendar with the new event.
* Added `aio:settings()` and `aio:open_settings()` functions

### Older versions

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
* 4.5.0 - the `aio` module has been significantly expanded, also added `system:currency()` and `ui:show_list_dialog()`;
* 4.5.2 - added `anim` and `morph` packages, added `calendar:open_event()` function;
* 4.5.3 - removed get_ prefixes where they are not needed while maintaining backward compatibility;
* 4.5.5 - added `on_action` callback and `calendar:add_event` function;
* 4.5.6 - `aio:active_widgets()` now returns also widget `label`, added `checks` module;
* 4.5.7 - added "fold" and "unfold" actions to the `on_action` callback;
* 4.6.0 - added `system:request_location()` and `tasker:send_command()` functions;
* 4.7.0 - added `ui:build()` and functions to display search results in different formats;
* 4.7.1 - fontawesome updated to version 6.3.0;
* 4.7.4 - added `prefs` module, `settings` module is deprecated.
