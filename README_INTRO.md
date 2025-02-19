# Creating Your Own Scripts for AIO Launcher: A Step-by-Step Guide for Beginners

**AIO Launcher** isn’t just an alternative to the standard Android home screen — it transforms your device into a powerful tool for personalization through Lua scripting. In this article, we’ll show you how to write your first scripts, presenting three examples ranging from simple text output to an interactive widget and integration with an open API. We’ll also explain how to add your scripts to the launcher via AIO Store.

---

## How to Create and Load Scripts

You can write scripts for AIO Launcher in any text editor—whether it’s Sublime Text, Visual Studio Code, or even Notepad. The key is to save your file with the **.lua** extension. Then, using the **AIO Store** app, you can easily add your file to the launcher. In AIO Store, at the end of the list of installed scripts there’s a special "Add Script" button that lets you add your own script.

---

## Example 1. Hello, World!

The simplest script is the classic "Hello, World!" In this example, when the widget is launched, a welcome message appears on the screen.

```lua
-- name = "Hello, World!"
-- type = "widget"

function on_load()
    -- On the first load of the widget, display the text "Hello, World!".
    ui:show_text("Hello, World!")
end
```

*Explanation:*

- The metadata at the beginning of the file sets the script’s name and type.
- The `on_load()` function is called when the script starts.
- The `ui:show_text()` method displays the text on the widget.

---

## Example 2. Interactive Counter

In the second example, we create an interactive counter using two buttons. Instead of displaying the count separately, the current counter value is embedded directly in the label of the "Increase" button. When you press "Increase", the counter increments and the button label updates; pressing "Reset" sets the counter back to zero.

```lua
-- name = "Interactive Counter"
-- type = "widget"

-- Global variable to store the current count.
local counter = 0

-- Function to update the display: shows two buttons with the counter embedded in the first button.
function update_display()
    ui:show_buttons({ "Increase (" .. counter .. ")", "Reset" })
end

function on_load()
    update_display()
end

-- Function to handle button clicks.
function on_click(index)
    if index == 1 then
        counter = counter + 1
    elseif index == 2 then
        counter = 0
    end
    update_display()
end
```

*Explanation:*

- When the script launches, the `on_load()` function calls `update_display()`, which displays two buttons.
- The first button’s label includes the current counter value (e.g., "Increase (0)").
- The `on_click(index)` function handles button presses: if the first button is pressed, the counter increases; if the second button is pressed, it resets to zero.
- After each action, `update_display()` updates the button labels accordingly.

---

## Example 3. Cat Facts

In the third example, we use the Cat Facts API to retrieve a random cat fact. This version uses the `on_alarm` callback instead of `on_load` so that the widget automatically updates every 30 minutes.

```lua
-- name = "Cat Facts"
-- type = "widget"

-- on_alarm is called automatically, up to once every 30 minutes, to refresh the widget.
function on_alarm()
    ui:show_text("Loading a random cat fact...")
    http:get("https://catfact.ninja/fact")
end

function on_network_result(body, code)
    if code == 200 then
        local json = require "json"
        local data = json.decode(body)  -- The json module converts the JSON string into a Lua table.
        if data and data.fact then
            ui:show_text("Random Cat Fact:\n" .. data.fact)
        else
            ui:show_text("Failed to retrieve a cat fact.")
        end
    else
        ui:show_text("Error loading data. Code: " .. code)
    end
end
```

*Explanation:*

- In this example, the `on_alarm()` function is used to trigger an automatic update every 30 minutes, ensuring that your widget stays fresh with a new cat fact.
- The `http:get()` call fetches data from the Cat Fact API, and the `json` module decodes the returned JSON string into a Lua table for easy access.

Remember: there’s also an `on_resume` callback that is invoked every time you return to the home screen, which you can use for additional actions if desired.

---

## Example 4. Search Engine Selector for the Search Window

In this example, we demonstrate how to create a search script for the AIO Launcher search window. Unlike widget scripts, search scripts are activated when the search window is opened and as the user types their query. This script presents two search suggestions — one for searching on Google and another for Bing. When a suggestion is clicked, the corresponding search engine opens in the browser.

```lua
-- name = "Search Engine Selector"
-- type = "search"

local lastQuery = ""

function on_search(query)
    lastQuery = query
    local results = {}
    if #query > 0 then
        table.insert(results, "Search Google for: " .. query)
        table.insert(results, "Search Bing for: " .. query)
    end
    search:show_lines(results)
end

function on_click(index)
    if index == 1 then
        system:open_browser("https://www.google.com/search?q=" .. lastQuery)
        return true
    elseif index == 2 then
        system:open_browser("https://www.bing.com/search?q=" .. lastQuery)
        return true
    end
    return false
end
```

*Explanation:*

- This search script is identified as a search script by the meta tag `-- type = "search"`.
- The global variable `lastQuery` stores the most recent search query.
- The `on_load()` function is called each time the search window is opened, displaying a default message.
- The `on_search(query)` function is invoked whenever the user types something; it saves the query and builds a list of suggestions, which are displayed via `search:show_lines()`.
- The `on_click(index)` function handles the user's selection: if the first result is clicked, the system opens Google with the query; if the second is clicked, Bing is used.

---

## Example 5. Side Menu Script

This example demonstrates how to create a side menu (drawer) script for AIO Launcher. Side menu scripts allow you to add custom items to the launcher's side menu. The script type is defined by the meta tag `-- type = "drawer"`, and the primary callback function is `on_drawer_open()`, which is invoked when the side menu is opened. When the user selects an item, the `on_click(index)` function is called to execute the corresponding action.

```lua
-- name = "Custom Drawer Menu"
-- type = "drawer"

function on_drawer_open()
    local menuItems = {"Open Website", "Update list", "Launch App"}
    drawer:show_list(menuItems)
end

function on_click(index)
    if index == 1 then
        system:open_browser("https://www.example.com")
    elseif index == 2 then
        local menuItems = {"Open Website", "List updated", "Launch App"}
        drawer:show_list(menuItems)
    elseif index == 3 then
        apps:launch("com.android.contacts")
    end
    return true
end
```

*Explanation:*

- The meta tags at the top specify the script’s name and indicate that it is a drawer (side menu) script.
- The `on_drawer_open()` function is automatically called when the side menu is opened; it builds a list of menu items (in this case, three items) and displays them using `drawer:show_list()`.
- The `on_click(index)` function handles user selection: clicking the first item opens a website, the second updates items list, and the third launches an application.

## Conclusion

Creating scripts for AIO Launcher opens up endless possibilities for customizing and extending the functionality of your Android device. From simple text output to interactive widgets and integration with external services, all of this is accessible thanks to the powerful API of AIO Launcher and the flexibility of Lua. Use any text editor you prefer to write your scripts, then easily add them to the launcher via AIO Store using the dedicated "Add Script" button at the end of your installed scripts list. Experiment, integrate new data sources, and create unique solutions that make your home screen truly your own!

---

## Sources for Further Study

- citeturn0search0 [Official AIO Launcher Scripts Repository](https://github.com/zobnin/aiolauncher_scripts)
- [AIO Launcher on Google Play](https://play.google.com/store/apps/details?id=ru.execbit.aiolauncher&hl=en)
- [Lua Documentation](https://www.lua.org/pil/)
- [Cat Fact API](https://catfact.ninja/fact)
- [AIO Store](https://play.google.com/store/apps/details?id=ru.execbit.aiolauncher.store)

These resources will help you dive deeper into creating scripts for AIO Launcher and explore new ways to extend your Android device’s functionality.
