Starting from version 5.2.0, AIO Launcher supports interaction with app widgets through scripts. This means that you can create a wrapper for any app's widget that will fully match the appearance and style of AIO. You can also use this API if you need to retrieve information from other applications, such as the balance on your mobile phone account or your car's parking spot. If the application has a widget providing such information, you will be able to access it.

### Introduction

Before you start working with app widgets, you need to find out the app widget provider's name and the widget interface structure. Both can be done using the [android-widget-dumper.lua](dev/android-widget-dumper.lua) script. Enter the package name of the desired application in its global variable `app_pkg` and run the script. It will display all the widgets available for that application. Click on the widget name, and you will see its provider name (first line) and a tree-like structure of its UI. Click on the text to copy it.

_Note: Some widgets can dynamically change their UI depending on their size. If you encounter such a widget, update the value of the `widget_size` variable by specifying a string from `1x1` to `4x4`. In other cases, leave the value as `nil`._

Take, for example, The Weather Channel app (package name: `com.weather.Weather`). Install this app and add its package name to the dumper script. After running the dumper, it will show you a list of widgets. Click on "Widget 2x2". A widget configuration screen will open. Click Done at the top of the configurator screen, and you will see the data of this widget. The first line will be the provider's name:

```
com.weather.Weather/com.weather.Weather.widgets.WeatherWidgetProvider2x2
```

The second block of information is the widget interface structure:

```
relative_layout_1:
  image_1: #13356F
  relative_layout_2:
    image_2: 270x270
    text_1: 40°
    text_2: Paris, France
  text_3: Weather data not available
```

You can see that the widget contains two images and three text fields: `text_1`, `text_2`, `text_3`. The first two contain the information we need: temperature and location.

Now we have everything to write our own widget that will use information from The Weather Channel widget and display it in a format convenient for us!

### Writing a Widget Wrapper

Let's start by writing a widget initialization function:

```
function setup_app_widget()
    local id = widgets:setup("com.weather.Weather/com.weather.Weather.widgets.WeatherWidgetProvider2x2")
    if (id ~= nil) then
        prefs.wid = id
    else
        ui:show_text("Can't add widget")
    end
end
```

Using the `widgets:setup()` method, we ask the launcher to prepare a widget for us. The method returns an identifier needed to work with the widget, or `nil` if an error occurred. Note that this function may trigger the widget's configuration window if it has one.

Having obtained the identifier, we can use it to communicate with the widget. For this purpose, we call the `widgets:request_updates()` method (you can specify the widget size as a string from 1x1 to 4x4 as the second argument):

```
widgets:request_updates(prefs.wid)
```

This method prepares the widget and then calls the `on_widget_updated(bridge)` callback every time the widget updates. The `bridge` object here is the main "window" or "bridge" for interacting with the widget. It's with its help that we will extract information from the widget.

The most straightforward way to do this is to use the `bridge:dump_table()` method, which returns the same UI element hierarchy as the dumper script but in a Lua table format. Here's how we can use it to extract the strings we need and display them on the screen:

```
function on_app_widget_updated(bridge)
    local tab = bridge:dump_table()
    temp = tab.relative_layout_1.relative_layout_2.text_1
    location = tab.relative_layout_1.relative_layout_2.text_2

    if location ~= nil and temp ~= nil then
        ui:show_text(location..": "..temp)
    end
end
```

Run the example [android-widget-sample2.lua](samples/android-widget-sample2.lua) to see how it looks on the screen.

Another way to extract the same information is to use the `bridge:dump_strings()` method:

```
function on_app_widget_updated(bridge)
    strings = bridge:dump_strings().values
    temp = strings[1]
    location = strings[2]

    if location ~= nil and temp ~= nil then
        ui:show_text(location..": "..temp)
    end
end
```

It returns a table of tables, where the `keys` table is an array of UI text elements, and `values` contains the text strings within them. You can use whichever method suits you better.

In both cases, the strings can include HTML tags (`<b>`, `<i>`, `<s>`, `<u>`) if the corresponding styles were applied to the text in the widget.

### Handling Clicks

Extracting information from an app widget is only half the job. Most widgets are interactive, meaning you can click on them to get some response, like adding a new note or opening a currency exchange rate window.

Implementing clicks on widget elements from the script is very simple: just use the `bridge:click()` method, passing it the name of the UI element or the string it contains as an argument:

```
bridge:click(temp)
```

Open the example [android-widget-sample2.lua](samples/android-widget-sample2.lua) to see how this can be used in the script.

### Updating and releasing the Widget

The AIO Launcher widget API is designed to keep the widget in memory all the time while the script is on the screen. This means that after calling `widgets:request_updates()`, the launcher will call the `on_widget_updated()` callback after _every_ widget interface update as long as the script is on the launcher's screen, and the launcher is on the phone's screen.

In most cases, such a mechanism is preferable. However, there are situations when `on_widget_updated()` should only be called when the script asks for it, and the widget itself should not constantly hang in memory. For this, there's a special `bridge:free()` method.

For example, you have a widget whose information you want to receive every morning, not with every update. In this case, you do everything the same as in the example above, but at the end of the `on_app_widget_updated()` function, you call `bridge:free()`. After that, the launcher will release the widget and will no longer call the `on_widget_updated()` method (while the widget itself will not respond to clicks). Then, it's enough to call `widgets:request_updates()` every morning to update the script's content.

### Other Functions

The information provided above is sufficient to handle almost any application widget. However, to write a truly efficient script, you'll need a few more auxiliary functions:

* `widgets:bound(id)` - returns true if the specified widget identifier was previously initialized using `widgets:setup()`. You should _always_ call this function at the beginning of the script and call `widgets:setup()` only if it returns `false`.

* `bridge:color(element_name)` - returns the color of an element in the format `#000000`. With this method, you can find out the color of the text, the background color of the layout (if set), or even extract the primary color from an image.

Other functions:

```
* bridge:label() - returns the name of the widget;
* bridge:provider() - returns the name of the widget provider;
* bridge:dump_tree() - returns the UI tree in text format;
* bridge:dump_json() - returns the UI tree in Json format;
* bridge:dump_colors() - returns a table of color tables, where `keys` are element names, `values` are colors;
* bridge:dump_elements(element_name) - returns a table of tables of specified elements, where `keys` are element names, `values` are their values.
```

### Examples

In the [samples](samples/) directory, you will find several widget examples. Also, pay attention to the Todoist and Chrome widgets in the [community](community/) directory.

